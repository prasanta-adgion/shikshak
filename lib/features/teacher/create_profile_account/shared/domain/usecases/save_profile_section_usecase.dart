import 'dart:convert';

import '../../../../../../core/network/api_result.dart';
import '../../../../../../core/network/request_body.dart';
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
  }) : _sections = sections,
       _repository = repository;

  final Map<ProfileStep, ProfileSection> _sections;
  final ProfileSectionRepository _repository;

  Future<ApiResult<SectionSaveOutcome>> call({
    required ProfileStep step,
    required TeacherProfileDraft draft,
    required String? lastSavedBody,
  }) async {
    final section = _sections[step];
    if (section == null) {
      throw StateError('No ProfileSection registered for ${step.name}.');
    }

    // Sanitised before encoding, so the body compared for changes is exactly
    // the body sent.
    final body = RequestBody.nullsAsEmptyStrings(section.body(draft));
    final encoded = jsonEncode(body);

    if (section is RepeatableSection) {
      return _saveEntry(
        section as RepeatableSection,
        path: section.path,
        draft: draft,
        body: body,
        encoded: encoded,
        lastSavedBody: lastSavedBody,
      );
    }

    if (encoded == lastSavedBody) {
      return ApiResult.success(
        SectionSaveOutcome(draft: draft, savedBody: encoded, wasSkipped: true),
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
        draft: draft,
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
}
