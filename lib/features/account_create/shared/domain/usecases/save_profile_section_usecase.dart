import 'dart:convert';

import '../../../../../core/network/api_result.dart';
import '../../../../../core/network/file_uploader.dart';
import '../../../../../core/network/request_body.dart';
import '../entities/profile_section.dart';
import '../entities/profile_step.dart';
import '../entities/teacher_profile_draft.dart';
import '../repositories/profile_section_repository.dart';

/// What a save did, and the draft it leaves behind.
class SectionSaveOutcome {
  final TeacherProfileDraft draft;

  final String savedBody;

  final bool wasSkipped;
  const SectionSaveOutcome({
    required this.draft,
    required this.savedBody,
    required this.wasSkipped,
  });
}

///
/// | state                            | action        |
/// |----------------------------------|---------------|
/// | never saved                      | `POST path`   |
/// | saved, and the body has changed  | `PATCH path`  |
/// | saved, and the body is identical | no request    |

class SaveProfileSectionUseCase {
  const SaveProfileSectionUseCase({
    required Map<ProfileStep, ProfileSection> sections,
    required ProfileSectionRepository repository,
    required FileUploader uploader,
  }) : _sections = sections,
       _repository = repository,
       _uploader = uploader;

  final Map<ProfileStep, ProfileSection> _sections;
  final ProfileSectionRepository _repository;
  final FileUploader _uploader;

  Future<ApiResult<SectionSaveOutcome>> call({
    required ProfileStep step,
    required TeacherProfileDraft draft,
    required String? lastSavedBody,
  }) async {
    final section = _sections[step];
    if (section == null) {
      throw StateError('No ProfileSection registered for ${step.name}.');
    }

    // Files first: the body cannot be built until their URLs exist.
    var currentDraft = draft;
    if (section is UploadingSection) {
      final uploaded = await _uploadPending(
        section as UploadingSection,
        currentDraft,
      );
      if (uploaded is ApiFailure<Map<String, String>>) {
        return ApiResult.failure(uploaded.exception);
      }

      final urls = (uploaded as ApiSuccess<Map<String, String>>).data;
      if (urls.isNotEmpty) {
        currentDraft = (section as UploadingSection).withUploadedUrls(
          currentDraft,
          urls,
        );
      }
    }

    // Sanitised before encoding, so the body compared for changes is exactly
    // the body sent.
    final body = RequestBody.nullsAsEmptyStrings(section.body(currentDraft));
    final encoded = jsonEncode(body);

    if (section is RepeatableSection) {
      return _saveEntry(
        section as RepeatableSection,
        path: section.path,
        draft: currentDraft,
        body: body,
        encoded: encoded,
        lastSavedBody: lastSavedBody,
      );
    }

    if (encoded == lastSavedBody) {
      return ApiResult.success(
        SectionSaveOutcome(
          draft: currentDraft,
          savedBody: encoded,
          wasSkipped: true,
        ),
      );
    }

    final result = await _repository.submit(
      path: section.path,
      body: body,
      // Having a saved body means this section already exists on the server.
      isUpdate: lastSavedBody != null,
    );

    return result.map(
      (_) => SectionSaveOutcome(
        draft: currentDraft,
        savedBody: encoded,
        wasSkipped: false,
      ),
    );
  }

  /// Repeatable sections always create: every entry is a new row, so there is
  /// no body to compare against and never a PATCH. A blank form means the
  /// teacher has filed everything they wanted, so nothing is sent.
  Future<ApiResult<SectionSaveOutcome>> _saveEntry(
    RepeatableSection section, {
    required String path,
    required TeacherProfileDraft draft,
    required Map<String, dynamic> body,
    required String encoded,
    required String? lastSavedBody,
  }) async {
    if (section.isEntryEmpty(draft)) {
      return ApiResult.success(
        SectionSaveOutcome(
          draft: draft,
          savedBody: lastSavedBody ?? '',
          wasSkipped: true,
        ),
      );
    }

    final result = await _repository.submit(
      path: path,
      body: body,
      isUpdate: false,
    );

    return result.map(
      (_) => SectionSaveOutcome(
        draft: section.commitEntry(draft),
        savedBody: encoded,
        wasSkipped: false,
      ),
    );
  }

  /// Uploads every pending file, stopping at the first failure so a half
  /// uploaded section is never sent.
  Future<ApiResult<Map<String, String>>> _uploadPending(
    UploadingSection section,
    TeacherProfileDraft draft,
  ) async {
    final pending = section.pendingUploads(draft);
    final urls = <String, String>{};

    for (final upload in pending) {
      final result = await _uploader.upload(upload.localPath);
      switch (result) {
        case ApiSuccess(:final data):
          urls[upload.field] = data;
        case ApiFailure(:final exception):
          return ApiResult.failure(exception);
      }
    }

    return ApiResult.success(urls);
  }
}
