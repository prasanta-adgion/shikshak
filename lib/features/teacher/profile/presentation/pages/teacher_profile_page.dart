import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/date_time_picker_func.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../shared/widgets/app_snackbar.dart';
import '../../../../../shared/widgets/empty_state.dart';
import '../../../../../shared/widgets/error_state.dart';
import '../../../../auth/presentation/widgets/logout_button.dart';
import '../../../create_profile_account/shared/presentation/widgets/saved_entry_card.dart';
import '../../domain/entities/teacher_profile.dart';
import '../providers/teacher_profile_providers.dart';
import '../widgets/profile_chip_wrap.dart';
import '../widgets/profile_detail_row.dart';
import '../widgets/profile_document_tile.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_section_card.dart';
import '../widgets/profile_status_banner.dart';

/// Read-only view of the signed-in teacher's profile.
class TeacherProfilePage extends ConsumerStatefulWidget {
  const TeacherProfilePage({super.key});

  @override
  ConsumerState<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends ConsumerState<TeacherProfilePage> {
  @override
  void initState() {
    super.initState();
    // Deferred: the notifier writes state, which cannot happen during build.
    Future.microtask(
      () => ref.read(teacherProfileNotifierProvider.notifier).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(teacherProfileNotifierProvider);
    final profile = state.profile;

    ref.listen(teacherProfileNotifierProvider, (previous, next) {
      final error = next.error;
      if (error != null && next.profile != null && previous?.error != error) {
        AppSnackbar.showError(context, error.message);
      }
    });

    return CenteredConstrainedBox(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            automaticallyImplyLeading: false,
            titleSpacing: AppSpacing.xl,
            title: Text('My Profile', style: theme.textTheme.titleLarge),
            actions: [
              if (state.isLoading && profile != null)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Center(
                    child: SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    ),
                  ),
                ),
              const LogoutButton(),
              AppSpacing.hGapMd,
            ],
          ),
          if (profile == null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _PlaceholderBody(
                isLoading: state.isLoading,
                hasLoaded: state.hasLoaded,
                errorMessage: state.error?.message,
                onRetry: () =>
                    ref.read(teacherProfileNotifierProvider.notifier).refresh(),
              ),
            )
          else
            SliverPadding(
              padding: context.responsivePagePadding,
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  AppSpacing.gapSm,
                  ProfileHeaderCard(profile: profile),
                  AppSpacing.gapLg,
                  ProfileStatusBanner(
                    status: profile.status,
                    reviewedAt: profile.reviewedAt,
                    reviewNotes: profile.reviewNotes,
                  ),
                  AppSpacing.gapLg,
                  _BasicInfoSection(profile: profile),
                  AppSpacing.gapLg,
                  _AboutYouSection(profile: profile),
                  AppSpacing.gapLg,
                  _ExperienceSection(profile: profile),
                  AppSpacing.gapLg,
                  _EducationSection(profile: profile),
                  AppSpacing.gapLg,
                  _DocumentsSection(profile: profile),
                  AppSpacing.gapXxxl,
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

/// Shown in place of the sections while there is no profile to render:
/// the first load, a load that failed outright, or a teacher who has none.
class _PlaceholderBody extends StatelessWidget {
  const _PlaceholderBody({
    required this.isLoading,
    required this.hasLoaded,
    required this.onRetry,
    this.errorMessage,
  });

  final bool isLoading;
  final bool hasLoaded;
  final VoidCallback onRetry;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (isLoading || !hasLoaded) {
      return const Center(
        child: SizedBox(
          height: 26,
          width: 26,
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      );
    }

    if (errorMessage != null) {
      return ErrorState(message: errorMessage, onRetry: onRetry);
    }

    return EmptyState(
      title: 'No profile yet',
      message: 'Complete your teacher profile to have it reviewed.',
      icon: AppIcons.profileOutlined,
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }
}

class _BasicInfoSection extends StatelessWidget {
  const _BasicInfoSection({required this.profile});

  final TeacherProfile profile;

  @override
  Widget build(BuildContext context) {
    final basicInfo = profile.basicInfo;
    final dateOfBirth = basicInfo.dateOfBirth;

    return ProfileSectionCard(
      title: 'Basic Information',
      icon: AppIcons.identifier,
      // TODO(profile): open the wizard's basic-info step once editing is wired.
      onEdit: () {},
      children: [
        ProfileDetailRow(
          icon: AppIcons.gender,
          label: 'Gender',
          value: basicInfo.gender?.label,
        ),
        ProfileDetailRow(
          icon: AppIcons.birthday,
          label: 'Date of birth',
          value: dateOfBirth == null
              ? null
              : DateTimeUtils.dayMonthYear(dateOfBirth),
        ),
        ProfileDetailRow(
          icon: AppIcons.address,
          label: 'Address',
          value: profile.formattedAddress,
        ),
        ProfileDetailRow(
          icon: AppIcons.city,
          label: 'City & state',
          value: [
            basicInfo.city,
            basicInfo.state,
          ].where((part) => part.isNotEmpty).join(', '),
        ),
        ProfileDetailRow(
          icon: AppIcons.country,
          label: 'Country',
          value: basicInfo.country,
        ),
        ProfileDetailRow(
          icon: AppIcons.postalCode,
          label: 'Postal code',
          value: basicInfo.postalCode,
        ),
      ],
    );
  }
}

class _AboutYouSection extends StatelessWidget {
  const _AboutYouSection({required this.profile});

  final TeacherProfile profile;

  @override
  Widget build(BuildContext context) {
    final aboutYou = profile.aboutYou;

    return ProfileSectionCard(
      title: 'About You',
      icon: AppIcons.about,
      // TODO(profile): open the wizard's about-you step once editing is wired.
      onEdit: () {},
      children: [
        ProfileTextBlock(label: 'Short bio', text: aboutYou.shortBio),
        ProfileTextBlock(
          label: 'Teaching approach',
          text: aboutYou.teachingApproach,
        ),
        ProfileTextBlock(
          label: 'What makes you unique',
          text: aboutYou.whatMakesYouUnique,
        ),
        ProfileChipWrap(
          label: 'Subjects taught',
          values: aboutYou.subjectsTaught,
        ),
        ProfileChipWrap(
          label: 'Classes taught',
          values: aboutYou.classesTaught,
        ),
        ProfileChipWrap(
          label: 'Languages known',
          values: aboutYou.languagesKnown,
        ),
      ],
    );
  }
}

class _ExperienceSection extends StatelessWidget {
  const _ExperienceSection({required this.profile});

  final TeacherProfile profile;

  @override
  Widget build(BuildContext context) {
    // Subjects are stored once on the about-you row, not per experience, so
    // the meta line borrows them — same as the wizard's draft does.
    final subjects = profile.aboutYou.subjectsTaught.join(', ');

    return ProfileSectionCard(
      title: 'Experience',
      icon: AppIcons.experience,
      count: profile.experiences.length,
      // TODO(profile): open the wizard's experience step once editing is wired.
      onEdit: () {},
      children: [
        if (profile.experiences.isEmpty)
          const _SectionEmptyNote(message: 'No experience added yet.')
        else
          for (final experience in profile.experiences)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: SavedEntryCard(
                icon: AppIcons.experience,
                title: experience.currentJobTitle,
                subtitle: experience.currentInstitution,
                meta: [
                  experience.totalTeachingExperience,
                  if (subjects.isNotEmpty) subjects,
                ].whereType<String>().join(' · '),
                trailingNote: experience.isCurrent ? 'Current' : null,
              ),
            ),
      ],
    );
  }
}

class _EducationSection extends StatelessWidget {
  const _EducationSection({required this.profile});

  final TeacherProfile profile;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'Education',
      icon: AppIcons.education,
      count: profile.educations.length,
      // TODO(profile): open the wizard's education step once editing is wired.
      onEdit: () {},
      children: [
        if (profile.educations.isEmpty)
          const _SectionEmptyNote(message: 'No qualifications added yet.')
        else
          for (final education in profile.educations)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: SavedEntryCard(
                icon: AppIcons.qualification,
                title: education.degree ?? 'Qualification',
                subtitle: [
                  education.specialization,
                  education.universityCollege,
                ].where((part) => part.isNotEmpty).join(' · '),
                meta: [
                  if (education.yearOfPassing != null)
                    'Passed ${education.yearOfPassing}',
                  if (education.marksOrGrade.isNotEmpty) education.marksOrGrade,
                ].join(' · '),
                trailingNote: education.isHighestQualification
                    ? 'Highest'
                    : null,
              ),
            ),
      ],
    );
  }
}

class _DocumentsSection extends StatelessWidget {
  const _DocumentsSection({required this.profile});

  final TeacherProfile profile;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'Documents',
      icon: AppIcons.documents,
      count: profile.documents.length,
      // TODO(profile): open the wizard's documents step once editing is wired.
      onEdit: () {},
      children: [
        if (profile.documents.isEmpty)
          const _SectionEmptyNote(message: 'No documents uploaded yet.')
        else
          for (final document in profile.documents)
            ProfileDocumentTile(document: document),
      ],
    );
  }
}

class _SectionEmptyNote extends StatelessWidget {
  const _SectionEmptyNote({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      message,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
