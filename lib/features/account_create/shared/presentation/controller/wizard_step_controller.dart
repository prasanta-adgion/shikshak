import 'package:flutter/widgets.dart';

class WizardStepController {
  VoidCallback? _submit;

  void register(VoidCallback submit) => _submit = submit;

  /// Identity-checked: during a transition the outgoing step disposes *after*
  /// the incoming one has registered, and must not clear its handler.
  void unregister(VoidCallback submit) {
    if (identical(_submit, submit)) _submit = null;
  }

  /// Runs the current step's submit, if one is registered.
  void submit() => _submit?.call();
}
