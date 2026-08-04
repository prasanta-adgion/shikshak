import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/core_providers.dart';
import '../../../about_you/data/about_you_section.dart';
import '../../../basic_info/data/basic_info_section.dart';
import '../../../documents/data/document_section.dart';
import '../../../education/data/education_section.dart';
import '../../../experience/data/experience_section.dart';
import '../../data/datasource/profile_section_remote_datasource.dart';
import '../../data/repository/file_upload_repository_impl.dart';
import '../../data/repository/profile_section_repository_impl.dart';
import '../../domain/entities/profile_section.dart';
import '../../domain/entities/profile_step.dart';
import '../../domain/repositories/file_upload_repository.dart';
import '../../domain/repositories/profile_section_repository.dart';
import '../../domain/usecases/save_profile_section_usecase.dart';
import '../../domain/usecases/upload_file_usecase.dart';
import '../controller/wizard_step_controller.dart';
import '../notifier/account_create_notifier.dart';
import '../state/account_create_state.dart';

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
  );
});

/// Every attachment the wizard sends — certificates, documents — goes up
/// through this one use case.
final fileUploadRepositoryProvider = Provider<FileUploadRepository>(
  (ref) => FileUploadRepositoryImpl(ref.watch(fileUploaderProvider)),
);

final uploadFileUseCaseProvider = Provider<UploadFileUseCase>(
  (ref) => UploadFileUseCase(ref.watch(fileUploadRepositoryProvider)),
);

/// The draft lives only as long as the wizard is on screen: `isAutoDispose`
/// drops it once the last step stops listening, so an abandoned setup cannot
/// leak into the next one.
final accountCreateNotifierProvider =
    NotifierProvider<AccountCreateNotifier, AccountCreateState>(
      AccountCreateNotifier.new,
      isAutoDispose: true,
    );

/// Lets the pinned action bar submit the step currently on screen.
final wizardStepControllerProvider = Provider<WizardStepController>(
  (ref) => WizardStepController(),
);
