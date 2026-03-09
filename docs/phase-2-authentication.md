# Phase 2 — Authentication

> PIN login, lockout, dan session token management.

**Prasyarat:** Phase 1 (Foundation) selesai.

---

## Checklist Overview

- [ ] Step 1: Buat Entity `Cashier`
- [ ] Step 2: Buat abstract Repository `AuthRepository`
- [ ] Step 3: Buat Use Cases (`VerifyPinUseCase`, `SavePinUseCase`, `GetActiveSessionUseCase`, `LogoutUseCase`)
- [ ] Step 4: Buat Data Model `CashierModel`
- [ ] Step 5: Implementasi `AuthRepositoryImpl`
- [ ] Step 6: Buat BLoC (`AuthBloc`, `AuthEvent`, `AuthState`)
- [ ] Step 7: Buat UI (`LoginPage`, `LoginView`, `PinPadWidget`, `PinIndicatorWidget`)
- [ ] Step 8: Register semua dependency di `injection_container.dart`
- [ ] Step 9: Tulis Unit Tests
- [ ] Step 10: Tulis Widget Tests

---

## Step 1: Buat Entity `Cashier`

**File: `lib/domain/entities/cashier.dart`**

```dart
class Cashier extends Equatable {
  const Cashier({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  @override
  List<Object> get props => [id, name];
}
```

> Entity ini pure Dart, tidak ada dependency ke Flutter atau third-party.

---

## Step 2: Buat Abstract Repository

**File: `lib/domain/repositories/auth_repository.dart`**

```dart
abstract class AuthRepository {
  /// Verifikasi PIN, return Cashier jika valid
  Future<Either<Failure, Cashier>> verifyPin(String pin);

  /// Simpan hashed PIN untuk pertama kali / reset
  Future<Either<Failure, void>> savePin(String pin);

  /// Cek apakah ada session aktif hari ini
  Future<Either<Failure, bool>> hasActiveSession();

  /// Logout: hapus session token, reset state
  Future<Either<Failure, void>> logout();

  /// Ambil jumlah failed attempts
  Future<int> getFailedAttempts();

  /// Cek apakah akun sedang locked out
  Future<bool> isLockedOut();
}
```

> Gunakan `dartz` package untuk `Either` atau buat sendiri simple Result type.

---

## Step 3: Buat Use Cases

### 3.1 — `VerifyPinUseCase`

**File: `lib/domain/usecases/verify_pin_usecase.dart`**

| Input        | Output                     |
| ------------ | -------------------------- |
| `String pin` | `Either<Failure, Cashier>` |

**Logic:**

1. Cek apakah akun locked out → jika iya, return `AuthFailure('Akun terkunci')`
2. Hash PIN input dengan SHA-256
3. Bandingkan dengan hashed PIN di SharedPreferences
4. Jika cocok → reset failed attempts, simpan session token, return `Cashier`
5. Jika tidak cocok → increment failed attempts, cek threshold lockout

### 3.2 — `SavePinUseCase`

**File: `lib/domain/usecases/save_pin_usecase.dart`**

| Input        | Output                  |
| ------------ | ----------------------- |
| `String pin` | `Either<Failure, void>` |

**Logic:**

1. Validasi PIN (4-6 digit)
2. Hash PIN dengan SHA-256
3. Simpan hashed PIN ke SharedPreferences

### 3.3 — `GetActiveSessionUseCase`

**File: `lib/domain/usecases/get_active_session_usecase.dart`**

| Input    | Output                  |
| -------- | ----------------------- |
| _(none)_ | `Either<Failure, bool>` |

**Logic:**

1. Query `sessions` table untuk session dengan status `open` pada tanggal hari ini
2. Return `true` jika ada, `false` jika tidak

### 3.4 — `LogoutUseCase`

**File: `lib/domain/usecases/logout_usecase.dart`**

| Input    | Output                  |
| -------- | ----------------------- |
| _(none)_ | `Either<Failure, void>` |

**Logic:**

1. Clear session token dari SharedPreferences
2. Clear session expiry
3. Preservasi data SQFlite (jangan hapus)
4. Preservasi sync queue

---

## Step 4: Buat Data Model

**File: `lib/data/models/cashier_model.dart`**

```dart
class CashierModel extends Cashier {
  const CashierModel({
    required super.id,
    required super.name,
  });

  factory CashierModel.fromJson(Map<String, dynamic> json) { ... }

  Map<String, dynamic> toJson() { ... }
}
```

---

## Step 5: Implementasi `AuthRepositoryImpl`

**File: `lib/data/repositories/auth_repository_impl.dart`**

**Dependencies (inject via constructor):**

- `AuthPreferencesDataSource`
- `DatabaseHelper` (untuk cek active session)

**Implementasi setiap method:**

| Method              | Detail                                                                    |
| ------------------- | ------------------------------------------------------------------------- |
| `verifyPin`         | Hash input → compare dengan stored hash → manage attempts → return result |
| `savePin`           | Validate → hash → save ke prefs                                           |
| `hasActiveSession`  | Query SQFlite `sessions` WHERE `status = 'open'` AND `opened_at` hari ini |
| `logout`            | Call `prefs.clearSession()`                                               |
| `getFailedAttempts` | Delegate ke `prefs.getFailedAttempts()`                                   |
| `isLockedOut`       | Cek `lockoutTimestamp` > now → return true/false                          |

**Penting:**

- Wrap semua operasi dalam try-catch
- Convert exceptions ke domain `Failure` types
- Jangan expose SharedPreferences atau SQFlite ke luar Data layer

---

## Step 6: Buat BLoC

### 6.1 — Events

**File: `lib/presentation/features/auth/bloc/auth_event.dart`**

```dart
abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

/// User menekan digit di PIN pad
class AuthPinDigitPressed extends AuthEvent {
  const AuthPinDigitPressed(this.digit);
  final String digit;
  @override
  List<Object> get props => [digit];
}

/// User menekan tombol delete di PIN pad
class AuthPinDeletePressed extends AuthEvent {
  const AuthPinDeletePressed();
  @override
  List<Object> get props => [];
}

/// User submit PIN (otomatis setelah digit terakhir atau tekan enter)
class AuthPinSubmitted extends AuthEvent {
  const AuthPinSubmitted();
  @override
  List<Object> get props => [];
}

/// Cek status session setelah login berhasil
class AuthSessionCheckRequested extends AuthEvent {
  const AuthSessionCheckRequested();
  @override
  List<Object> get props => [];
}

/// User request logout
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
  @override
  List<Object> get props => [];
}
```

### 6.2 — States

**File: `lib/presentation/features/auth/bloc/auth_state.dart`**

```dart
enum AuthStatus {
  initial,
  pinEntry,
  loading,
  authenticated,
  hasActiveSession,
  noActiveSession,
  failure,
  lockedOut,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.pinDigits = const [],
    this.cashier,
    this.failedAttempts = 0,
    this.errorMessage = '',
    this.lockoutRemainingSeconds = 0,
  });

  final AuthStatus status;
  final List<String> pinDigits;
  final Cashier? cashier;
  final int failedAttempts;
  final String errorMessage;
  final int lockoutRemainingSeconds;

  AuthState copyWith({ ... });

  @override
  List<Object?> get props => [
    status, pinDigits, cashier, failedAttempts,
    errorMessage, lockoutRemainingSeconds,
  ];
}
```

### 6.3 — BLoC

**File: `lib/presentation/features/auth/bloc/auth_bloc.dart`**

| Event                       | Handler Logic                                                                   |
| --------------------------- | ------------------------------------------------------------------------------- |
| `AuthPinDigitPressed`       | Append digit ke `pinDigits` (max 6), auto-submit jika sudah 6 digit             |
| `AuthPinDeletePressed`      | Remove last digit dari `pinDigits`                                              |
| `AuthPinSubmitted`          | Call `VerifyPinUseCase` → handle success/failure/lockout                        |
| `AuthSessionCheckRequested` | Call `GetActiveSessionUseCase` → emit `hasActiveSession` atau `noActiveSession` |
| `AuthLogoutRequested`       | Call `LogoutUseCase` → emit `initial`                                           |

**Lockout Logic:**

- Setelah 5 failed attempts → emit `lockedOut` state
- Simpan lockout timestamp via repository
- Timer countdown di state (`lockoutRemainingSeconds`)

### 6.4 — Barrel File

**File: `lib/presentation/features/auth/auth.dart`**

```dart
export 'bloc/auth_bloc.dart';
export 'bloc/auth_event.dart';
export 'bloc/auth_state.dart';
export 'pages/login_page.dart';
```

---

## Step 7: Buat UI

### 7.1 — `LoginPage` (DI Wiring)

**File: `lib/presentation/features/auth/pages/login_page.dart`**

```dart
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: const LoginView(),
    );
  }
}
```

### 7.2 — `LoginView` (UI + State Consumption)

**File: `lib/presentation/features/auth/pages/login_view.dart`**

| Komponen             | Behavior                                                     |
| -------------------- | ------------------------------------------------------------ |
| PIN Indicator (atas) | Menampilkan ●●●○○○ sesuai jumlah digit yang sudah dimasukkan |
| Error message        | Tampil jika PIN salah, atau info lockout                     |
| PIN Pad (bawah)      | Grid 3×4 tombol digit (1-9, 0, delete)                       |

**BlocListener:**

- `AuthStatus.authenticated` + `hasActiveSession` → navigate ke `/cashier`
- `AuthStatus.authenticated` + `noActiveSession` → navigate ke `/opening`
- `AuthStatus.failure` → tampilkan error di UI
- `AuthStatus.lockedOut` → tampilkan countdown timer

### 7.3 — `PinPadWidget`

**File: `lib/presentation/features/auth/widgets/pin_pad_widget.dart`**

- Grid 3 kolom × 4 baris
- Tombol: 1, 2, 3, 4, 5, 6, 7, 8, 9, (kosong), 0, ⌫
- Setiap tombol digit → dispatch `AuthPinDigitPressed(digit)`
- Tombol delete → dispatch `AuthPinDeletePressed()`
- Disable semua tombol saat `AuthStatus.loading` atau `AuthStatus.lockedOut`

### 7.4 — `PinIndicatorWidget`

**File: `lib/presentation/features/auth/widgets/pin_indicator_widget.dart`**

- Row of circles (○ / ●)
- Jumlah total circle = `AppConstants.pinMaxLength` (6)
- Filled circles = jumlah digit yang sudah dimasukkan
- Animasi shake saat PIN salah (opsional)

---

## Step 8: Register Dependencies

Tambahkan ke `lib/injection_container.dart`:

```dart
// ─── Auth ───
// Use Cases
sl.registerLazySingleton(() => VerifyPinUseCase(sl()));
sl.registerLazySingleton(() => SavePinUseCase(sl()));
sl.registerLazySingleton(() => GetActiveSessionUseCase(sl()));
sl.registerLazySingleton(() => LogoutUseCase(sl()));

// Repository
sl.registerLazySingleton<AuthRepository>(
  () => AuthRepositoryImpl(
    preferencesDataSource: sl(),
    databaseHelper: sl(),
  ),
);

// BLoC
sl.registerFactory(() => AuthBloc(
  verifyPinUseCase: sl(),
  getActiveSessionUseCase: sl(),
  logoutUseCase: sl(),
));
```

---

## Step 9: Tulis Unit Tests

### 9.1 — Use Case Tests

**File: `test/domain/usecases/verify_pin_usecase_test.dart`**

| Test Case                                    | Expected |
| -------------------------------------------- | -------- |
| PIN benar → return `Right(Cashier)`          | ✅       |
| PIN salah → return `Left(AuthFailure)`       | ✅       |
| Akun locked out → return `Left(AuthFailure)` | ✅       |
| Failed attempts increment setelah PIN salah  | ✅       |
| Failed attempts reset setelah PIN benar      | ✅       |

### 9.2 — Repository Tests

**File: `test/data/repositories/auth_repository_impl_test.dart`**

- Mock `AuthPreferencesDataSource` dan `DatabaseHelper`
- Test semua method di `AuthRepositoryImpl`

### 9.3 — BLoC Tests

**File: `test/presentation/features/auth/bloc/auth_bloc_test.dart`**

Gunakan `blocTest` dari `bloc_test` package:

| Test Case               | Events                                  | Expected States                                                      |
| ----------------------- | --------------------------------------- | -------------------------------------------------------------------- |
| Initial state           | -                                       | `AuthState()`                                                        |
| Digit pressed           | `AuthPinDigitPressed('1')`              | state dengan `pinDigits: ['1']`                                      |
| Delete pressed          | setelah 2 digit, `AuthPinDeletePressed` | 1 digit tersisa                                                      |
| PIN benar               | 6 digit → auto submit                   | `loading` → `authenticated` → `hasActiveSession` / `noActiveSession` |
| PIN salah               | 6 digit salah                           | `loading` → `failure` dengan error message                           |
| Lockout setelah 5 gagal | 5× PIN salah                            | `lockedOut` state                                                    |
| Logout                  | `AuthLogoutRequested`                   | `initial` state                                                      |

---

## Step 10: Tulis Widget Tests

**File: `test/presentation/features/auth/pages/login_page_test.dart`**

| Test Case                              | Expected |
| -------------------------------------- | -------- |
| Render PIN pad dengan 12 tombol        | ✅       |
| Tap digit menampilkan filled indicator | ✅       |
| PIN salah menampilkan error message    | ✅       |
| Lockout menampilkan countdown          | ✅       |
| Loading state menampilkan indicator    | ✅       |

Gunakan `MockAuthBloc` dari `mocktail` + `tester.pumpApp()` helper.

---

## Definition of Done — Phase 2

- [ ] User bisa login dengan PIN 4-6 digit
- [ ] PIN salah menampilkan error dan increment counter
- [ ] Setelah 5 gagal, app terkunci selama durasi yang dikonfigurasi
- [ ] Login berhasil → redirect ke Opening Balance (jika belum ada session) atau Cashier (jika session aktif)
- [ ] Logout menghapus session dan kembali ke PIN screen
- [ ] Semua use case ter-unit-test
- [ ] BLoC ter-unit-test dengan `blocTest`
- [ ] Widget test untuk LoginPage
- [ ] `flutter analyze` clean, `flutter test` pass
