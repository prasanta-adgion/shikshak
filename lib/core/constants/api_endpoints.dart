/// REST endpoint definitions.
///
/// These are placeholder endpoints — swap [baseUrl] with the production
/// gateway once the backend is live. Paths are kept relative so the base URL
/// can vary per flavor (dev / staging / prod).
abstract final class ApiEndpoints {
  static const String baseUrl = 'https://api.Shikshak.app/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/auth/me';
  static const String refreshToken = '/auth/refresh';
}
