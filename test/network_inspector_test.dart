import 'package:Shikshak/core/flavor/app_flavor.dart';
import 'package:Shikshak/core/network/network_inspector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_logger/network_logger.dart';

/// Pumps a page that attaches the inspector from its own context — the same
/// position `SplashPage` calls it from.
Future<void> pumpPageThatAttaches(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => NetworkInspector.attach(context),
          );
          return const Scaffold(body: SizedBox.shrink());
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => AppFlavorConfig.set(AppFlavor.dev));

  tearDown(() {
    NetworkInspector.detach();
    AppFlavorConfig.set(AppFlavor.prod);
  });

  testWidgets('attaches from a page context', (tester) async {
    await pumpPageThatAttaches(tester);

    // A context inside the navigator resolves the overlay; the navigator's
    // own context would not, since the overlay is its descendant.
    expect(find.byType(NetworkLoggerButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('attaches only once', (tester) async {
    await pumpPageThatAttaches(tester);
    NetworkInspector.attach(tester.element(find.byType(NetworkLoggerButton)));
    await tester.pumpAndSettle();

    expect(find.byType(NetworkLoggerButton), findsOneWidget);
  });

  testWidgets('stays off in production', (tester) async {
    AppFlavorConfig.set(AppFlavor.prod);
    await pumpPageThatAttaches(tester);

    expect(find.byType(NetworkLoggerButton), findsNothing);
  });
}
