import 'package:Shikshak/core/theme/app_theme.dart';
import 'package:Shikshak/features/account_create/experience/data/model/experience_response_model.dart';
import 'package:Shikshak/features/account_create/experience/presentation/notifier/experience_list_notifier.dart';
import 'package:Shikshak/features/account_create/experience/presentation/providers/experience_providers.dart';
import 'package:Shikshak/features/account_create/experience/presentation/state/experience_list_state.dart';
import 'package:Shikshak/features/account_create/experience/presentation/widgets/experience_display_screen.dart';
import 'package:Shikshak/features/account_create/experience/presentation/widgets/experience_edit_sheet.dart';
import 'package:Shikshak/features/account_create/shared/domain/entities/profile_step.dart';
import 'package:Shikshak/features/account_create/shared/presentation/notifier/account_create_notifier.dart';
import 'package:Shikshak/features/account_create/shared/presentation/pages/create_teacher_account_page.dart';
import 'package:Shikshak/features/account_create/shared/presentation/providers/account_create_providers.dart';
import 'package:Shikshak/features/account_create/shared/presentation/state/account_create_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Two rows as the experience endpoint returns them.
const _first = ExperienceItem(
  id: '716bf579-5adb-449b-89e9-eccfa7938b7a',
  teachingSubjects: ['Mathematics', 'Geometry'],
  classesTaught: ['Class 7', 'Class 5'],
  totalTeachingExperience: '3-5 years',
  currentJobTitle: 'Senior Mathematics Teacher',
  currentInstitution: 'Delhi Public School',
  experienceDetails: 'Algebra and geometry for middle school.',
  isCurrent: true,
  startDate: '2026-07-30T00:00:00.000Z',
);

const _second = ExperienceItem(
  id: '0cc60a67-db79-4116-857a-ce29760e62d8',
  teachingSubjects: ['Mathematics'],
  classesTaught: ['Class 5'],
  totalTeachingExperience: '1-3 years',
  currentJobTitle: 'Mathematics Tutor',
  currentInstitution: 'Sunrise Academy',
  experienceDetails: 'Evening batches.',
  isCurrent: false,
  startDate: '2022-04-01T00:00:00.000Z',
  endDate: '2024-03-01T00:00:00.000Z',
);

/// Seeds the list the server would have returned, and never calls the API.
class _SeededExperienceList extends ExperienceListNotifier {
  @override
  ExperienceListState build() =>
      const ExperienceListState(items: [_first, _second]);

  @override
  Future<void> load() async {}
}

class _NotifierAtExperience extends AccountCreateNotifier {
  @override
  AccountCreateState build() =>
      const AccountCreateState(step: ProfileStep.experience);
}

void main() {
  Future<void> pumpStep(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountCreateNotifierProvider.overrideWith(_NotifierAtExperience.new),
          experienceListNotifierProvider.overrideWith(
            _SeededExperienceList.new,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const CreateTeacherAccountPage(),
        ),
      ),
    );
    await tester.pump();
  }

  Finder cardFor(ExperienceItem item) => find.byWidgetPredicate(
    (widget) => widget is SavedExperienceCard && widget.item.id == item.id,
  );

  Finder editIn(ExperienceItem item) =>
      find.descendant(of: cardFor(item), matching: find.text('Edit'));

  testWidgets('lists what the server returned, each row with an Edit button', (
    tester,
  ) async {
    await pumpStep(tester);

    expect(find.text('Experience added (2)'), findsOneWidget);
    expect(find.text('Senior Mathematics Teacher'), findsOneWidget);
    expect(find.text('Delhi Public School'), findsOneWidget);
    expect(find.text('Mathematics Tutor'), findsOneWidget);
    expect(find.text('Sunrise Academy'), findsOneWidget);

    // Dates and the total ride along under the institution.
    expect(find.text('3-5 years · Jul 2026 – Present'), findsOneWidget);
    expect(find.text('1-3 years · Apr 2022 – Mar 2024'), findsOneWidget);

    // The Edit button replaced the "Current" annotation.
    expect(find.text('Edit'), findsNWidgets(2));
    expect(find.text('Current'), findsNothing);
  });

  testWidgets('Edit opens a sheet on that row\'s stored values', (
    tester,
  ) async {
    await pumpStep(tester);

    expect(find.text('Update Experience'), findsNothing);

    await tester.tap(editIn(_first));
    await tester.pumpAndSettle();

    expect(find.byType(ExperienceEditSheet), findsOneWidget);
    expect(find.text('Update Experience'), findsOneWidget);
    expect(
      find.text('Algebra and geometry for middle school.'),
      findsOneWidget,
    );
    expect(find.text('Evening batches.'), findsNothing);
  });

  testWidgets('each row opens its own sheet', (tester) async {
    await pumpStep(tester);

    await tester.tap(editIn(_first));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(editIn(_second));
    await tester.pumpAndSettle();
    await tester.tap(editIn(_second));
    await tester.pumpAndSettle();

    expect(find.byType(ExperienceEditSheet), findsOneWidget);
    expect(find.text('Evening batches.'), findsOneWidget);
    expect(find.text('Algebra and geometry for middle school.'), findsNothing);
  });

  testWidgets('Close dismisses the sheet', (tester) async {
    await pumpStep(tester);

    await tester.tap(editIn(_first));
    await tester.pumpAndSettle();
    expect(find.byType(ExperienceEditSheet), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(find.byType(ExperienceEditSheet), findsNothing);
    expect(find.text('Update Experience'), findsNothing);
  });
}
