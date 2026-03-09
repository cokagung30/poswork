# Project Guidelines — Poswork (Flutter POS)

## Code Style

- **Lint rules**: `very_good_analysis` + `bloc_lint/recommended.yaml` — do not disable rules without justification
- **Barrel exports**: Every feature folder has a barrel file (e.g., `counter/counter.dart`) that re-exports public API
- **Page/View separation**: `FooPage` creates `BlocProvider`, `FooView` consumes state — never mix DI wiring with UI
- Use `context.select` for granular rebuilds, not `BlocBuilder` for single-field reads
- Material 3 theming enabled — use theme tokens, not raw colors

### Naming Conventions

| Element             | Convention                   | Example                |
| ------------------- | ---------------------------- | ---------------------- |
| Files               | `snake_case`                 | `auth_bloc.dart`       |
| Classes             | `PascalCase`                 | `AuthBloc`             |
| Variables & methods | `camelCase`                  | `isLoading`            |
| Constants           | `camelCase` with `k` prefix  | `kPrimaryColor`        |
| BLoC Events         | `Noun + Verb + Requested`    | `AuthLoginRequested`   |
| BLoC States         | `Feature + State`            | `AuthState`            |
| DB table names      | `snake_case` (plural)        | `users`, `order_items` |
| Prefs keys          | `snake_case` (private const) | `_keyAuthToken`        |
| Use Cases           | `Verb + Noun + UseCase`      | `SignInUseCase`        |
| Repositories        | `Noun + Repository`          | `UserRepository`       |
| Data Sources        | `Noun + Scope + DataSource`  | `UserLocalDataSource`  |

## Architecture

- **Very Good CLI** scaffold with BLoC state management
- **Clean Architecture** with strict layer separation (see `docs/flutter_pos_architecture.md`)
- **Offline-first**: local SQFlite DB is source of truth, background sync to Firestore
- Full roadmap and feature specs in `docs/flutter_pos_master_plan.md`

### Layer Dependency Rules

- **Presentation → Domain only**. Never import from Data layer in presentation code.
- **Domain** is pure Dart — no Flutter or third-party dependencies.
- **Data** fulfills Domain contracts and is the only layer aware of Firebase, SQFlite, or SharedPreferences.

### Project Structure

```
lib/
├── app/                            # Root widget, MaterialApp, router, BlocObserver
├── core/
│   ├── constants/                  # app_constants, db_constants, firebase_constants
│   ├── errors/                     # exceptions.dart, failures.dart
│   ├── network/                    # network_info.dart
│   ├── theme/                      # app_theme.dart, app_colors.dart
│   └── utils/                      # date_utils, validators
├── data/
│   ├── datasources/
│   │   ├── local/sqflite/          # SQFlite CRUD datasources
│   │   ├── local/preferences/      # SharedPreferences datasources
│   │   └── remote/                 # Firebase Auth & Firestore datasources
│   ├── models/                     # Data models with JSON/DB serialization
│   └── repositories/              # Repository implementations (local + remote)
├── domain/
│   ├── entities/                   # Pure Dart business objects
│   ├── repositories/              # Abstract repository contracts
│   └── usecases/                  # Single-responsibility business actions
├── presentation/
│   ├── features/
│   │   └── feature_name/
│   │       ├── bloc/              # BLoC: events, states, bloc
│   │       ├── pages/             # Full-screen route targets
│   │       └── widgets/           # Feature-scoped UI components
│   └── shared/widgets/            # Cross-feature reusable widgets
├── injection_container.dart        # GetIt registration for all dependencies
├── gen/                            # FlutterGen output (do not edit manually)
└── main_*.dart                     # Flavor entry points
```

### BLoC Best Practices

- One BLoC per feature — BLoCs must not be shared across unrelated features
- Events represent user intentions; states represent the full UI snapshot
- Side effects (navigation, dialogs) belong in `BlocListener`, not `BlocBuilder`

### Data Layer Rules

- **SQFlite**: All table/column names as constants in `db_constants.dart`. Schema changes via versioned `onUpgrade` migrations — never drop and recreate. Use transactions for multi-step writes.
- **SharedPreferences**: Never store sensitive data (passwords, tokens). All keys as private constants in the datasource.
- **Firebase**: Catch exceptions at datasource level → convert to domain `Failure` types. Never expose Firebase models (`DocumentSnapshot`, `User`) beyond Data layer.
- **FlutterGen**: Use generated `Assets` class — never reference asset paths as raw strings.

### Offline-First Sync

- All writes go to SQFlite first (`synced = false`)
- Background `SyncManager` processes queue on connectivity
- Sync is idempotent — uses record ID as Firestore document ID
- Local data is always source of truth; Firestore is for reporting and cross-device visibility

## Build and Test

```bash
# Run by flavor
flutter run --flavor development --target lib/main_development.dart
flutter run --flavor staging --target lib/main_staging.dart
flutter run --flavor production --target lib/main_production.dart

# Run all tests
flutter test

# Generate assets (after adding/renaming asset files)
flutter pub run build_runner build --delete-conflicting-outputs

# BLoC lint check
dart run bloc_tools:bloc lint .

# Build release APK
flutter build apk --flavor production --target lib/main_production.dart
```

## Conventions

- **Three flavors**: `development` (`.dev`), `staging` (`.stg`), `production` — each has its own entry point in `lib/main_*.dart`
- **Bootstrap pattern**: All entry points call `bootstrap(() => const App())` — app initialization lives in `lib/bootstrap.dart`
- **DI**: Use `get_it` via `injection_container.dart` for all service registration. Use `equatable` for value equality in BLoC states/events.
- **Testing**: Unit test every use case, repository impl, and BLoC. Use `tester.pumpApp(widget)` helper from `test/helpers/pump_app.dart`. BLoC tests use `blocTest`. Widget tests mock cubits with `MockCubit` + `mocktail`.
- **Package ID**: `com.baliwork.pos`
