# Flutter Project Pattern Guide

> **Stack:** Very Good CLI · BLoC · SQFlite · SharedPreferences · Firebase · FlutterGen

---

## Daftar Isi

1. [Setup & Inisialisasi Project](#1-setup--inisialisasi-project)
2. [Struktur Direktori](#2-struktur-direktori)
3. [Dependencies](#3-dependencies)
4. [Konfigurasi FlutterGen](#4-konfigurasi-fluttergen)
5. [Arsitektur & Layer](#5-arsitektur--layer)
6. [Local Storage Pattern](#6-local-storage-pattern)
7. [Firebase Pattern](#7-firebase-pattern)
8. [BLoC Pattern](#8-bloc-pattern)
9. [Contoh Implementasi: Fitur Login PIN](#9-contoh-implementasi-fitur-login-pin)
10. [Naming Convention](#10-naming-convention)

---

## 1. Setup & Inisialisasi Project

### Install Very Good CLI

```bash
dart pub global activate very_good_cli
```

### Buat Project Baru

```bash
very_good create flutter_app my_app \
  --desc "My Flutter Application" \
  --org "com.example"
```

### Struktur yang Dihasilkan Very Good CLI

```
my_app/
├── lib/
├── test/
├── pubspec.yaml
├── analysis_options.yaml   # Very Good Analysis rules
└── .github/                # CI/CD workflows
```

---

## 2. Struktur Direktori

```
lib/
├── app/
│   ├── app.dart
│   ├── app_bloc_observer.dart
│   └── view/
│       └── app.dart
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── storage_keys.dart
│   ├── di/
│   │   └── injection.dart          # Dependency Injection (get_it)
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── extensions/
│   │   └── context_extension.dart
│   ├── network/
│   │   └── network_info.dart
│   ├── router/
│   │   └── app_router.dart
│   └── theme/
│       ├── app_theme.dart
│       └── app_colors.dart
│
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── app_database.dart           # SQFlite database
│   │   │   ├── preference_helper.dart      # SharedPreferences
│   │   │   └── dao/
│   │   │       └── user_dao.dart
│   │   └── remote/
│   │       └── firebase_auth_datasource.dart
│   ├── models/
│   │   └── user_model.dart
│   └── repositories/
│       └── auth_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   └── user.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       ├── verify_pin_usecase.dart
│       ├── save_pin_usecase.dart
│       └── get_current_user_usecase.dart
│
├── features/
│   └── login/
│       ├── bloc/
│       │   ├── login_bloc.dart
│       │   ├── login_event.dart
│       │   └── login_state.dart
│       ├── view/
│       │   ├── login_page.dart
│       │   └── login_view.dart
│       └── widgets/
│           ├── pin_input_widget.dart
│           └── pin_keyboard_widget.dart
│
└── gen/                     # FlutterGen output (auto-generated)
    ├── assets.gen.dart
    └── fonts.gen.dart
```

---

## 3. Dependencies

### `pubspec.yaml`

```yaml
name: my_app
description: My Flutter Application
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter

  # State Management
  bloc: ^8.1.4
  flutter_bloc: ^8.1.6
  equatable: ^2.0.5

  # Local Storage
  sqflite: ^2.3.3
  shared_preferences: ^2.2.3
  path: ^1.9.0

  # Firebase
  firebase_core: ^2.32.0
  firebase_auth: ^4.20.0
  cloud_firestore: ^4.17.5

  # DI & Utils
  get_it: ^7.7.0
  injectable: ^2.4.4
  dartz: ^0.10.1
  crypto: ^3.0.3
  local_auth: ^2.2.0   # Biometric fallback
  pin_code_fields: ^8.0.1

  # Assets (FlutterGen)
  flutter_svg: ^2.0.10+1

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Very Good Analysis
  very_good_analysis: ^6.0.0

  # FlutterGen
  flutter_gen_runner: ^5.7.0
  build_runner: ^2.4.11

  # Code Generation
  injectable_generator: ^2.6.2
  bloc_test: ^9.1.7
  mocktail: ^1.0.4

flutter:
  uses-material-design: true

  assets:
    - assets/images/
    - assets/icons/
    - assets/lottie/

  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700

flutter_gen:
  output: lib/gen/
  line_length: 80
  integrations:
    flutter_svg: true
    lottie: true
```

---

## 4. Konfigurasi FlutterGen

### Generate Assets

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Hasil Generate (`lib/gen/assets.gen.dart`)

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

class Assets {
  const Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsIconsGen icons = $AssetsIconsGen();
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  AssetGenImage get logo => const AssetGenImage('assets/images/logo.png');
  AssetGenImage get splashBg =>
      const AssetGenImage('assets/images/splash_bg.png');
}

class $AssetsIconsGen {
  const $AssetsIconsGen();

  SvgGenImage get fingerprint =>
      const SvgGenImage('assets/icons/fingerprint.svg');
  SvgGenImage get lock => const SvgGenImage('assets/icons/lock.svg');
}
```

### Penggunaan di Widget

```dart
// Sebelum FlutterGen (rentan typo)
Image.asset('assets/images/logo.png');

// Sesudah FlutterGen (type-safe)
Assets.images.logo.image();
Assets.icons.lock.svg(width: 24, height: 24);
```

---

## 5. Arsitektur & Layer

```
┌──────────────────────────────────────┐
│           Presentation Layer          │
│    (Pages, Views, Widgets, BLoC)      │
└─────────────────┬────────────────────┘
                  │ calls
┌─────────────────▼────────────────────┐
│            Domain Layer               │
│      (Entities, UseCases, Repo IF)    │
└─────────────────┬────────────────────┘
                  │ implements
┌─────────────────▼────────────────────┐
│             Data Layer                │
│  (Models, Repo Impl, DataSources)     │
│                                       │
│   ┌────────────┐  ┌────────────────┐  │
│   │  SQFlite   │  │   Firebase     │  │
│   │  + Prefs   │  │   Auth/Store   │  │
│   └────────────┘  └────────────────┘  │
└──────────────────────────────────────┘
```

### Prinsip Utama

| Layer        | Boleh Akses         | Tidak Boleh Akses     |
|--------------|---------------------|-----------------------|
| Presentation | Domain              | Data langsung         |
| Domain       | —                   | Data, Flutter package |
| Data         | Domain (interfaces) | Presentation          |

---

## 6. Local Storage Pattern

### SQFlite — Database Helper

```dart
// lib/data/datasources/local/app_database.dart

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static Database? _db;

  static const _dbName = 'app_database.db';
  static const _dbVersion = 1;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        pin_hash TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations here
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _db = null;
  }
}
```

### SharedPreferences Helper

```dart
// lib/data/datasources/local/preference_helper.dart

import 'package:shared_preferences/shared_preferences.dart';

abstract class StorageKeys {
  static const String isLoggedIn = 'is_logged_in';
  static const String userId = 'user_id';
  static const String pinAttempts = 'pin_attempts';
  static const String lastLoginAt = 'last_login_at';
  static const String biometricEnabled = 'biometric_enabled';
}

class PreferenceHelper {
  PreferenceHelper(this._prefs);

  final SharedPreferences _prefs;

  // Auth
  Future<bool> setLoggedIn({required bool value}) =>
      _prefs.setBool(StorageKeys.isLoggedIn, value);

  bool get isLoggedIn => _prefs.getBool(StorageKeys.isLoggedIn) ?? false;

  Future<bool> setUserId(String id) =>
      _prefs.setString(StorageKeys.userId, id);

  String? get userId => _prefs.getString(StorageKeys.userId);

  // PIN Attempts
  Future<bool> incrementPinAttempts() {
    final current = pinAttempts;
    return _prefs.setInt(StorageKeys.pinAttempts, current + 1);
  }

  Future<bool> resetPinAttempts() =>
      _prefs.setInt(StorageKeys.pinAttempts, 0);

  int get pinAttempts => _prefs.getInt(StorageKeys.pinAttempts) ?? 0;

  // Biometric
  Future<bool> setBiometricEnabled({required bool value}) =>
      _prefs.setBool(StorageKeys.biometricEnabled, value);

  bool get biometricEnabled =>
      _prefs.getBool(StorageKeys.biometricEnabled) ?? false;

  Future<void> clearAll() async => _prefs.clear();
}
```

---

## 7. Firebase Pattern

### Inisialisasi Firebase

```dart
// lib/main.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await configureDependencies();
  runApp(const App());
}
```

### Firebase Auth DataSource

```dart
// lib/data/datasources/remote/firebase_auth_datasource.dart

import 'package:firebase_auth/firebase_auth.dart';

abstract class FirebaseAuthDataSource {
  Future<UserCredential> signInWithEmail(String email, String password);
  Future<void> signOut();
  Stream<User?> get authStateChanges;
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  FirebaseAuthDataSourceImpl(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  @override
  Future<UserCredential> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    }
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Exception _mapFirebaseException(FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' => const UserNotFoundException(),
      'wrong-password' => const WrongPasswordException(),
      'too-many-requests' => const TooManyRequestsException(),
      _ => ServerException(e.message ?? 'Unknown error'),
    };
  }
}
```

---

## 8. BLoC Pattern

### Struktur BLoC

```
feature/
└── bloc/
    ├── feature_bloc.dart   # Logic & business rules
    ├── feature_event.dart  # Input triggers
    └── feature_state.dart  # Output states
```

### Konvensi Penamaan

| Komponen | Format              | Contoh                   |
|----------|---------------------|--------------------------|
| Event    | `NounVerb`          | `PinSubmitted`           |
| State    | Status description  | `LoginLoading`           |
| BLoC     | `FeatureBloc`       | `LoginBloc`              |

### BLoC Observer (Global)

```dart
// lib/app/app_bloc_observer.dart

import 'package:bloc/bloc.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    // Log state changes (use logger in production)
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    // Log errors to Firebase Crashlytics
    super.onError(bloc, error, stackTrace);
  }
}
```

---

## 9. Contoh Implementasi: Fitur Login PIN

### 9.1 Domain Layer

#### Entity

```dart
// lib/domain/entities/user.dart

import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.username,
  });

  final String id;
  final String username;

  static const empty = User(id: '', username: '');
  bool get isEmpty => this == empty;

  @override
  List<Object> get props => [id, username];
}
```

#### Repository Interface

```dart
// lib/domain/repositories/auth_repository.dart

import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../../core/error/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> verifyPin(String pin);
  Future<Either<Failure, Unit>> savePin(String pin);
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, Unit>> logout();
}
```

#### Use Cases

```dart
// lib/domain/usecases/verify_pin_usecase.dart

import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../../core/error/failures.dart';

class VerifyPinUseCase {
  const VerifyPinUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, User>> call(String pin) {
    return _repository.verifyPin(pin);
  }
}
```

### 9.2 Data Layer

#### User Model

```dart
// lib/data/models/user_model.dart

import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required this.pinHash,
    required this.createdAt,
  });

  final String pinHash;
  final DateTime createdAt;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      username: map['username'] as String,
      pinHash: map['pin_hash'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['created_at'] as int,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'pin_hash': pinHash,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
  }
}
```

#### User DAO

```dart
// lib/data/datasources/local/dao/user_dao.dart

import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../app_database.dart';
import '../../models/user_model.dart';

class UserDao {
  UserDao(this._database);

  final AppDatabase _database;

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  Future<UserModel?> getUserById(String id) async {
    final db = await _database.database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<bool> verifyPin(String userId, String pin) async {
    final user = await getUserById(userId);
    if (user == null) return false;
    return user.pinHash == _hashPin(pin);
  }

  Future<void> saveUser(UserModel user) async {
    final db = await _database.database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updatePin(String userId, String newPin) async {
    final db = await _database.database;
    await db.update(
      'users',
      {
        'pin_hash': _hashPin(newPin),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
```

#### Repository Implementation

```dart
// lib/data/repositories/auth_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/error/failures.dart';
import '../datasources/local/dao/user_dao.dart';
import '../datasources/local/preference_helper.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required UserDao userDao,
    required PreferenceHelper preferenceHelper,
  })  : _userDao = userDao,
        _prefs = preferenceHelper;

  final UserDao _userDao;
  final PreferenceHelper _prefs;

  static const int _maxPinAttempts = 5;

  @override
  Future<Either<Failure, User>> verifyPin(String pin) async {
    try {
      // Cek apakah sudah melebihi batas percobaan
      if (_prefs.pinAttempts >= _maxPinAttempts) {
        return Left(TooManyAttemptsFailure());
      }

      final userId = _prefs.userId;
      if (userId == null) return Left(UserNotFoundFailure());

      final isValid = await _userDao.verifyPin(userId, pin);

      if (!isValid) {
        await _prefs.incrementPinAttempts();
        final remaining = _maxPinAttempts - _prefs.pinAttempts;
        return Left(InvalidPinFailure(remainingAttempts: remaining));
      }

      // Reset attempt counter on success
      await _prefs.resetPinAttempts();
      await _prefs.setLoggedIn(value: true);

      final user = await _userDao.getUserById(userId);
      if (user == null) return Left(UserNotFoundFailure());

      return Right(user);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> savePin(String pin) async {
    try {
      final userId = _prefs.userId;
      if (userId == null) return Left(UserNotFoundFailure());

      await _userDao.updatePin(userId, pin);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final userId = _prefs.userId;
      if (userId == null) return Left(UserNotFoundFailure());

      final user = await _userDao.getUserById(userId);
      if (user == null) return Left(UserNotFoundFailure());

      return Right(user);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _prefs.setLoggedIn(value: false);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
```

### 9.3 Failures & Exceptions

```dart
// lib/core/error/failures.dart

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([this.message = '']);
  final String message;

  @override
  List<Object> get props => [message];
}

class InvalidPinFailure extends Failure {
  InvalidPinFailure({required this.remainingAttempts})
      : super('PIN tidak valid. Sisa percobaan: $remainingAttempts');

  final int remainingAttempts;

  @override
  List<Object> get props => [message, remainingAttempts];
}

class TooManyAttemptsFailure extends Failure {
  TooManyAttemptsFailure() : super('Terlalu banyak percobaan. Akun dikunci.');
}

class UserNotFoundFailure extends Failure {
  UserNotFoundFailure() : super('Pengguna tidak ditemukan.');
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}
```

### 9.4 BLoC Layer

#### Event

```dart
// lib/features/login/bloc/login_event.dart

part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

/// Dipanggil saat user menekan angka pada keyboard PIN
final class PinDigitAdded extends LoginEvent {
  const PinDigitAdded(this.digit);
  final String digit;

  @override
  List<Object> get props => [digit];
}

/// Dipanggil saat user menekan tombol hapus
final class PinDigitRemoved extends LoginEvent {
  const PinDigitRemoved();
}

/// Dipanggil saat PIN sudah lengkap (auto-submit)
final class PinSubmitted extends LoginEvent {
  const PinSubmitted();
}

/// Dipanggil saat user menekan tombol biometrik
final class BiometricLoginRequested extends LoginEvent {
  const BiometricLoginRequested();
}

/// Reset state ke initial
final class LoginReset extends LoginEvent {
  const LoginReset();
}
```

#### State

```dart
// lib/features/login/bloc/login_state.dart

part of 'login_bloc.dart';

enum LoginStatus { initial, loading, success, failure, locked }

final class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
    this.pin = '',
    this.errorMessage,
    this.remainingAttempts,
    this.user,
  });

  final LoginStatus status;
  final String pin;
  final String? errorMessage;
  final int? remainingAttempts;
  final User? user;

  static const int pinLength = 6;
  bool get isPinComplete => pin.length == pinLength;
  bool get isLoading => status == LoginStatus.loading;
  bool get isLocked => status == LoginStatus.locked;

  LoginState copyWith({
    LoginStatus? status,
    String? pin,
    String? errorMessage,
    int? remainingAttempts,
    User? user,
  }) {
    return LoginState(
      status: status ?? this.status,
      pin: pin ?? this.pin,
      errorMessage: errorMessage,
      remainingAttempts: remainingAttempts ?? this.remainingAttempts,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [
        status,
        pin,
        errorMessage,
        remainingAttempts,
        user,
      ];
}
```

#### BLoC

```dart
// lib/features/login/bloc/login_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/verify_pin_usecase.dart';
import '../../../core/error/failures.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required VerifyPinUseCase verifyPinUseCase})
      : _verifyPinUseCase = verifyPinUseCase,
        super(const LoginState()) {
    on<PinDigitAdded>(_onPinDigitAdded);
    on<PinDigitRemoved>(_onPinDigitRemoved);
    on<PinSubmitted>(_onPinSubmitted);
    on<LoginReset>(_onLoginReset);
  }

  final VerifyPinUseCase _verifyPinUseCase;

  void _onPinDigitAdded(
    PinDigitAdded event,
    Emitter<LoginState> emit,
  ) {
    if (state.pin.length >= LoginState.pinLength || state.isLoading) return;

    final newPin = state.pin + event.digit;
    emit(state.copyWith(pin: newPin, status: LoginStatus.initial));

    // Auto-submit saat PIN sudah lengkap
    if (newPin.length == LoginState.pinLength) {
      add(const PinSubmitted());
    }
  }

  void _onPinDigitRemoved(
    PinDigitRemoved event,
    Emitter<LoginState> emit,
  ) {
    if (state.pin.isEmpty || state.isLoading) return;
    emit(
      state.copyWith(
        pin: state.pin.substring(0, state.pin.length - 1),
        status: LoginStatus.initial,
      ),
    );
  }

  Future<void> _onPinSubmitted(
    PinSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (!state.isPinComplete) return;

    emit(state.copyWith(status: LoginStatus.loading));

    final result = await _verifyPinUseCase(state.pin);

    result.fold(
      (failure) {
        if (failure is TooManyAttemptsFailure) {
          emit(
            state.copyWith(
              status: LoginStatus.locked,
              pin: '',
              errorMessage: failure.message,
            ),
          );
        } else if (failure is InvalidPinFailure) {
          emit(
            state.copyWith(
              status: LoginStatus.failure,
              pin: '',
              errorMessage: failure.message,
              remainingAttempts: failure.remainingAttempts,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: LoginStatus.failure,
              pin: '',
              errorMessage: failure.message,
            ),
          );
        }
      },
      (user) {
        emit(
          state.copyWith(
            status: LoginStatus.success,
            user: user,
          ),
        );
      },
    );
  }

  void _onLoginReset(
    LoginReset event,
    Emitter<LoginState> emit,
  ) {
    emit(const LoginState());
  }
}
```

### 9.5 Presentation Layer

#### Login Page

```dart
// lib/features/login/view/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../domain/usecases/verify_pin_usecase.dart';
import '../bloc/login_bloc.dart';
import 'login_view.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (_) => const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(
        verifyPinUseCase: getIt<VerifyPinUseCase>(),
      ),
      child: const LoginView(),
    );
  }
}
```

#### Login View

```dart
// lib/features/login/view/login_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/login_bloc.dart';
import '../widgets/pin_input_widget.dart';
import '../widgets/pin_keyboard_widget.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.status == LoginStatus.success) {
            // Navigate ke Home
            Navigator.of(context).pushReplacementNamed('/home');
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),
                _buildHeader(context),
                const Spacer(),
                const PinInputWidget(),
                const SizedBox(height: 16),
                _buildErrorMessage(),
                const Spacer(),
                const PinKeyboardWidget(),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // Gunakan FlutterGen untuk akses asset
        // Assets.icons.lock.svg(width: 64, color: Colors.white),
        const Icon(Icons.lock_outline, size: 64, color: Colors.white),
        const SizedBox(height: 24),
        Text(
          'Masukkan PIN',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Masukkan 6 digit PIN Anda',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white60,
              ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage ||
          prev.status != curr.status,
      builder: (context, state) {
        if (state.errorMessage == null) return const SizedBox.shrink();

        final isLocked = state.status == LoginStatus.locked;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isLocked
                ? Colors.red.withOpacity(0.2)
                : Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isLocked ? Colors.red : Colors.orange,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLocked ? Icons.lock : Icons.warning_amber,
                color: isLocked ? Colors.red : Colors.orange,
                size: 16,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  state.errorMessage!,
                  style: TextStyle(
                    color: isLocked ? Colors.red : Colors.orange,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

#### PIN Input Widget

```dart
// lib/features/login/widgets/pin_input_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/login_bloc.dart';

class PinInputWidget extends StatelessWidget {
  const PinInputWidget({super.key});

  static const _dotSize = 16.0;
  static const _dotSpacing = 20.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (prev, curr) =>
          prev.pin != curr.pin || prev.status != curr.status,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            LoginState.pinLength,
            (index) => _PinDot(
              isFilled: index < state.pin.length,
              hasError: state.status == LoginStatus.failure,
              index: index,
              pinLength: state.pin.length,
            ),
          ),
        );
      },
    );
  }
}

class _PinDot extends StatefulWidget {
  const _PinDot({
    required this.isFilled,
    required this.hasError,
    required this.index,
    required this.pinLength,
  });

  final bool isFilled;
  final bool hasError;
  final int index;
  final int pinLength;

  @override
  State<_PinDot> createState() => _PinDotState();
}

class _PinDotState extends State<_PinDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(_PinDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFilled && !oldWidget.isFilled) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.hasError
                ? Colors.red
                : widget.isFilled
                    ? Colors.white
                    : Colors.transparent,
            border: Border.all(
              color: widget.hasError
                  ? Colors.red
                  : Colors.white54,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
```

#### PIN Keyboard Widget

```dart
// lib/features/login/widgets/pin_keyboard_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/login_bloc.dart';

class PinKeyboardWidget extends StatelessWidget {
  const PinKeyboardWidget({super.key});

  static const _keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['', '0', 'del'],
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (prev, curr) =>
          prev.isLoading != curr.isLoading ||
          prev.isLocked != curr.isLocked,
      builder: (context, state) {
        final isDisabled = state.isLoading || state.isLocked;

        return Column(
          children: _keys.map((row) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((key) {
                return _KeyButton(
                  keyValue: key,
                  isDisabled: isDisabled,
                );
              }).toList(),
            );
          }).toList(),
        );
      },
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    required this.keyValue,
    required this.isDisabled,
  });

  final String keyValue;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    if (keyValue.isEmpty) {
      return const SizedBox(width: 80, height: 80);
    }

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
              if (keyValue == 'del') {
                context.read<LoginBloc>().add(const PinDigitRemoved());
              } else {
                context.read<LoginBloc>().add(PinDigitAdded(keyValue));
              }
            },
      child: Container(
        width: 80,
        height: 80,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(isDisabled ? 0.05 : 0.1),
        ),
        alignment: Alignment.center,
        child: keyValue == 'del'
            ? Icon(
                Icons.backspace_outlined,
                color: isDisabled ? Colors.white30 : Colors.white,
                size: 22,
              )
            : Text(
                keyValue,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: isDisabled ? Colors.white30 : Colors.white,
                ),
              ),
      ),
    );
  }
}
```

### 9.6 Dependency Injection

```dart
// lib/core/di/injection.dart

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/local/app_database.dart';
import '../../data/datasources/local/preference_helper.dart';
import '../../data/datasources/local/dao/user_dao.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/verify_pin_usecase.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // Database
  getIt.registerSingleton<AppDatabase>(AppDatabase.instance);

  // DAOs
  getIt.registerLazySingleton<UserDao>(
    () => UserDao(getIt<AppDatabase>()),
  );

  // Helpers
  getIt.registerLazySingleton<PreferenceHelper>(
    () => PreferenceHelper(getIt<SharedPreferences>()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      userDao: getIt<UserDao>(),
      preferenceHelper: getIt<PreferenceHelper>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<VerifyPinUseCase>(
    () => VerifyPinUseCase(getIt<AuthRepository>()),
  );
}
```

### 9.7 Unit Test BLoC

```dart
// test/features/login/bloc/login_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_app/core/error/failures.dart';
import 'package:my_app/domain/entities/user.dart';
import 'package:my_app/domain/usecases/verify_pin_usecase.dart';
import 'package:my_app/features/login/bloc/login_bloc.dart';

class MockVerifyPinUseCase extends Mock implements VerifyPinUseCase {}

void main() {
  late LoginBloc loginBloc;
  late MockVerifyPinUseCase mockVerifyPinUseCase;

  const tUser = User(id: 'user-1', username: 'testuser');
  const tValidPin = '123456';
  const tInvalidPin = '000000';

  setUp(() {
    mockVerifyPinUseCase = MockVerifyPinUseCase();
    loginBloc = LoginBloc(verifyPinUseCase: mockVerifyPinUseCase);
  });

  tearDown(() => loginBloc.close());

  group('PinDigitAdded', () {
    blocTest<LoginBloc, LoginState>(
      'emits state dengan PIN terupdate saat digit ditambahkan',
      build: () => loginBloc,
      act: (bloc) => bloc.add(const PinDigitAdded('1')),
      expect: () => [
        const LoginState(pin: '1', status: LoginStatus.initial),
      ],
    );
  });

  group('PinSubmitted - Sukses', () {
    blocTest<LoginBloc, LoginState>(
      'emits [loading, success] saat PIN valid',
      setUp: () {
        when(() => mockVerifyPinUseCase(tValidPin))
            .thenAnswer((_) async => const Right(tUser));
      },
      build: () => loginBloc,
      seed: () => const LoginState(pin: tValidPin),
      act: (bloc) => bloc.add(const PinSubmitted()),
      expect: () => [
        const LoginState(pin: tValidPin, status: LoginStatus.loading),
        const LoginState(
          pin: tValidPin,
          status: LoginStatus.success,
          user: tUser,
        ),
      ],
    );
  });

  group('PinSubmitted - Gagal', () {
    blocTest<LoginBloc, LoginState>(
      'emits [loading, failure] saat PIN tidak valid',
      setUp: () {
        when(() => mockVerifyPinUseCase(tInvalidPin)).thenAnswer(
          (_) async => Left(InvalidPinFailure(remainingAttempts: 4)),
        );
      },
      build: () => loginBloc,
      seed: () => const LoginState(pin: tInvalidPin),
      act: (bloc) => bloc.add(const PinSubmitted()),
      expect: () => [
        const LoginState(pin: tInvalidPin, status: LoginStatus.loading),
        isA<LoginState>()
            .having((s) => s.status, 'status', LoginStatus.failure)
            .having((s) => s.pin, 'pin', '')
            .having((s) => s.remainingAttempts, 'remainingAttempts', 4),
      ],
    );
  });
}
```

---

## 10. Naming Convention

### File & Class Naming

| Tipe           | File                       | Class               |
|----------------|----------------------------|---------------------|
| BLoC           | `login_bloc.dart`          | `LoginBloc`         |
| Event          | `login_event.dart`         | `LoginEvent`        |
| State          | `login_state.dart`         | `LoginState`        |
| Page           | `login_page.dart`          | `LoginPage`         |
| View           | `login_view.dart`          | `LoginView`         |
| Widget         | `pin_input_widget.dart`    | `PinInputWidget`    |
| Entity         | `user.dart`                | `User`              |
| Model          | `user_model.dart`          | `UserModel`         |
| Repository IF  | `auth_repository.dart`     | `AuthRepository`    |
| Repository Impl| `auth_repository_impl.dart`| `AuthRepositoryImpl`|
| UseCase        | `verify_pin_usecase.dart`  | `VerifyPinUseCase`  |
| DAO            | `user_dao.dart`            | `UserDao`           |

### Aturan Umum

- Semua file menggunakan `snake_case`
- Class, Enum, dan Extension menggunakan `PascalCase`
- Variabel dan parameter menggunakan `camelCase`
- Konstanta menggunakan `camelCase` (bukan `SCREAMING_SNAKE_CASE`)
- Private member diawali dengan underscore `_`
- Gunakan `sealed class` untuk Event dan State Pattern

---

> **Tip:** Jalankan `very_good check --all` secara rutin untuk memastikan kode sesuai dengan standar very_good_analysis.
