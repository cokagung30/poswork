# Phase 3 — Session Lifecycle

> Opening balance dan session closing flows.

**Prasyarat:** Phase 2 (Authentication) selesai.

---

## Checklist Overview

- [ ] Step 1: Buat Entity `Session`
- [ ] Step 2: Buat abstract Repository `SessionRepository`
- [ ] Step 3: Buat Use Cases (`OpenSessionUseCase`, `CloseSessionUseCase`, `GetActiveSessionUseCase`)
- [ ] Step 4: Buat Data Model `SessionModel`
- [ ] Step 5: Implementasi `SessionLocalDataSource`
- [ ] Step 6: Implementasi `SessionRepositoryImpl`
- [ ] Step 7: Buat `OpeningBloc` (Events, States, BLoC)
- [ ] Step 8: Buat `ClosingBloc` (Events, States, BLoC)
- [ ] Step 9: Buat UI Opening (`OpeningPage`, `OpeningView`)
- [ ] Step 10: Buat UI Closing (`ClosingPage`, `ClosingView`, `ClosingResultPage`)
- [ ] Step 11: Implementasi PDF generation untuk Closing Report
- [ ] Step 12: Register semua dependency di `injection_container.dart`
- [ ] Step 13: Tulis Unit Tests
- [ ] Step 14: Tulis Widget Tests

---

## Step 1: Buat Entity `Session`

**File: `lib/domain/entities/session.dart`**

```dart
class Session extends Equatable {
  const Session({
    required this.sessionId,
    required this.cashierId,
    required this.openedAt,
    required this.openingBalance,
    required this.status,
    this.closedAt,
    this.closingBalance,
    this.expectedCash,
    this.variance,
    this.totalCashSales = 0,
    this.totalQrisSales = 0,
    this.totalOrders = 0,
    this.synced = false,
    this.syncedAt,
  });

  final String sessionId;
  final String cashierId;
  final DateTime openedAt;
  final DateTime? closedAt;
  final double openingBalance;
  final double? closingBalance;
  final double? expectedCash;
  final double? variance;
  final double totalCashSales;
  final double totalQrisSales;
  final int totalOrders;
  final String status; // 'open' | 'closed'
  final bool synced;
  final DateTime? syncedAt;

  @override
  List<Object?> get props => [ ... ];
}
```

---

## Step 2: Buat Abstract Repository

**File: `lib/domain/repositories/session_repository.dart`**

```dart
abstract class SessionRepository {
  /// Buat session baru dengan opening balance
  Future<Either<Failure, Session>> openSession({
    required String cashierId,
    required double openingBalance,
  });

  /// Ambil session aktif (status = 'open') hari ini
  Future<Either<Failure, Session?>> getActiveSession();

  /// Tutup session dengan closing data
  Future<Either<Failure, Session>> closeSession({
    required String sessionId,
    required double closingBalance,
  });

  /// Ambil summary session untuk closing
  Future<Either<Failure, SessionSummary>> getSessionSummary(String sessionId);
}
```

> Buat juga value object `SessionSummary` di domain/entities jika perlu, berisi:
> `openingBalance`, `totalCashSales`, `totalQrisSales`, `expectedCash`, `totalOrders`

---

## Step 3: Buat Use Cases

### 3.1 — `OpenSessionUseCase`

**File: `lib/domain/usecases/open_session_usecase.dart`**

| Input                         | Output                     |
| ----------------------------- | -------------------------- |
| `cashierId`, `openingBalance` | `Either<Failure, Session>` |

**Logic:**

1. Validasi `openingBalance >= 0`
2. Cek apakah sudah ada session open hari ini → jika iya, return `Failure`
3. Generate `session_id` (UUID)
4. Simpan ke SQFlite via repository
5. Return `Session` yang baru dibuat

### 3.2 — `CloseSessionUseCase`

**File: `lib/domain/usecases/close_session_usecase.dart`**

| Input                         | Output                     |
| ----------------------------- | -------------------------- |
| `sessionId`, `closingBalance` | `Either<Failure, Session>` |

**Logic:**

1. Ambil session by ID → pastikan status `open`
2. Hitung `expectedCash` = `openingBalance + totalCashSales`
3. Hitung `variance` = `closingBalance - expectedCash`
4. Update session di SQFlite: status → `closed`, isi semua closing fields
5. Trigger sync all pending records (best effort)
6. Return updated `Session`

### 3.3 — `GetActiveSessionUseCase` (extend dari Phase 2)

**File: `lib/domain/usecases/get_active_session_usecase.dart`**

| Input    | Output                      |
| -------- | --------------------------- |
| _(none)_ | `Either<Failure, Session?>` |

**Logic:**

1. Query `sessions` WHERE `status = 'open'` AND `opened_at` >= hari ini 00:00
2. Return `Session` jika ada, `null` jika tidak

---

## Step 4: Buat Data Model

**File: `lib/data/models/session_model.dart`**

```dart
class SessionModel extends Session {
  const SessionModel({ ... });

  /// Dari SQFlite row
  factory SessionModel.fromMap(Map<String, dynamic> map) { ... }

  /// Ke SQFlite row
  Map<String, dynamic> toMap() { ... }

  /// Dari Firestore document
  factory SessionModel.fromFirestore(Map<String, dynamic> doc) { ... }

  /// Ke Firestore document
  Map<String, dynamic> toFirestore() { ... }
}
```

**Penting:**

- Unix timestamp ↔ DateTime conversion di `fromMap`/`toMap`
- `synced` sebagai `int` di DB (0/1), `bool` di domain
- Semua column names referensi dari `DbConstants`

---

## Step 5: Implementasi `SessionLocalDataSource`

**File: `lib/data/datasources/local/sqflite/session_local_datasource.dart`**

| Method                         | SQL                                                                  | Deskripsi                    |
| ------------------------------ | -------------------------------------------------------------------- | ---------------------------- |
| `insertSession(SessionModel)`  | `INSERT INTO sessions ...`                                           | Buat session baru            |
| `getActiveSession()`           | `SELECT * FROM sessions WHERE status = 'open' AND opened_at >= ?`    | Ambil session aktif hari ini |
| `getSessionById(String id)`    | `SELECT * FROM sessions WHERE session_id = ?`                        | Ambil session by ID          |
| `updateSession(SessionModel)`  | `UPDATE sessions SET ... WHERE session_id = ?`                       | Update session (closing)     |
| `getUnsyncedSessions()`        | `SELECT * FROM sessions WHERE synced = 0`                            | Untuk sync queue             |
| `markSessionSynced(String id)` | `UPDATE sessions SET synced = 1, synced_at = ? WHERE session_id = ?` | Setelah sync berhasil        |

**Rules:**

- Gunakan `DatabaseHelper.database` untuk akses DB
- Semua operasi async
- Throw `CacheException` jika operasi gagal

---

## Step 6: Implementasi `SessionRepositoryImpl`

**File: `lib/data/repositories/session_repository_impl.dart`**

**Dependencies:**

- `SessionLocalDataSource`
- `DatabaseHelper` (untuk query orders aggregate)

**Implementasi setiap method:**

| Method              | Detail                                                                            |
| ------------------- | --------------------------------------------------------------------------------- |
| `openSession`       | Generate UUID → create `SessionModel` → insert ke SQFlite                         |
| `getActiveSession`  | Delegate ke datasource → convert ke entity                                        |
| `closeSession`      | Get summary → calculate expected & variance → update session                      |
| `getSessionSummary` | Aggregate query pada `orders` table: SUM cash sales, SUM QRIS sales, COUNT orders |

**Query Aggregate untuk Summary:**

```sql
SELECT
  COALESCE(SUM(CASE WHEN payment_method = 'cash' AND status = 'completed' THEN grand_total ELSE 0 END), 0) AS total_cash_sales,
  COALESCE(SUM(CASE WHEN payment_method = 'qris' AND status = 'completed' THEN grand_total ELSE 0 END), 0) AS total_qris_sales,
  COUNT(CASE WHEN status = 'completed' THEN 1 END) AS total_orders
FROM orders
WHERE session_id = ?
```

---

## Step 7: Buat `OpeningBloc`

### 7.1 — Events

**File: `lib/presentation/features/opening/bloc/opening_event.dart`**

```dart
class OpeningBalanceChanged extends OpeningEvent {
  const OpeningBalanceChanged(this.amount);
  final String amount; // raw text input
}

class OpeningBalanceSubmitted extends OpeningEvent {
  const OpeningBalanceSubmitted();
}
```

### 7.2 — States

**File: `lib/presentation/features/opening/bloc/opening_state.dart`**

```dart
enum OpeningStatus { initial, loading, success, failure }

class OpeningState extends Equatable {
  const OpeningState({
    this.status = OpeningStatus.initial,
    this.balanceInput = '',
    this.errorMessage = '',
    this.session,
  });

  final OpeningStatus status;
  final String balanceInput;
  final String errorMessage;
  final Session? session;
}
```

### 7.3 — BLoC

**File: `lib/presentation/features/opening/bloc/opening_bloc.dart`**

| Event                     | Handler Logic                                               |
| ------------------------- | ----------------------------------------------------------- |
| `OpeningBalanceChanged`   | Update `balanceInput` di state                              |
| `OpeningBalanceSubmitted` | Validate → call `OpenSessionUseCase` → emit success/failure |

### 7.4 — Barrel File

**File: `lib/presentation/features/opening/opening.dart`**

---

## Step 8: Buat `ClosingBloc`

### 8.1 — Events

**File: `lib/presentation/features/closing/bloc/closing_event.dart`**

```dart
class ClosingDataRequested extends ClosingEvent {} // Load session summary
class ClosingBalanceChanged extends ClosingEvent { final String amount; }
class ClosingPinSubmitted extends ClosingEvent { final String pin; }
class ClosingConfirmed extends ClosingEvent {}
class ClosingReportExportRequested extends ClosingEvent {}
```

### 8.2 — States

**File: `lib/presentation/features/closing/bloc/closing_state.dart`**

```dart
enum ClosingStatus { initial, loading, summaryLoaded, pinVerification, closing, closed, failure }

class ClosingState extends Equatable {
  final ClosingStatus status;
  final Session? session;
  final SessionSummary? summary;
  final String closingBalanceInput;
  final double? expectedCash;
  final double? variance;
  final String errorMessage;
}
```

### 8.3 — BLoC

**File: `lib/presentation/features/closing/bloc/closing_bloc.dart`**

| Event                          | Handler Logic                                                               |
| ------------------------------ | --------------------------------------------------------------------------- |
| `ClosingDataRequested`         | Call `GetActiveSessionUseCase` + `GetSessionSummary` → emit `summaryLoaded` |
| `ClosingBalanceChanged`        | Update input, recalculate expected vs actual                                |
| `ClosingPinSubmitted`          | Re-verify PIN sebelum closing                                               |
| `ClosingConfirmed`             | Call `CloseSessionUseCase` → emit `closed`                                  |
| `ClosingReportExportRequested` | Generate PDF → share                                                        |

### 8.4 — Barrel File

**File: `lib/presentation/features/closing/closing.dart`**

---

## Step 9: Buat UI Opening

### 9.1 — `OpeningPage`

**File: `lib/presentation/features/opening/pages/opening_page.dart`**

- Provides `OpeningBloc` via `BlocProvider`
- Child: `OpeningView`

### 9.2 — `OpeningView`

**File: `lib/presentation/features/opening/pages/opening_view.dart`**

**Layout:**

1. Header: "Saldo Awal Kas"
2. Input field: numeric keyboard, mata uang format (Rp)
3. Info text: "Masukkan jumlah uang tunai di laci kas"
4. Tombol "Buka Sesi" (disabled jika input kosong/invalid)

**BlocListener:**

- `OpeningStatus.success` → navigate ke `/cashier`
- `OpeningStatus.failure` → tampilkan error snackbar

**Confirmation Dialog:**

- Sebelum submit, tampilkan dialog: "Buka sesi dengan saldo awal Rp xxx.xxx?"
- Tombol "Batal" dan "Konfirmasi"

---

## Step 10: Buat UI Closing

### 10.1 — `ClosingPage`

**File: `lib/presentation/features/closing/pages/closing_page.dart`**

- Provides `ClosingBloc` via `BlocProvider`
- Dispatch `ClosingDataRequested` on init

### 10.2 — `ClosingView`

**File: `lib/presentation/features/closing/pages/closing_view.dart`**

**Layout:**

1. **Session Summary Card:**
   - Saldo awal: Rp xxx.xxx
   - Total penjualan tunai: Rp xxx.xxx
   - Total penjualan QRIS: Rp xxx.xxx
   - Kas yang diharapkan: Rp xxx.xxx (opening + cash sales)
   - Total transaksi: xx
2. **Input Kas Aktual:**
   - Field: "Masukkan jumlah kas fisik"
   - Realtime display: Selisih (lebih/kurang)
3. **Tombol "Tutup Sesi"**

**Flow:**

1. Tap "Tutup Sesi" → tampilkan PIN re-entry dialog
2. PIN valid → tampilkan confirmation dialog dengan summary
3. Confirm → close session → navigate ke `ClosingResultPage`

### 10.3 — `ClosingResultPage`

**File: `lib/presentation/features/closing/pages/closing_result_page.dart`**

**Layout — tampilkan Closing Report:**

- Tanggal & ID Sesi
- Nama / ID Kasir
- Saldo awal
- Total transaksi
- Total penjualan per metode (Cash, QRIS)
- Kas yang diharapkan
- Kas aktual
- Selisih (lebih / kurang) — highlight merah jika kurang
- Jam buka & tutup sesi

**Actions:**

- Tombol "Bagikan" → share via share sheet (PDF/image)
- Tombol "Selesai" → navigate ke Login screen (logout)

---

## Step 11: Implementasi PDF Generation

**File: `lib/data/services/closing_report_pdf_service.dart`** (atau utility)

**Input:** `Session` + `SessionSummary`  
**Output:** `Uint8List` (PDF bytes)

**Konten PDF:**

- Header: Nama toko, tanggal
- Semua data yang ada di Closing Report (Step 10.3)
- Footer: generated timestamp

**Share:**

- Gunakan `printing` package untuk preview/print
- Gunakan `share_plus` untuk share file PDF

---

## Step 12: Register Dependencies

Tambahkan ke `lib/injection_container.dart`:

```dart
// ─── Session ───
// Data Sources
sl.registerLazySingleton(() => SessionLocalDataSource(sl()));

// Repository
sl.registerLazySingleton<SessionRepository>(
  () => SessionRepositoryImpl(
    localDataSource: sl(),
    databaseHelper: sl(),
  ),
);

// Use Cases
sl.registerLazySingleton(() => OpenSessionUseCase(sl()));
sl.registerLazySingleton(() => CloseSessionUseCase(sl()));

// BLoCs
sl.registerFactory(() => OpeningBloc(openSessionUseCase: sl()));
sl.registerFactory(() => ClosingBloc(
  getActiveSessionUseCase: sl(),
  closeSessionUseCase: sl(),
  verifyPinUseCase: sl(),
));
```

---

## Step 13: Tulis Unit Tests

### 13.1 — Use Case Tests

**`test/domain/usecases/open_session_usecase_test.dart`**

| Test Case                                           | Expected |
| --------------------------------------------------- | -------- |
| Opening balance valid → return `Right(Session)`     | ✅       |
| Opening balance negative → return `Left(Failure)`   | ✅       |
| Session sudah ada hari ini → return `Left(Failure)` | ✅       |

**`test/domain/usecases/close_session_usecase_test.dart`**

| Test Case                                                           | Expected |
| ------------------------------------------------------------------- | -------- |
| Close session valid → return updated `Session` with status `closed` | ✅       |
| Session tidak ditemukan → return `Left(Failure)`                    | ✅       |
| Session sudah closed → return `Left(Failure)`                       | ✅       |
| Variance dihitung dengan benar                                      | ✅       |

### 13.2 — DataSource Tests

**`test/data/datasources/local/sqflite/session_local_datasource_test.dart`**

| Test Case                                         | Expected |
| ------------------------------------------------- | -------- |
| Insert session → data tersimpan                   | ✅       |
| Get active session → return session open hari ini | ✅       |
| Get active session → return null jika tidak ada   | ✅       |
| Update session → data terupdate                   | ✅       |

### 13.3 — Repository Tests

**`test/data/repositories/session_repository_impl_test.dart`**

- Mock `SessionLocalDataSource`
- Test semua method

### 13.4 — BLoC Tests

**`test/presentation/features/opening/bloc/opening_bloc_test.dart`**

| Test Case                 | Events                           | Expected States         |
| ------------------------- | -------------------------------- | ----------------------- |
| Initial state             | -                                | `OpeningState()`        |
| Balance changed           | `OpeningBalanceChanged('50000')` | state with balanceInput |
| Submit success            | `OpeningBalanceSubmitted`        | `loading` → `success`   |
| Submit failure (negative) | `OpeningBalanceSubmitted`        | `loading` → `failure`   |

**`test/presentation/features/closing/bloc/closing_bloc_test.dart`**

| Test Case                | Events                 | Expected States             |
| ------------------------ | ---------------------- | --------------------------- |
| Load summary             | `ClosingDataRequested` | `loading` → `summaryLoaded` |
| Close session            | full flow              | `closing` → `closed`        |
| PIN invalid saat closing | `ClosingPinSubmitted`  | `failure`                   |

---

## Step 14: Tulis Widget Tests

**`test/presentation/features/opening/pages/opening_page_test.dart`**

| Test Case                              | Expected |
| -------------------------------------- | -------- |
| Render input field dan tombol          | ✅       |
| Tombol disabled saat input kosong      | ✅       |
| Submit menampilkan confirmation dialog | ✅       |
| Success navigasi ke cashier            | ✅       |

**`test/presentation/features/closing/pages/closing_page_test.dart`**

| Test Case                                  | Expected |
| ------------------------------------------ | -------- |
| Render session summary                     | ✅       |
| Input closing balance menampilkan variance | ✅       |
| Tutup sesi meminta PIN                     | ✅       |
| Closing result menampilkan report          | ✅       |

---

## Definition of Done — Phase 3

- [ ] Opening Balance flow berfungsi end-to-end
- [ ] Hanya 1 session per hari per device
- [ ] Closing flow menampilkan summary yang akurat
- [ ] Variance (selisih) dihitung dan ditampilkan dengan benar
- [ ] PIN re-entry diperlukan untuk closing
- [ ] Closing report bisa di-export sebagai PDF dan di-share
- [ ] Session tersimpan di SQFlite dengan `synced = false`
- [ ] Navigasi: Login → Opening → Cashier → Closing → Result → Login
- [ ] Semua use case, repository, dan BLoC ter-unit-test
- [ ] Widget test untuk Opening dan Closing pages
- [ ] `flutter analyze` clean, `flutter test` pass
