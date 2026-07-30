import 'package:flutter/widgets.dart';
import 'package:network_logger/network_logger.dart';

import '../flavor/app_flavor.dart';

abstract final class NetworkInspector {
  static OverlayEntry? _entry;

  static void attach(BuildContext context) {
    if (!AppFlavorConfig.enableNetworkLogging || _entry != null) return;

    _entry = NetworkLoggerOverlay.attachTo(context);
  }

  /// Removes the button. Only needed by tests.
  static void detach() {
    final entry = _entry;
    _entry = null;
    // Guarded: by teardown the overlay it lived in may already be gone.
    if (entry != null && entry.mounted) entry.remove();
  }
}
