import 'dart:ui';

import 'package:Shikshak/core/theme/app_colors.dart';
import 'package:Shikshak/core/utils/responsive.dart';
import 'package:Shikshak/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_images_const.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/user_role.dart';
import 'select_role_card.dart';

Future<UserRole?> showRoleCheckDialog(
  BuildContext context, {
  UserRole initialRole = UserRole.student,
}) {
  return showDialog<UserRole>(
    context: context,
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: RoleCheckDialog(initialRole: initialRole),
    ),
  );
}

class RoleCheckDialog extends StatefulWidget {
  const RoleCheckDialog({super.key, this.initialRole = UserRole.student});

  final UserRole initialRole;

  @override
  State<RoleCheckDialog> createState() => _RoleCheckDialogState();
}

class _RoleCheckDialogState extends State<RoleCheckDialog> {
  late UserRole _role = widget.initialRole;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: context.isTablet
          ? const EdgeInsets.all(100)
          : const EdgeInsets.all(20),
      backgroundColor: AppColors.lightBackground,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: EdgeInsets.all(
          context.isTablet ? AppSpacing.huge : AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Register as?',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            AppSpacing.gapXs,
            Text(
              'Choose the role you want to register with',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            AppSpacing.gapXl,
            Row(
              children: [
                Expanded(
                  child: SelectRoleCard(
                    role: UserRole.student,
                    image: AppImagesConst.studentIcon,
                    selected: _role == UserRole.student,
                    onSelected: () => setState(() => _role = UserRole.student),
                  ),
                ),
                AppSpacing.hGapLg,
                Expanded(
                  child: SelectRoleCard(
                    role: UserRole.teacher,
                    image: AppImagesConst.teacherIcon,
                    selected: _role == UserRole.teacher,
                    onSelected: () => setState(() => _role = UserRole.teacher),
                  ),
                ),
              ],
            ),
            AppSpacing.gapXl,

            AppButton(
              label: 'Continue with ${_role.label}',
              onPressed: () {
                context.pop(_role);
              },
            ),
            AppSpacing.gapSm,
            AppButton(
              label: 'Cancel',
              labelColor: theme.colorScheme.primary,
              onPressed: () {
                context.pop();
              },
              color: Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
