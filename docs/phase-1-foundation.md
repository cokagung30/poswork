# Phase 1 — Foundation

> Setup project scaffolding, architecture skeleton, and local database.

---

## Checklist Overview

- [ ] Step 1: Scaffold project with Very Good CLI
- [ ] Step 2: Configure flavors (dev, staging, production)
- [ ] Step 3: Set up Clean Architecture folder structure
- [ ] Step 4: Set up core layer (constants, errors, theme, utils)
- [ ] Step 5: Implement `DatabaseHelper` with full schema
- [ ] Step 6: Implement `AuthPreferencesDataSource`
- [ ] Step 7: Configure Firebase and Firestore collections
- [ ] Step 8: Set up `GetIt` dependency injection container
- [ ] Step 9: Implement `SyncManager` skeleton with connectivity detection
- [ ] Step 10: Set up routing skeleton
- [ ] Step 11: Add required dependencies to `pubspec.yaml`

---

## Step 1: Scaffold Project with Very Good CLI

> Skip jika project sudah di-scaffold.

```bash
very_good create flutter_app poswork --org com.baliwork.pos
```

**Verify:**

- [ ] `lib/main_development.dart`, `lib/main_staging.dart`, `lib/main_production.dart` ada
- [ ] `analysis_options.yaml` menggunakan `very_good_analysis`
- [ ] `flutter test` berjalan tanpa error

---

## Step 2: Configure Flavors

> Skip jika flavor sudah dikonfigurasi oleh Very Good CLI.

**Files yang harus ada:**

| File                           | Keterangan                       |
| ------------------------------ | -------------------------------- |
| `lib/main_development.dart`    | Entry point flavor `development` |
| `lib/main_staging.dart`        | Entry point flavor `staging`     |
| `lib/main_production.dart`     | Entry point flavor `production`  |
| `android/app/src/development/` | Android flavor config (`.dev`)   |
| `android/app/src/staging/`     | Android flavor config (`.stg`)   |
| `android/app/build.gradle.kts` | `productFlavors` block           |

**Verify:**

- [ ] `flutter run --flavor development --target lib/main_development.dart` berhasil
- [ ] `flutter run --flavor staging --target lib/main_staging.dart` berhasil
- [ ] `flutter run --flavor production --target lib/main_production.dart` berhasil

---

## Step 3: Set Up Clean Architecture Folder Structure

Buat seluruh folder structure berikut di `lib/`:

```
lib/
├── app/
│   ├── app.dart
│   └── view/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── theme/
│   └── utils/
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── sqflite/
│   │   │   └── preferences/
│   │   └── remote/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── features/
│   └── shared/
│       └── widgets/
├── injection_container.dart
└── bootstrap.dart
```

**Sub-steps:**

1. Buat semua folder di atas (kosong dulu, yang belum ada)
2. Tambahkan placeholder `.gitkeep` di folder kosong jika perlu
3. Pastikan `injection_container.dart` dan `bootstrap.dart` sudah ada

---

## Step 4: Set Up Core Layer

### 4.1 — Constants

**File: `lib/core/constants/app_constants.dart`**

```dart
abstract class AppConstants {
  static const int pinMinLength = 4;
  static const int pinMaxLength = 6;
  static const int maxFailedAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 5);
  static const Duration sessionTimeout = Duration(hours: 24);
}
```

**File: `lib/core/constants/db_constants.dart`**

```dart
abstract class DbConstants {
  static const String databaseName = 'poswork.db';
  static const int databaseVersion = 1;

  // Table names
  static const String tableSessions = 'sessions';
  static const String tableOrders = 'orders';
  static const String tableOrderItems = 'order_items';
  static const String tableProducts = 'products';

  // sessions columns
  static const String colSessionId = 'session_id';
  static const String colCashierId = 'cashier_id';
  static const String colOpenedAt = 'opened_at';
  static const String colClosedAt = 'closed_at';
  static const String colOpeningBalance = 'opening_balance';
  static const String colClosingBalance = 'closing_balance';
  static const String colExpectedCash = 'expected_cash';
  static const String colVariance = 'variance';
  static const String colTotalCashSales = 'total_cash_sales';
  static const String colTotalQrisSales = 'total_qris_sales';
  static const String colTotalOrders = 'total_orders';
  static const String colStatus = 'status';
  static const String colSynced = 'synced';
  static const String colSyncedAt = 'synced_at';

  // orders columns
  static const String colOrderId = 'order_id';
  static const String colCreatedAt = 'created_at';
  static const String colTotalAmount = 'total_amount';
  static const String colDiscountAmount = 'discount_amount';
  static const String colGrandTotal = 'grand_total';
  static const String colPaymentMethod = 'payment_method';
  static const String colAmountTendered = 'amount_tendered';
  static const String colChangeAmount = 'change_amount';

  // order_items columns
  static const String colOrderItemId = 'order_item_id';
  static const String colProductId = 'product_id';
  static const String colProductName = 'product_name';
  static const String colUnitPrice = 'unit_price';
  static const String colQuantity = 'quantity';
  static const String colSubtotal = 'subtotal';

  // products columns
  static const String colName = 'name';
  static const String colSku = 'sku';
  static const String colCategory = 'category';
  static const String colPrice = 'price';
  static const String colImageUrl = 'image_url';
  static const String colIsActive = 'is_active';
  static const String colUpdatedAt = 'updated_at';
}
```

**File: `lib/core/constants/firebase_constants.dart`**

```dart
abstract class FirebaseConstants {
  static const String collSessions = 'sessions';
  static const String collOrders = 'orders';
  static const String collOrderItems = 'order_items';
}
```

### 4.2 — Errors

**File: `lib/core/errors/exceptions.dart`**

```dart
class ServerException implements Exception {
  const ServerException([this.message]);
  final String? message;
}

class CacheException implements Exception {
  const CacheException([this.message]);
  final String? message;
}

class AuthException implements Exception {
  const AuthException([this.message]);
  final String? message;
}
```

**File: `lib/core/errors/failures.dart`**

```dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([this.message = '']);
  final String message;

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message]);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message]);
}
```

### 4.3 — Network

**File: `lib/core/network/network_info.dart`**

```dart
abstract class NetworkInfo {
  Future<bool> get isConnected;
}
```

### 4.4 — Theme

**File: `lib/core/theme/app_colors.dart`**

- Definisikan color palette untuk aplikasi POS

**File: `lib/core/theme/app_theme.dart`**

- `ThemeData` untuk Material 3 (light mode sebagai default)

### 4.5 — Utils

**File: `lib/core/utils/validators.dart`**

- `validatePin(String pin)` — validasi panjang dan format PIN

**Verify:**

- [ ] Semua file core terbuat tanpa compile error
- [ ] `flutter analyze` clean

---

## Step 5: Implement `DatabaseHelper` with Full Schema

**File: `lib/data/datasources/local/sqflite/database_helper.dart`**

Implementasikan:

1. Singleton pattern untuk `DatabaseHelper`
2. `_onCreate` — buat 4 tabel: `sessions`, `orders`, `order_items`, `products`
3. `_onUpgrade` — placeholder untuk migrasi masa depan
4. Semua nama tabel dan kolom referensi dari `DbConstants`

**Schema SQL (sesuai master plan):**

```sql
-- sessions
CREATE TABLE sessions (
  session_id TEXT PRIMARY KEY,
  cashier_id TEXT NOT NULL,
  opened_at INTEGER NOT NULL,
  closed_at INTEGER,
  opening_balance REAL NOT NULL,
  closing_balance REAL,
  expected_cash REAL,
  variance REAL,
  total_cash_sales REAL DEFAULT 0,
  total_qris_sales REAL DEFAULT 0,
  total_orders INTEGER DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'open',
  synced INTEGER NOT NULL DEFAULT 0,
  synced_at INTEGER
);

-- orders
CREATE TABLE orders (
  order_id TEXT PRIMARY KEY,
  session_id TEXT NOT NULL,
  cashier_id TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  total_amount REAL NOT NULL,
  discount_amount REAL DEFAULT 0,
  grand_total REAL NOT NULL,
  payment_method TEXT,
  amount_tendered REAL,
  change_amount REAL,
  status TEXT NOT NULL DEFAULT 'pending',
  synced INTEGER NOT NULL DEFAULT 0,
  synced_at INTEGER,
  FOREIGN KEY (session_id) REFERENCES sessions (session_id)
);

-- order_items
CREATE TABLE order_items (
  order_item_id TEXT PRIMARY KEY,
  order_id TEXT NOT NULL,
  product_id TEXT NOT NULL,
  product_name TEXT NOT NULL,
  unit_price REAL NOT NULL,
  quantity INTEGER NOT NULL,
  discount_amount REAL DEFAULT 0,
  subtotal REAL NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders (order_id)
);

-- products
CREATE TABLE products (
  product_id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  sku TEXT,
  category TEXT,
  price REAL NOT NULL,
  image_url TEXT,
  is_active INTEGER NOT NULL DEFAULT 1,
  updated_at INTEGER
);
```

**Verify:**

- [ ] Unit test: database bisa dibuat dan semua tabel terinisialisasi
- [ ] Unit test: versi database = 1

---

## Step 6: Implement `AuthPreferencesDataSource`

**File: `lib/data/datasources/local/preferences/auth_preferences_datasource.dart`**

Metode yang harus diimplementasikan:

| Method                                             | Deskripsi                            |
| -------------------------------------------------- | ------------------------------------ |
| `Future<void> saveHashedPin(String hashedPin)`     | Simpan hashed PIN                    |
| `Future<String?> getHashedPin()`                   | Ambil hashed PIN                     |
| `Future<void> saveSessionToken(String token)`      | Simpan session token                 |
| `Future<String?> getSessionToken()`                | Ambil session token                  |
| `Future<void> saveSessionExpiry(int timestamp)`    | Simpan waktu expiry                  |
| `Future<int?> getSessionExpiry()`                  | Ambil waktu expiry                   |
| `Future<void> saveFailedAttempts(int count)`       | Simpan jumlah gagal login            |
| `Future<int> getFailedAttempts()`                  | Ambil jumlah gagal login (default 0) |
| `Future<void> saveLockoutTimestamp(int timestamp)` | Simpan waktu lockout                 |
| `Future<int?> getLockoutTimestamp()`               | Ambil waktu lockout                  |
| `Future<void> clearSession()`                      | Hapus session token & expiry         |
| `Future<void> resetFailedAttempts()`               | Reset failed attempts ke 0           |

**Rules:**

- Semua key sebagai `static const String` private di dalam class
- Tidak menyimpan data sensitif (PIN plain text, password)

**Verify:**

- [ ] Unit test untuk setiap method (save & retrieve)
- [ ] Unit test `clearSession` menghapus token & expiry

---

## Step 7: Configure Firebase and Firestore Collections

### 7.1 — Firebase Setup

1. Buat Firebase project atau gunakan existing project
2. Tambahkan Android & iOS apps ke Firebase Console
3. Download `google-services.json` → `android/app/`
4. Download `GoogleService-Info.plist` → `ios/Runner/`
5. Jalankan `flutterfire configure` jika menggunakan FlutterFire CLI

### 7.2 — Firestore Collections

Buat collections berikut di Firebase Console (atau biarkan auto-create saat pertama kali sync):

| Collection    | Document ID     | Keterangan                    |
| ------------- | --------------- | ----------------------------- |
| `sessions`    | `session_id`    | 1 doc per sesi kasir          |
| `orders`      | `order_id`      | 1 doc per transaksi           |
| `order_items` | `order_item_id` | 1 doc per item di dalam order |

### 7.3 — Firestore Security Rules (basic)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /sessions/{sessionId} {
      allow read, write: if request.auth != null;
    }
    match /orders/{orderId} {
      allow read, write: if request.auth != null;
    }
    match /order_items/{itemId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**Verify:**

- [ ] `firebase_core` terinisialisasi di `bootstrap.dart`
- [ ] App bisa run tanpa crash terkait Firebase

---

## Step 8: Set Up `GetIt` Dependency Injection

**File: `lib/injection_container.dart`**

Registrasi awal (skeleton):

```dart
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ─── Core ───
  // sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(...));

  // ─── Data Sources ───
  // sl.registerLazySingleton<AuthPreferencesDataSource>(() => ...);
  // sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());

  // ─── Repositories ───

  // ─── Use Cases ───

  // ─── BLoCs ───
}
```

**Sub-steps:**

1. Register `DatabaseHelper` sebagai singleton
2. Register `AuthPreferencesDataSource`
3. Register `NetworkInfo` implementation
4. Panggil `initDependencies()` di `bootstrap.dart` sebelum `runApp`

**Verify:**

- [ ] App bisa run setelah DI container diinisialisasi
- [ ] Tidak ada circular dependency error

---

## Step 9: Implement `SyncManager` Skeleton

**File: `lib/data/datasources/remote/sync_manager.dart`**

Skeleton implementation:

```dart
class SyncManager {
  // Subscribe to connectivity changes
  // When online → process sync queue
  // Priority: sessions → orders → order_items

  Future<void> startListening() async { /* TODO */ }
  Future<void> stopListening() async { /* TODO */ }
  Future<void> syncAll() async { /* TODO */ }
}
```

Logika lengkap akan diimplementasi di **Phase 6**. Saat ini cukup buat skeleton class agar DI bisa diregister.

**Verify:**

- [ ] Class bisa di-import tanpa error
- [ ] Teregistrasi di `injection_container.dart`

---

## Step 10: Set Up Routing Skeleton

**File: `lib/app/routes/app_router.dart`** (atau di `lib/app/view/`)

Definisikan route map sesuai master plan:

| Route Name       | Path              |
| ---------------- | ----------------- |
| `login`          | `/`               |
| `opening`        | `/opening`        |
| `cashier`        | `/cashier`        |
| `order_history`  | `/history`        |
| `order_detail`   | `/history/:id`    |
| `closing`        | `/closing`        |
| `closing_result` | `/closing/result` |

Gunakan `go_router` atau `Navigator 2.0` sesuai preferensi.

**Sub-steps:**

1. Buat file router dengan semua route definition
2. Buat placeholder page untuk setiap route (empty `Scaffold` dengan nama route)
3. Integrate router ke `MaterialApp` di `app.dart`

**Verify:**

- [ ] Navigasi antar route berfungsi
- [ ] Tidak ada route yang 404

---

## Step 11: Add Required Dependencies

Pastikan `pubspec.yaml` memiliki semua dependency berikut:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.x
  bloc: ^8.x
  equatable: ^2.x
  get_it: ^7.x
  sqflite: ^2.x
  shared_preferences: ^2.x
  firebase_core: ^2.x
  cloud_firestore: ^4.x
  connectivity_plus: ^5.x
  crypto: ^3.x
  uuid: ^4.x
  pdf: ^3.x
  printing: ^5.x
  share_plus: ^7.x

dev_dependencies:
  very_good_analysis: ^5.x
  bloc_test: ^9.x
  mocktail: ^1.x
  bloc_lint: ^1.x
```

Jalankan `flutter pub get` dan pastikan tidak ada conflict.

**Verify:**

- [ ] `flutter pub get` berhasil
- [ ] `flutter analyze` clean
- [ ] `flutter test` pass (semua existing test)

---

## Definition of Done — Phase 1

- [ ] Project bisa di-build di semua 3 flavors
- [ ] Folder structure Clean Architecture lengkap
- [ ] Database SQFlite terbuat dengan 4 tabel dan schema benar
- [ ] `AuthPreferencesDataSource` berfungsi dan ter-unit-test
- [ ] Firebase terinisialisasi tanpa crash
- [ ] DI container terkonfigurasi dengan semua dependencies awal
- [ ] `SyncManager` skeleton teregistrasi
- [ ] Routing skeleton terdefinisi dengan placeholder pages
- [ ] `flutter analyze` clean, `flutter test` pass
