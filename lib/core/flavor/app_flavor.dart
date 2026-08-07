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
        return 'http://192.168.1.14:5001/';
      case AppFlavor.staging:
        return 'https://backend.shiksak.in/';
      case AppFlavor.prod:
        return 'https://backend.shiksak.in/';
    }
  }

  /// False until the host for this environment exists.
  bool get hasBaseUrl => baseUrl.isNotEmpty;

  /// Whether requests are recorded — console logs and the in-app inspector
  /// alike. Never in production.
  bool get enableNetworkLogging => this != AppFlavor.prod;

  /// Whether the session token restored at splash is printed to the console.
  /// Deliberately an allowlist, not `!= prod`: a flavor added later stays
  /// silent until someone opts it in here.
  bool get logRestoredToken => switch (this) {
    AppFlavor.dev || AppFlavor.staging => true,
    AppFlavor.prod => false,
  };
}

class AppFlavorConfig {
  AppFlavorConfig._();

  static AppFlavor _flavor = AppFlavor.prod;

  static AppFlavor get current => _flavor;

  static bool get isProd => _flavor == AppFlavor.prod;

  static String get baseUrl => _flavor.baseUrl;

  static bool get enableNetworkLogging => _flavor.enableNetworkLogging;

  static bool get logRestoredToken => _flavor.logRestoredToken;

  static void set(AppFlavor flavor) {
    _flavor = flavor;
  }
}
