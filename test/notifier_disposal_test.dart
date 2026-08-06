import 'package:Shikshak/core/network/i_api_client.dart';
import 'package:Shikshak/core/providers/core_providers.dart';
import 'package:Shikshak/features/teacher/create_profile_account/about_you/presentation/providers/about_you_providers.dart';
import 'package:Shikshak/features/teacher/create_profile_account/basic_info/presentation/providers/basic_info_providers.dart';
import 'package:Shikshak/features/teacher/create_profile_account/documents/presentation/providers/document_providers.dart';
import 'package:Shikshak/features/teacher/create_profile_account/education/presentation/providers/education_providers.dart';
import 'package:Shikshak/features/teacher/create_profile_account/experience/presentation/providers/experience_providers.dart';
import 'package:Shikshak/features/teacher/profile/presentation/providers/teacher_profile_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers after a delay, so a request can still be in flight when the
/// provider that started it is disposed.
class _SlowApiClient implements IApiClient {
  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    return {
          'success': true,
          'code': 200,
          'data': {'items': <dynamic>[]},
        }
        as T;
  }

  @override
  Future<T> post<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, Map<String, dynamic>? headers}) =>
      throw UnimplementedError();

  @override
  Future<T> put<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, Map<String, dynamic>? headers}) =>
      throw UnimplementedError();

  @override
  Future<T> patch<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, Map<String, dynamic>? headers}) =>
      throw UnimplementedError();

  @override
  Future<T> delete<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, Map<String, dynamic>? headers}) =>
      throw UnimplementedError();
}

void main() {
  // Closing a screen mid-request auto-disposes the notifier that started it.
  // Writing state after that throws UnmountedRefException, which surfaced as a
  // crash when the profile screen began pushing and popping the wizard.
  group('a load that lands after disposal', () {
    final loads = <String, Future<void> Function(ProviderContainer)>{
      'BasicInfoNotifier': (c) =>
          c.read(basicInfoNotifierProvider.notifier).load(),
      'AboutYouNotifier': (c) =>
          c.read(aboutYouNotifierProvider.notifier).load(),
      'ExperienceListNotifier': (c) =>
          c.read(experienceListNotifierProvider.notifier).load(),
      'EducationListNotifier': (c) =>
          c.read(educationListNotifierProvider.notifier).load(),
      'DocumentListNotifier': (c) =>
          c.read(documentListNotifierProvider.notifier).load(),
      'TeacherProfileNotifier': (c) =>
          c.read(teacherProfileNotifierProvider.notifier).load(),
    };

    for (final MapEntry(key: name, value: load) in loads.entries) {
      test('$name completes quietly', () async {
        final container = ProviderContainer(
          overrides: [apiClientProvider.overrideWithValue(_SlowApiClient())],
        );

        final pending = load(container);
        container.dispose();

        await expectLater(pending, completes);
      });
    }
  });
}
