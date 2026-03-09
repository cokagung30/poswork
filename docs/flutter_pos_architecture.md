# Flutter Project Architecture Pattern
### Very Good CLI · BLoC · SQFlite · SharedPreferences · Firebase · FlutterGen

---

## Table of Contents

1. [Overview](#overview)
2. [Tech Stack](#tech-stack)
3. [Project Structure](#project-structure)
4. [Layer Responsibilities](#layer-responsibilities)
5. [Naming Conventions](#naming-conventions)
6. [Best Practices](#best-practices)

---

## Overview

This document defines the **standard architecture pattern** for Flutter projects scaffolded with [Very Good CLI](https://cli.vgv.dev/). It enforces a clean, scalable, and testable codebase using:

- **Very Good CLI** — project scaffolding & flavoring
- **BLoC** — predictable, reactive state management
- **SQFlite** — structured local relational database
- **SharedPreferences** — lightweight key-value persistence
- **Firebase** — cloud backend (Auth, Firestore, Messaging, etc.)
- **FlutterGen** — type-safe code generation for assets, fonts, and colors

---

## Tech Stack

| Category | Package | Purpose |
|---|---|---|
| Scaffolding | `very_good_cli` | Project structure, flavors, and linting setup |
| State Management | `flutter_bloc` | UI state handling via BLoC pattern |
| BLoC Core | `bloc` | Business logic separation from UI |
| Local DB | `sqflite` | Structured relational data persistence |
| Key-Value Storage | `shared_preferences` | Lightweight settings and flag storage |
| Firebase Core | `firebase_core` | Firebase SDK initialization |
| Firebase Auth | `firebase_auth` | User authentication |
| Cloud Firestore | `cloud_firestore` | Cloud NoSQL document database |
| Firebase Messaging | `firebase_messaging` | Push notification handling |
| DI / Service Locator | `get_it` | Dependency injection across layers |
| Equatable | `equatable` | Value equality for BLoC states & events |
| Asset Generation | `flutter_gen` | Type-safe generated references for images, fonts, and colors |

---

## Project Structure

```
my_app/
├── lib/
│   ├── app/
│   │   ├── app.dart                        # Root app widget and MaterialApp setup
│   │   ├── app_router.dart                 # Centralized route definitions
│   │   └── app_bloc_observer.dart          # Global BLoC lifecycle observer for logging
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart          # Global app-wide constants (timeouts, limits)
│   │   │   ├── db_constants.dart           # SQFlite table and column name constants
│   │   │   └── firebase_constants.dart     # Firestore collection and field name constants
│   │   ├── errors/
│   │   │   ├── exceptions.dart             # Raw exception types thrown by data sources
│   │   │   └── failures.dart               # Domain-level failure types for error handling
│   │   ├── network/
│   │   │   └── network_info.dart           # Network connectivity checker
│   │   ├── theme/
│   │   │   ├── app_theme.dart              # ThemeData configuration (light/dark)
│   │   │   └── app_colors.dart             # Color palette constants
│   │   └── utils/
│   │       ├── date_utils.dart             # Date formatting and conversion helpers
│   │       └── validators.dart             # Input validation utilities
│   │
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── local/
│   │   │   │   ├── sqflite/
│   │   │   │   │   ├── database_helper.dart          # SQFlite singleton, schema creation & migration
│   │   │   │   │   └── user_local_datasource.dart    # CRUD operations on the users table
│   │   │   │   └── preferences/
│   │   │   │       └── preferences_datasource.dart   # Read/write key-value data via SharedPreferences
│   │   │   └── remote/
│   │   │       ├── firebase_auth_datasource.dart     # Firebase Auth sign-in, sign-up, sign-out
│   │   │       └── firestore_datasource.dart         # Firestore document reads, writes, and streams
│   │   ├── models/
│   │   │   └── user_model.dart             # Data model with JSON serialization and DB mapping
│   │   └── repositories/
│   │       └── user_repository_impl.dart   # Combines local and remote sources; owns sync logic
│   │
│   ├── domain/
│   │   ├── entities/
│   │   │   └── user_entity.dart            # Pure Dart business object, no external dependencies
│   │   ├── repositories/
│   │   │   └── user_repository.dart        # Abstract contract defining available data operations
│   │   └── usecases/
│   │       ├── get_user_usecase.dart        # Fetches a single user by ID
│   │       ├── save_user_usecase.dart       # Persists user data locally and/or remotely
│   │       └── sign_in_usecase.dart         # Handles authentication business logic
│   │
│   ├── presentation/
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   │   ├── bloc/
│   │   │   │   │   ├── auth_bloc.dart      # Processes auth events and emits auth states
│   │   │   │   │   ├── auth_event.dart     # Defines all possible auth user actions
│   │   │   │   │   └── auth_state.dart     # Defines all possible auth UI states
│   │   │   │   ├── pages/
│   │   │   │   │   ├── login_page.dart     # Login screen UI
│   │   │   │   │   └── register_page.dart  # Registration screen UI
│   │   │   │   └── widgets/
│   │   │   │       └── auth_form.dart      # Reusable form widget for auth inputs
│   │   │   │
│   │   │   └── home/
│   │   │       ├── bloc/
│   │   │       │   ├── home_bloc.dart      # Processes home events and emits home states
│   │   │       │   ├── home_event.dart     # Defines all possible home user actions
│   │   │       │   └── home_state.dart     # Defines all possible home UI states
│   │   │       ├── pages/
│   │   │       │   └── home_page.dart      # Main home screen UI
│   │   │       └── widgets/
│   │   │           └── home_card.dart      # Reusable card component for home content
│   │   │
│   │   └── shared/
│   │       └── widgets/
│   │           ├── loading_widget.dart     # Global loading indicator component
│   │           └── error_widget.dart       # Global error display component
│   │
│   ├── injection_container.dart            # GetIt registration for all dependencies
│   ├── gen/                                # Auto-generated by flutter_gen (do not edit manually)
│   │   ├── assets.gen.dart                 # Type-safe references to all image and icon assets
│   │   ├── fonts.gen.dart                  # Type-safe references to all custom font families
│   │   └── colors.gen.dart                 # Type-safe references to colors defined in pubspec
│   └── main.dart                           # App entry point; initializes Firebase and DI
│
├── test/
│   ├── data/                               # Unit tests for datasources and repositories
│   ├── domain/                             # Unit tests for use cases
│   └── presentation/                       # BLoC unit tests and widget tests
│
├── assets/
│   ├── images/                             # PNG, JPG image assets
│   ├── icons/                              # SVG and icon assets
│   └── fonts/                              # Custom font files
│
├── flavors/
│   ├── main_development.dart               # Entry point for development flavor
│   ├── main_staging.dart                   # Entry point for staging flavor
│   └── main_production.dart                # Entry point for production flavor
│
├── pubspec.yaml                            # Dependencies and asset declarations
├── flutter_gen_config.yaml                 # FlutterGen configuration (output path, integrations)
├── analysis_options.yaml                   # Very Good Analysis lint rules
└── README.md
```

---

## Layer Responsibilities

### `app/`
The root of the Flutter application. Responsible for wiring the widget tree, defining navigation routes, and observing BLoC lifecycle events globally.

### `core/`
Shared infrastructure used across all features. Contains constants, error types, theme configuration, and utility helpers. Has no dependency on any feature layer.

### `data/`
Implements how data is fetched, stored, and synchronized. This layer talks directly to SQFlite, SharedPreferences, and Firebase. It maps raw data into models and fulfills the repository contracts defined in the domain layer.

- **`datasources/local/sqflite/`** — manages structured relational data using SQFlite tables; suitable for lists, records, and queryable data.
- **`datasources/local/preferences/`** — manages lightweight key-value pairs using SharedPreferences; suitable for user settings, flags, and tokens.
- **`datasources/remote/`** — handles all communication with Firebase services including authentication and Firestore document management.
- **`models/`** — data transfer objects that know how to serialize/deserialize from JSON and map to/from database rows.
- **`repositories/`** — concrete implementations that coordinate between local and remote sources, applying caching and sync strategies.

### `domain/`
The core business logic layer. Contains no Flutter or external library dependencies — only pure Dart. Defines the rules of the application independently of any storage or UI technology.

- **`entities/`** — plain Dart objects representing core business concepts.
- **`repositories/`** — abstract interfaces that define what data operations are available, without specifying how.
- **`usecases/`** — single-responsibility classes that encapsulate one business action, called directly by BLoCs.

### `presentation/`
Everything the user sees and interacts with. Each feature is self-contained with its own BLoC, pages, and widgets.

- **`bloc/`** — receives user events, calls use cases, and emits new states to drive UI updates.
- **`pages/`** — full screens rendered by the router.
- **`widgets/`** — smaller, reusable UI components scoped to a feature.
- **`shared/widgets/`** — common components used across multiple features.

### `flavors/`
Separate entry points for development, staging, and production environments. Each flavor can configure different Firebase projects, API endpoints, and feature flags.

### `lib/gen/`
Auto-generated code produced by `flutter_gen` via `build_runner`. This folder must never be edited manually — it is always regenerated from the asset declarations in `pubspec.yaml`.

- **`assets.gen.dart`** — provides type-safe, compile-time-checked references to every image and icon file declared under `assets/`. Eliminates hardcoded path strings across the codebase.
- **`fonts.gen.dart`** — provides type-safe constants for every custom font family declared in `pubspec.yaml`, preventing typos in font name strings.
- **`colors.gen.dart`** — provides type-safe color constants when colors are defined via the FlutterGen color integration, keeping the color palette consistent across the app.

---

## Naming Conventions

| Element | Convention | Example |
|---|---|---|
| Files | `snake_case` | `auth_bloc.dart` |
| Classes | `PascalCase` | `AuthBloc` |
| Variables & methods | `camelCase` | `isLoading` |
| Constants | `camelCase` with `k` prefix | `kPrimaryColor` |
| BLoC Events | `Noun + Verb + Requested` | `AuthLoginRequested` |
| BLoC States | `Feature + State` | `AuthState` |
| DB table names | `snake_case` (plural) | `users`, `order_items` |
| Prefs keys | `snake_case` (private const) | `_keyAuthToken` |
| Use Cases | `Verb + Noun + UseCase` | `SignInUseCase` |
| Repositories | `Noun + Repository` | `UserRepository` |
| Data Sources | `Noun + Scope + DataSource` | `UserLocalDataSource` |

---

## Best Practices

### Architecture
- The **Presentation** layer may only depend on **Domain**. It must never import from the Data layer.
- The **Domain** layer must remain free of all Flutter and third-party dependencies.
- The **Data** layer fulfills Domain contracts and is the only layer aware of Firebase, SQFlite, or SharedPreferences.

### BLoC
- One BLoC per feature. BLoCs must not be shared across unrelated features.
- Events represent user intentions; states represent the full UI snapshot at a given moment.
- Side effects (navigation, dialogs) belong in `BlocListener`, not `BlocBuilder`.

### SQFlite
- All table and column names must be declared as constants in `db_constants.dart`.
- Schema changes must be handled through versioned `onUpgrade` migrations — never drop and recreate.
- Use database transactions for any multi-step write operations.

### SharedPreferences
- Never store sensitive data (passwords, auth tokens) in SharedPreferences. Use `flutter_secure_storage` for those cases.
- All preference keys must be private constants defined inside the datasource implementation.

### Firebase
- All Firebase exceptions must be caught at the datasource level and converted into domain `Failure` types before reaching the repository or BLoC.
- Never expose Firebase models (`DocumentSnapshot`, `User`) beyond the Data layer.
- Enable **Firebase App Check** in production to prevent API abuse.

### FlutterGen
- Always run `flutter pub run build_runner build --delete-conflicting-outputs` after adding or renaming any asset file.
- Never reference asset paths as raw strings (e.g. `'assets/images/logo.png'`) — always use the generated `Assets` class instead.
- Commit the generated `lib/gen/` files into version control so the project builds without requiring a code generation step on first checkout.
- Configure the output directory and integration options (e.g. `flutter_svg`, `lottie`) in `flutter_gen_config.yaml`.

### Testing
- Unit test every use case, repository implementation, and BLoC in isolation.
- Use `mocktail` or `mockito` for mocking dependencies.
- Use the `bloc_test` package for all BLoC unit tests.

---

> **Pattern Version:** 1.0.0 · **Flutter SDK:** ≥ 3.x · **Dart SDK:** ≥ 3.x