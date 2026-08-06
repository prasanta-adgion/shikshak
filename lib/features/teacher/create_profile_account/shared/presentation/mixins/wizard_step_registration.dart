import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/wizard_step_controller.dart';
import '../providers/account_create_providers.dart';

mixin WizardStepRegistration<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  late final WizardStepController _controller;

  /// Held as a field so register and unregister compare the same object.
  late final void Function() _submit;

  /// Validate, save this step's section, then advance.
  void submitStep();

  @override
  void initState() {
    super.initState();
    _submit = submitStep;
    _controller = ref.read(wizardStepControllerProvider);
    _controller.register(_submit);
  }

  @override
  void dispose() {
    _controller.unregister(_submit);
    super.dispose();
  }
}
