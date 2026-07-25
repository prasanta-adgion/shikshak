# Shikshak

**Find the Right Teacher. Learn Without Limits.**

A production-grade Flutter home-tutoring app connecting students with teachers. Built with feature-first Clean Architecture, Riverpod, GoRouter, Dio, and Material 3.

## Getting Started

```bash
flutter pub get
flutter run -t lib/main_dev.dart
```

## Flavors

The environment is chosen by the entrypoint. Each `main_*.dart` only selects an
`AppFlavor`; `bootstrap.dart` owns the shared startup path so environments
cannot drift.

| Flavor | Entrypoint | Base URL | Application ID |
|---|---|---|---|
| dev | `lib/main_dev.dart` | `http://192.168.1.12:5001` | `…Shikshak.dev` |
| staging | `lib/main_staging.dart` | *(not provisioned)* | `…Shikshak.staging` |
| prod | `lib/main_prod.dart` | *(not provisioned)* | `…Shikshak` |

The Android `productFlavors` in `app/build.gradle.kts` use these same names.
**Always pass both `--flavor` and `-t`** — Gradle picks the native flavor, `-t`
picks the Dart entrypoint, and Flutter does not infer one from the other:

```bash
flutter run --flavor dev     -t lib/main_dev.dart
flutter build apk --flavor prod -t lib/main_prod.dart --release
```

The `.vscode/launch.json` configurations already pair them correctly.

dev and staging carry an `applicationIdSuffix` and their own launcher label
("Shikshak Dev" / "Shikshak Staging"), so all three install side by side on one
device. A bare `flutter run` (via `lib/main.dart`) targets **dev** but builds no
native flavor.

Hosts live in `AppFlavor` (`lib/core/flavor/app_flavor.dart`) — the single
source of truth. `ApiEndpoints` holds paths only, and may write them with or
without a leading slash: `DioClient` normalises the base URL to end with `/`,
because Dio concatenates the two verbatim and `host:5001` + `api/v1/x` would
otherwise produce `host:5001api/v1/x` (a `FormatException` on every call). The base URL is
injected into `DioClient` through `apiClientProvider`, so nothing reads global
state and tests can override `appFlavorProvider`. Staging and prod are
deliberately empty: `DioClient` asserts on an empty base URL, so a
misconfigured build fails loudly instead of issuing relative requests. Fill
those in as the environments come online.

> **Cleartext HTTP.** The dev host is `http://`, which Android blocks by
> default (targetSdk 28+) and iOS blocks via ATS. Android permits it for the
> dev LAN addresses only, via a `network-security-config` in the **debug**
> source set — release builds keep the HTTPS-only default (verified: the
> release manifest contains no `networkSecurityConfig`). iOS uses Apple's
> `NSAllowsLocalNetworking` exception, which covers local addresses without
> allowing arbitrary insecure traffic. When you add more LAN addresses, extend
> `android/app/src/debug/res/xml/network_security_config.xml` rather than
> setting a blanket `cleartextTrafficPermitted="true"`.

> Authentication talks to the **real API** (`AuthRemoteDataSourceImpl`) against
> the active flavor's host. The former mock data source has been removed — it
> accepted any well-formed credentials, which masked integration failures.
> Only the `dev` flavor has a host, so run
> `flutter run --flavor dev -t lib/main_dev.dart` with the backend reachable at
> `192.168.1.12:5001`; other flavors throw on the first API call until their
> `baseUrl` is filled in.

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




=> Data :

Responsible for fetching data.

Contains -----------
1.Repository

2.Model

3.Datasource

4.API

Example -----------
LoginRepository

LoginModel

LoginRemoteDatasource


=> Domain :

Contains business rules.

Contains -----------
Entity
Repository Interface
UseCase

Example -----------
LoginEntity 
LoginRepository 
LoginUseCase 

-> Can user login? / -> Can teacher create slot? / -> Can student book class?

=> Presentation :

Everything visible to the user.

Contains -----------
Screens
Widgets
Riverpod
Bloc
Controllers

Example -----------
LoginScreen
LoginNotifier
LoginProvider
LoginButton


presentation  ──▶  domain  ◀──  data
   (UI, state)   (business rules)  (API/storage)