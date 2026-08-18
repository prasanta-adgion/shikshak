import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/date_time_picker_func.dart';
import '../../../../../shared/widgets/app_snackbar.dart';
import '../../../../../shared/widgets/empty_state.dart';
import '../../../../../shared/widgets/error_state.dart';
import '../../../../auth/presentation/widgets/logout_button.dart';
import '../../domain/entities/student_profile.dart';
import '../providers/student_profile_providers.dart';
import '../widgets/notification_prefs_wrap.dart';
import '../widgets/profile_completion_card.dart';
import '../widgets/profile_info_row.dart';
import '../widgets/profile_section_card.dart';
import '../widgets/social_links_wrap.dart';
import '../widgets/student_profile_header.dart';

/// Read-only view of the signed-in student's profile.
///
/// One scrolling column rather than the teacher screen's tab strip: a student
/// has a handful of details, and hiding four of five sections behind tabs
/// would cost a tap to reveal two lines of text.
class StudentProfilePage extends ConsumerStatefulWidget {
  const StudentProfilePage({super.key});

  @override
  ConsumerState<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends ConsumerState<StudentProfilePage> {
  @override
  void initState() {
    super.initState();
    // Deferred: the notifier writes state, which cannot happen during build.
    Future.microtask(
      () => ref.read(studentProfileNotifierProvider.notifier).load(),
    );
  }

  Future<void> _refresh() =>
      ref.read(studentProfileNotifierProvider.notifier).refresh();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(studentProfileNotifierProvider);
    final profile = state.profile;

    ref.listen(studentProfileNotifierProvider, (previous, next) {
      final error = next.error;
      // Only when there is still a profile on screen — otherwise the body
      // itself carries the error, and a snackbar would say it twice.
      if (error != null && next.profile != null && previous?.error != error) {
        AppSnackbar.showError(context, error.message);
      }
    });

    return CenteredConstrainedBox(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
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
                  onRetry: _refresh,
                ),
              )
            else
              SliverPadding(
                padding: context.responsivePagePadding,
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    AppSpacing.gapSm,
                    StudentProfileHeader(profile: profile),
                    AppSpacing.gapLg,
                    ProfileCompletionCard(profile: profile),
                    AppSpacing.gapLg,
                    _AboutSection(profile: profile),
                    AppSpacing.gapLg,
                    _PersonalSection(profile: profile),
                    AppSpacing.gapLg,
                    _ContactSection(profile: profile),
                    AppSpacing.gapLg,
                    _NotificationsSection(profile: profile),
                    AppSpacing.gapLg,
                    _SocialSection(profile: profile),
                    AppSpacing.gapLg,
                    _AccountSection(profile: profile),
                    AppSpacing.gapXxxl,
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Shown in place of the sections while there is no profile to render: the
/// first load, a load that failed outright, or a student who has none.
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
      message: 'Add your details so teachers know who they are teaching.',
      icon: AppIcons.profileOutlined,
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.profile});

  final StudentProfile profile;

  @override
  Widget build(BuildContext context) {
    final bio = profile.bio;

    return ProfileSectionCard(
      title: 'About',
      icon: AppIcons.about,
      children: [
        if (bio == null || bio.trim().isEmpty)
          const _SectionEmptyNote(
            message: 'No bio yet. A line or two helps teachers place you.',
          )
        else
          ProfileTextBlock(text: bio),
      ],
    );
  }
}

class _PersonalSection extends StatelessWidget {
  const _PersonalSection({required this.profile});

  final StudentProfile profile;

  @override
  Widget build(BuildContext context) {
    final dateOfBirth = profile.dateOfBirth;
    final age = profile.age;

    return ProfileSectionCard(
      title: 'Personal Details',
      icon: AppIcons.identifier,
      children: [
        ProfileInfoRow(
          icon: AppIcons.gender,
          label: 'Gender',
          value: profile.genderLabel,
        ),
        ProfileInfoRow(
          icon: AppIcons.birthday,
          label: 'Date of birth',
          value: dateOfBirth == null
              ? null
              : [
                  DateTimeUtils.dayMonthYear(dateOfBirth),
                  if (age != null) '$age yrs',
                ].join(' · '),
        ),
        ProfileInfoRow(
          icon: AppIcons.language,
          label: 'Preferred language',
          value: profile.languageLabel,
        ),
      ],
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.profile});

  final StudentProfile profile;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'Contact',
      icon: AppIcons.email,
      children: [
        ProfileInfoRow(
          icon: AppIcons.email,
          label: 'Email',
          value: profile.user.email,
          trailing: _VerificationPill(isVerified: profile.isEmailVerified),
        ),
        ProfileInfoRow(
          icon: AppIcons.phone,
          label: 'Phone number',
          value: profile.phoneNumber,
        ),
        ProfileInfoRow(
          icon: AppIcons.phone,
          label: 'Alternate phone',
          value: profile.altPhoneNumber,
        ),
      ],
    );
  }
}

class _NotificationsSection extends StatelessWidget {
  const _NotificationsSection({required this.profile});

  final StudentProfile profile;

  @override
  Widget build(BuildContext context) {
    final preferences = profile.notificationPrefs;

    return ProfileSectionCard(
      title: 'Notifications',
      icon: AppIcons.notifications,
      children: [
        if (preferences.isEmpty)
          const _SectionEmptyNote(
            message:
                'Using the default alerts — class reminders and booking '
                'updates.',
          )
        else
          NotificationPrefsWrap(preferences: preferences),
      ],
    );
  }
}

class _SocialSection extends StatelessWidget {
  const _SocialSection({required this.profile});

  final StudentProfile profile;

  @override
  Widget build(BuildContext context) {
    final links = profile.socialLinks;

    return ProfileSectionCard(
      title: 'Social Links',
      icon: AppIcons.link,
      count: links.isEmpty ? null : links.length,
      children: [
        if (links.isEmpty)
          const _SectionEmptyNote(message: 'No links added yet.')
        else
          SocialLinksWrap(links: links),
      ],
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({required this.profile});

  final StudentProfile profile;

  @override
  Widget build(BuildContext context) {
    final joinedAt = profile.joinedAt;
    final lastSeenAt = profile.lastSeenAt;

    return ProfileSectionCard(
      title: 'Account',
      icon: AppIcons.account,
      children: [
        ProfileInfoRow(
          icon: AppIcons.joined,
          label: 'Member since',
          value: joinedAt == null ? null : DateTimeUtils.dayMonthYear(joinedAt),
        ),
        ProfileInfoRow(
          icon: AppIcons.lastSeen,
          label: 'Last active',
          value: lastSeenAt == null
              ? null
              : DateTimeUtils.dayMonthYear(lastSeenAt),
        ),
      ],
    );
  }
}

/// Green when the address has been confirmed, amber while it has not.
class _VerificationPill extends StatelessWidget {
  const _VerificationPill({required this.isVerified});

  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = isVerified ? AppColors.success : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: AppRadius.chip,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? AppIcons.verified : AppIcons.unverified,
            size: 12,
            color: accent,
          ),
          AppSpacing.hGapXs,
          Text(
            isVerified ? 'Verified' : 'Unverified',
            style: theme.textTheme.labelSmall?.copyWith(color: accent),
          ),
        ],
      ),
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
