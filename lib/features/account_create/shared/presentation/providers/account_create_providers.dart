import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/wizard_step_controller.dart';
import '../notifier/account_create_notifier.dart';
import '../state/account_create_state.dart';

/// Composition root for the teacher profile wizard.
///
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
