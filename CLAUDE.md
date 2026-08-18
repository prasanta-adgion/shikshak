# Shikshak

Flutter app serving two roles from one binary: **teacher** and **student**. Riverpod 3 for state and
DI, go_router for navigation, Dio for networking. No code generation.

## Where code goes

```
lib/
  app/          MaterialApp, GoRouter, route paths and page transitions
  core/         cross-role plumbing: network, storage, theme, media, flavors, utils
  shared/       cross-role UI widgets (AppButton, AppCard, AppTextField, ...)
  features/
    <name>/                     role-agnostic features: auth, forgot_password, splash
    teacher/<sub_feature>/      screens only a teacher sees
    student/<sub_feature>/      screens only a student sees
```

The role split is the first thing to decide for a new screen. If only one role can reach it, it
belongs under `features/teacher/` or `features/student/` — not at the top level of `features/`.
Widgets shared by both roles go in `lib/shared/widgets/`; anything non-visual shared by both goes in
`lib/core/`.

## Feature layering

Every feature (and every sub-feature of a role folder) uses the same three layers:

```
<feature>/
  data/
    datasource/    <X>RemoteDataSource + Impl, takes IApiClient
    model/         JSON DTOs: fromJson + toEntity()
    repository/    <X>RepositoryImpl implements <X>Repository, returns ApiResult<T>
  domain/
    entities/      pure Dart, no Flutter imports
    params/        input value objects
    repositories/  abstract contracts
    usecases/      callable classes with call()
  presentation/
    pages/         screens
    widgets/       widgets private to this feature
    notifier/      Riverpod Notifier subclasses
    state/         immutable state classes with copyWith
    providers/     the composition root — the only file that names concrete classes
    controller/    plain (non-Riverpod) form controllers, where a section repeats
```

A UI-only feature may ship `presentation/` alone and add `data/` + `domain/` when the endpoint
lands. Do not create empty layer folders in advance.

**Naming.** Two inconsistencies exist in older code — new code picks the first of each:
`presentation/providers/` (not `providers_di/`) and `presentation/pages/` (not `screens/`).

## Conventions

- **Imports inside `lib/` are relative.** Tests import via `package:Shikshak/...`. Keep directive
  sections sorted — `directives_ordering` is on.
- **State**: `ConsumerStatefulWidget` for pages, `ConsumerWidget` for read-only widgets. Scope
  rebuilds with `ref.watch(provider.select((s) => s.field))`. Local form state uses `ValueNotifier` +
  `ListenableBuilder`, not `setState`, so one field repaints instead of the whole form.
- **Errors**: repositories return `ApiResult<T>`; callers use `fold(onSuccess:, onFailure:)`. Surface
  failures with `ref.listen` → `AppSnackbar.showError`.
- **Theme**: never hardcode a `Color`, size, or radius. Read from
  `Theme.of(context).colorScheme` / `.textTheme`, `AppSpacing`, `AppRadius`, `AppShadows`,
  `AppIcons`. `AppColors` is for gradients and the semantic `success`/`warning` only. There is no
  `AppTextStyles` class.
- **Responsive**: everything comes from `lib/core/responsive/` — import the barrel,
  `core/responsive/responsive.dart`. Wrap scroll pages in `CenteredConstrainedBox` and pad with
  `context.responsivePagePadding`. Two axes, kept apart on purpose:
  - **Device form factor** — `context.isTabletDevice`, off the window's *shortest side*, so it
    survives rotation. Use it for structural choices that shouldn't flip when a phone turns
    sideways: nav rail vs bottom bar, two-pane vs stacked auth, base component sizing.
  - **Layout size** — compact (`<600`) / medium (`600–839`) / expanded (`≥840`). Use it for
    choices that *should* react to available space: column counts, gutters, whether a pair fits
    on one row. `context.isCompact`/`isMedium`/`isExpanded` reads the window, for page-level
    decisions; `ResponsiveBuilder` resolves the same enum from the constraints a widget is
    actually given, for decisions inside a page.

  Never swap one axis for the other — `isExpanded` is true on a landscape phone, `isTabletDevice`
  is not.
- **Dates**: `DateTimeUtils` in `lib/core/utils/date_time_picker_func.dart`. The project has no
  `intl` dependency — formatting is hand-rolled there.

## Commands

```bash
flutter analyze
```

```bash
flutter test
```

```bash
flutter run -t lib/main_dev.dart
```

`test/responsive_screens_test.dart` renders every top-level screen at five sizes plus dark mode and
fails on overflow. Add new screens to its table.
