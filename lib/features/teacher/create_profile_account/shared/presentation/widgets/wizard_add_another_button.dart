import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../shared/widgets/app_outlined_button.dart';
import '../providers/account_create_providers.dart';

class WizardAddAnotherButton extends ConsumerWidget {
  const WizardAddAnotherButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubmitting = ref.watch(
      accountCreateNotifierProvider.select((state) => state.isSubmitting),
    );

    return AppOutlinedButton(
      label: label,
      icon: Icons.add_rounded,
      onPressed: isSubmitting ? null : onPressed,
    );
  }
}
