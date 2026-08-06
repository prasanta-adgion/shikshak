import 'package:Shikshak/core/theme/app_theme.dart';
import 'package:Shikshak/features/teacher/create_profile_account/education/data/model/education_response_model.dart';
import 'package:Shikshak/features/teacher/create_profile_account/education/presentation/notifier/education_list_notifier.dart';
import 'package:Shikshak/features/teacher/create_profile_account/education/presentation/providers/education_providers.dart';
import 'package:Shikshak/features/teacher/create_profile_account/education/presentation/state/education_list_state.dart';
import 'package:Shikshak/features/teacher/create_profile_account/education/presentation/widgets/education_display_screen.dart';
import 'package:Shikshak/features/teacher/create_profile_account/education/presentation/widgets/education_edit_sheet.dart';
import 'package:Shikshak/features/teacher/create_profile_account/shared/domain/entities/profile_step.dart';
import 'package:Shikshak/features/teacher/create_profile_account/shared/presentation/notifier/account_create_notifier.dart';
import 'package:Shikshak/features/teacher/create_profile_account/shared/presentation/pages/create_teacher_account_page.dart';
import 'package:Shikshak/features/teacher/create_profile_account/shared/presentation/providers/account_create_providers.dart';
import 'package:Shikshak/features/teacher/create_profile_account/shared/presentation/state/account_create_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A row as the education endpoint returns it.
const _bsc = EducationItem(
  id: 'ad1d8d55-4e09-4ca0-bbb5-5f1bedd07cc3',
  degree: 'Bachelor of Science',
  specialization: 'Mathematics',
  universityCollege: 'University of Delhi',
  yearOfPassing: 2014,
  marksOrGrade: 'A',
  certificateUrl: 'https://example.com/cert.pdf',
  isHighestQualification: true,
);

const _diploma = EducationItem(
  id: '7c1f0a94-2f2c-4f0e-9a52-7f6b1a3d5e88',
  degree: 'Diploma',
  specialization: 'Education',
  universityCollege: 'Sunrise Institute',
  yearOfPassing: 2010,
  marksOrGrade: 'B',
  isHighestQualification: false,
);

/// Seeds the list the server would have returned, and never calls the API.
class _SeededEducationList extends EducationListNotifier {
  @override
  EducationListState build() =>
      const EducationListState(items: [_bsc, _diploma]);

  @override
  Future<void> load() async {}
}

class _NotifierAtEducation extends AccountCreateNotifier {
  @override
  AccountCreateState build() =>
      const AccountCreateState(step: ProfileStep.education);
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
          accountCreateNotifierProvider.overrideWith(_NotifierAtEducation.new),
          educationListNotifierProvider.overrideWith(_SeededEducationList.new),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const CreateTeacherAccountPage(),
        ),
      ),
    );
    await tester.pump();
  }

  Finder cardFor(EducationItem item) => find.byWidgetPredicate(
    (widget) => widget is SavedEducationCard && widget.item.id == item.id,
  );

  Finder editIn(EducationItem item) =>
      find.descendant(of: cardFor(item), matching: find.text('Edit'));

  testWidgets('lists what the server returned, each row with an Edit button', (
    tester,
  ) async {
    await pumpStep(tester);

    expect(find.text('Education added (2)'), findsOneWidget);
    expect(find.text('Bachelor of Science · Mathematics'), findsOneWidget);
    expect(find.text('University of Delhi · 2014'), findsOneWidget);
    expect(find.text('Grade A · Highest qualification'), findsOneWidget);

    expect(find.text('Diploma · Education'), findsOneWidget);
    expect(find.text('Sunrise Institute · 2010'), findsOneWidget);
    expect(find.text('Grade B'), findsOneWidget);

    // The Edit button replaced the "Highest" annotation.
    expect(find.text('Edit'), findsNWidgets(2));
    expect(find.text('Highest'), findsNothing);
  });

  testWidgets('Edit opens a sheet on that row\'s stored values', (
    tester,
  ) async {
    await pumpStep(tester);

    expect(find.text('Update Education'), findsNothing);

    await tester.tap(editIn(_bsc));
    await tester.pumpAndSettle();

    expect(find.byType(EducationEditSheet), findsOneWidget);
    expect(find.text('Update Education'), findsOneWidget);
    expect(find.text('Bachelor of Science'), findsOneWidget);
    expect(find.text('University of Delhi'), findsOneWidget);
    // The stored certificate is named after the file its URL points at.
    expect(find.text('cert.pdf'), findsOneWidget);
  });

  testWidgets('Close dismisses the sheet', (tester) async {
    await pumpStep(tester);

    await tester.tap(editIn(_bsc));
    await tester.pumpAndSettle();
    expect(find.byType(EducationEditSheet), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(find.byType(EducationEditSheet), findsNothing);
    expect(find.text('Update Education'), findsNothing);
  });
}
