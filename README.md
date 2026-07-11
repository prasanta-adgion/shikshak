# Shiksha

**Find the Right Teacher. Learn Without Limits.**

A production-grade Flutter home-tutoring app connecting students with teachers. Built with feature-first Clean Architecture, Riverpod, GoRouter, Dio, and Material 3.

## Getting Started

```bash
flutter pub get
dart run build_runner build   # generates freezed / json_serializable code
flutter run
```

> The backend does not exist yet: authentication runs against a **mock data source** (`MockAuthRemoteDataSource`) with realistic latency. Any well-formed credentials log you in. Swap in `AuthRemoteDataSourceImpl` inside `auth_providers.dart` when the API is live — no other file changes.

## App Flow

```
Splash ─▶ session check (secure storage)
   ├─ token found ─▶ fetch profile ─▶ Student / Teacher Dashboard (by role)
   └─ no token ────▶ Role Selection ─▶ Login (role-aware) ─▶ Registration (role-aware)
```

Navigation uses plain GoRouter (`AppRouter.router` — a static configuration with no state-management coupling). Auth-driven transitions are explicit: splash navigates when the session check resolves, login/register navigate on success, and logout returns to role selection. The `/login/:role` and `/register/:role` routes validate their role parameter and redirect to role selection when it is invalid.

## Architecture

Feature-first Clean Architecture. Each feature owns three layers:

```
lib/
├── app/                    # Root widget + routing (paths, transitions, guard)
├── core/                   # Cross-cutting infrastructure
│   ├── constants/          #   App constants, API endpoints
│   ├── network/            #   IApiClient, DioClient, interceptors, ApiResult/ApiException
│   ├── providers/          #   Core Riverpod providers (storage, api client)
│   ├── storage/            #   SecureStorageService + StorageKeys
│   ├── theme/              #   AppColors, AppTypography, AppSpacing, AppRadius,
│   │                       #   AppShadows, AppIcons, AppTheme (Material 3, light + dark)
│   └── utils/              #   Validators, responsive helpers
├── shared/widgets/         # Design-system widgets (AppButton, AppTextField, AppCard, …)
└── features/
    ├── splash/             # presentation
    ├── auth/               # presentation / domain / data (role selection, login, register)
    ├── student/            # presentation (dashboard)
    └── teacher/            # presentation (dashboard)
```

Dependency rule: `presentation → domain ← data`. Repositories are interfaces in the domain layer; the data layer implements them. All wiring happens in provider files (composition roots), so every class depends on abstractions (SOLID/DIP).

### State management

Riverpod `Notifier` (`AuthNotifier` + immutable freezed `AuthState`). Widgets never contain business logic — they call notifier methods and render state. Errors surface through `state.errorMessage` (shown as snackbars via `ref.listen`).

### Networking

`IApiClient` abstraction over Dio with auth + logging interceptors, a typed `ApiException` taxonomy, and a sealed `ApiResult<T>` returned by repositories so failures are handled exhaustively.

## Commands

| Task | Command |
|---|---|
| Fetch deps | `flutter pub get` |
| Codegen | `dart run build_runner build` |
| Codegen (watch) | `dart run build_runner watch` |
| Analyze | `flutter analyze` |
| Test | `flutter test` |

## Conventions

- No hardcoded colors, text styles, spacing, or radii — everything comes from `core/theme/`.
- Icons are referenced semantically via `AppIcons`.
- Routes are referenced via `RoutePaths` helpers, never string literals.
- Generated files (`*.freezed.dart`, `*.g.dart`) are excluded from analysis and never edited by hand.
