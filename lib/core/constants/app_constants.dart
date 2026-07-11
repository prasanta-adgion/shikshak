/// Application-wide constants.
abstract final class AppConstants {
  static const String appName = 'Shiksha';
  static const String tagline = 'Find the Right Teacher. Learn Without Limits.';
  static const String appVersion = '1.0.0';

  /// Minimum time the splash screen stays visible, so the intro animation
  /// always completes even when the session check resolves instantly.
  static const Duration splashMinDuration = Duration(milliseconds: 2600);

  /// Simulated latency used by mock data sources.
  static const Duration mockNetworkDelay = Duration(milliseconds: 900);
}
