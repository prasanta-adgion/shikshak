import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/core_providers.dart';
import '../../../about_you/data/about_you_section.dart';
import '../../../basic_info/data/basic_info_section.dart';
import '../../../documents/data/document_section.dart';
import '../../../education/data/education_section.dart';
import '../../../experience/data/experience_section.dart';
import '../../data/datasource/profile_section_remote_datasource.dart';
import '../../data/repository/profile_section_repository_impl.dart';
import '../../domain/entities/profile_section.dart';
import '../../domain/entities/profile_step.dart';
import '../../domain/repositories/profile_section_repository.dart';
import '../../domain/usecases/save_profile_section_usecase.dart';
import '../controller/wizard_step_controller.dart';
import '../notifier/account_create_notifier.dart';
import '../state/account_create_state.dart';

/// Composition root for the teacher profile wizard. Everything depends on
/// abstractions; only this file knows the concrete classes.

/// Which section belongs to which step. Adding a sixth section is one entry
/// here plus its mapper — the notifier, the page and the transport are
/// untouched.
final profileSectionsProvider = Provider<Map<ProfileStep, ProfileSection>>(
  (ref) => const {
    ProfileStep.basicInfo: BasicInfoSection(),
    ProfileStep.aboutYou: AboutYouSection(),
    ProfileStep.experience: ExperienceSection(),
    ProfileStep.education: EducationSection(),
    ProfileStep.documents: DocumentSection(),
  },
);

final profileSectionRemoteDataSourceProvider =
    Provider<ProfileSectionRemoteDataSource>((ref) {
      return ProfileSectionRemoteDataSourceImpl(ref.watch(apiClientProvider));
    });

final profileSectionRepositoryProvider = Provider<ProfileSectionRepository>((
  ref,
) {
  return ProfileSectionRepositoryImpl(
    remoteDataSource: ref.watch(profileSectionRemoteDataSourceProvider),
  );
});

final saveProfileSectionUseCaseProvider = Provider<SaveProfileSectionUseCase>((
  ref,
) {
  return SaveProfileSectionUseCase(
    sections: ref.watch(profileSectionsProvider),
    repository: ref.watch(profileSectionRepositoryProvider),
    uploader: ref.watch(fileUploaderProvider),
  );
});

/// The draft lives only as long as the wizard is on screen — disposing it with
/// the route is deliberate, so an abandoned setup cannot leak into the next.
final accountCreateNotifierProvider =
    NotifierProvider<AccountCreateNotifier, AccountCreateState>(
      AccountCreateNotifier.new,
    );

/// Lets the pinned action bar submit the step currently on screen.
final wizardStepControllerProvider = Provider<WizardStepController>(
  (ref) => WizardStepController(),
);
