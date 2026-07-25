enum AppFlavor {
  dev,
  staging,
  prod;

  String get label {
    switch (this) {
      case AppFlavor.dev:
        return 'Dev';
      case AppFlavor.staging:
        return 'Staging';
      case AppFlavor.prod:
        return 'Prod';
    }
  }

  String get baseUrl {
    switch (this) {
      case AppFlavor.dev:
        return 'http://192.168.1.12:5001';
      case AppFlavor.staging:
        return '';
      case AppFlavor.prod:
        return '';
    }
  }

  /// False until the host for this environment exists.
  bool get hasBaseUrl => baseUrl.isNotEmpty;
}

class AppFlavorConfig {
  AppFlavorConfig._();

  static AppFlavor _flavor = AppFlavor.prod;

  static AppFlavor get current => _flavor;

  static bool get isProd => _flavor == AppFlavor.prod;

  static String get baseUrl => _flavor.baseUrl;

  static bool get enableNetworkLogging => !isProd;

  static void set(AppFlavor flavor) {
    _flavor = flavor;
  }
}
