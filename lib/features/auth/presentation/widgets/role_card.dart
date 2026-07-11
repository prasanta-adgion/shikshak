import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/user_role.dart';

/// Large selectable card on the role-selection screen.
///
/// The whole card (and its button) trigger [onSelected]; a press-down scale
/// gives tactile feedback.
class RoleCard extends StatefulWidget {
  const RoleCard({
    super.key,
    required this.role,
    required this.icon,
    required this.subtitle,
    required this.gradient,
    required this.onSelected,
  });

  final UserRole role;
  final IconData icon;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onSelected;

  @override
  State<RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<RoleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AppCard(
          onTap: widget.onSelected,
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Illustration: gradient tile with the role icon.
              Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  gradient: widget.gradient,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadius.lg),
                  ),
                ),
                child: Icon(widget.icon, color: Colors.white, size: 36),
              ),
              AppSpacing.gapXl,
              Text(widget.role.label, style: theme.textTheme.headlineSmall),
              AppSpacing.gapSm,
              Text(
                widget.subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              AppSpacing.gapXl,
              AppButton(
                label: 'Continue as ${widget.role.label}',
                onPressed: widget.onSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
