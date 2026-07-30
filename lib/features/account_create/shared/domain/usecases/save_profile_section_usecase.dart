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
  const SectionSaveOutcome({
    required this.draft,
    required this.savedBody,
    required this.wasSkipped,
  });

  /// The draft after any upload wrote its URL back in.
  final TeacherProfileDraft draft;

  /// Encoded body now on the server, to compare against on the next attempt.
  final String savedBody;

  /// True when nothing had changed and no request was made.
  final bool wasSkipped;
}

/// Saves the section belonging to a step, deciding between create, update and
/// doing nothing at all.
///
/// Each section is judged on its own history:
///
/// | state                            | action        |
/// |----------------------------------|---------------|
/// | never saved                      | `POST path`   |
/// | saved, and the body has changed  | `PATCH path`  |
/// | saved, and the body is identical | no request    |
///
/// So a section creates itself the first time its step is completed, and
/// updates on every later pass.
///
/// Change detection compares the encoded body rather than the entity, so it
/// reacts to exactly the fields that go over the wire and needs no equality
/// plumbing on the domain objects.
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
