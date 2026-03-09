# Phase 6 — Sync & Offline Hardening

> Firestore sync lengkap, offline resilience, dan edge case handling.

**Prasyarat:** Phase 5 (Order History) selesai.

---

## Checklist Overview

- [ ] Step 1: Implementasi `NetworkInfoImpl`
- [ ] Step 2: Implementasi `SessionRemoteDataSource`
- [ ] Step 3: Implementasi `OrderRemoteDataSource`
- [ ] Step 4: Complete `SyncManager` dengan full logic
- [ ] Step 5: Update Repository Implementations untuk sync
- [ ] Step 6: Buat `SyncStatusBadgeWidget`
- [ ] Step 7: Integrasikan sync ke UI
- [ ] Step 8: Handle edge cases dan error scenarios
- [ ] Step 9: Register semua dependency di `injection_container.dart`
- [ ] Step 10: Tulis Unit Tests
- [ ] Step 11: Tulis Integration Tests (Offline → Online cycle)

---

## Step 1: Implementasi `NetworkInfoImpl`

**File: `lib/data/datasources/network/network_info_impl.dart`**

```dart
class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl(this._connectivity);

  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.mobile) ||
           result.contains(ConnectivityResult.wifi);
  }

  /// Stream untuk monitoring perubahan koneksi
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((results) {
      return results.contains(ConnectivityResult.mobile) ||
             results.contains(ConnectivityResult.wifi);
    });
  }
}
```

---

## Step 2: Implementasi `SessionRemoteDataSource`

**File: `lib/data/datasources/remote/session_remote_datasource.dart`**

| Method                        | Firestore Operation      | Deskripsi                          |
| ----------------------------- | ------------------------ | ---------------------------------- |
| `upsertSession(SessionModel)` | `set(data, merge: true)` | Upload/update session ke Firestore |
| `getSession(String id)`       | `get()`                  | Ambil session dari Firestore       |

**Firestore Document Structure (collection: `sessions`):**

```json
{
  "session_id": "uuid",
  "cashier_id": "John",
  "opened_at": 1704067200,
  "closed_at": 1704110400,
  "opening_balance": 500000,
  "closing_balance": 1250000,
  "expected_cash": 1230000,
  "variance": 20000,
  "total_cash_sales": 730000,
  "total_qris_sales": 320000,
  "total_orders": 25,
  "status": "closed"
}
```

**Penting:**

- Document ID = `session_id` (idempotent upsert)
- Gunakan `set` dengan `SetOptions(merge: true)`, bukan `add`
- Catch `FirebaseException` → throw `ServerException`
- Jangan expose `DocumentSnapshot` ke luar class

---

## Step 3: Implementasi `OrderRemoteDataSource`

**File: `lib/data/datasources/remote/order_remote_datasource.dart`**

| Method                                   | Firestore Operation      | Deskripsi                     |
| ---------------------------------------- | ------------------------ | ----------------------------- |
| `upsertOrder(OrderModel)`                | `set(data, merge: true)` | Upload order ke Firestore     |
| `upsertOrderItems(List<OrderItemModel>)` | Batch write              | Upload semua items satu order |
| `getOrder(String id)`                    | `get()`                  | Ambil order dari Firestore    |

**Firestore Document Structure:**

**Collection `orders`:**

```json
{
  "order_id": "uuid",
  "session_id": "uuid",
  "cashier_id": "John",
  "created_at": 1704067200,
  "total_amount": 58000,
  "discount_amount": 5000,
  "grand_total": 53000,
  "payment_method": "cash",
  "amount_tendered": 100000,
  "change_amount": 47000,
  "status": "completed"
}
```

**Collection `order_items`:**

```json
{
  "order_item_id": "uuid",
  "order_id": "uuid",
  "product_id": "prod_001",
  "product_name": "Nasi Goreng",
  "unit_price": 25000,
  "quantity": 2,
  "discount_amount": 0,
  "subtotal": 50000
}
```

**Penting:**

- Batch write untuk order items (atomicity di Firestore)
- Document ID = record ID

---

## Step 4: Complete `SyncManager`

**File: `lib/data/datasources/remote/sync_manager.dart`**

### 4.1 — Architecture

```dart
class SyncManager {
  SyncManager({
    required NetworkInfo networkInfo,
    required SessionLocalDataSource sessionLocalDs,
    required SessionRemoteDataSource sessionRemoteDs,
    required OrderLocalDataSource orderLocalDs,
    required OrderRemoteDataSource orderRemoteDs,
  });

  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;

  /// Mulai listening connectivity changes
  Future<void> startListening() async { ... }

  /// Stop listening
  Future<void> stopListening() async { ... }

  /// Sync semua data yang belum di-sync
  Future<SyncResult> syncAll() async { ... }

  /// Sync hanya sessions
  Future<void> _syncSessions() async { ... }

  /// Sync hanya orders + items
  Future<void> _syncOrders() async { ... }
}
```

### 4.2 — `syncAll()` Flow

```
syncAll()
  │
  ├─ Cek isConnected → jika offline, skip
  ├─ Cek _isSyncing → jika sudah running, skip (prevent concurrent)
  │
  ├─ _isSyncing = true
  │
  ├─ 1. _syncSessions()
  │   ├─ Get all sessions WHERE synced = 0
  │   ├─ For each session:
  │   │   ├─ Call sessionRemoteDs.upsertSession()
  │   │   ├─ On success → sessionLocalDs.markSessionSynced(id)
  │   │   └─ On failure → log error, continue to next
  │   └─ Return count synced
  │
  ├─ 2. _syncOrders()
  │   ├─ Get all orders WHERE synced = 0
  │   ├─ For each order:
  │   │   ├─ Call orderRemoteDs.upsertOrder()
  │   │   ├─ Get order items → call orderRemoteDs.upsertOrderItems()
  │   │   ├─ On success → orderLocalDs.markOrderSynced(id)
  │   │   └─ On failure → log error, continue to next
  │   └─ Return count synced
  │
  ├─ _isSyncing = false
  └─ Return SyncResult(sessionsSynced, ordersSynced, errors)
```

### 4.3 — Auto-Sync on Connectivity Change

```dart
Future<void> startListening() async {
  _connectivitySubscription = networkInfo.onConnectivityChanged.listen(
    (isConnected) {
      if (isConnected) {
        syncAll(); // Fire-and-forget
      }
    },
  );
}
```

### 4.4 — `SyncResult` Value Object

```dart
class SyncResult extends Equatable {
  const SyncResult({
    this.sessionsSynced = 0,
    this.ordersSynced = 0,
    this.errors = const [],
  });

  final int sessionsSynced;
  final int ordersSynced;
  final List<String> errors;

  bool get hasErrors => errors.isNotEmpty;
  int get totalSynced => sessionsSynced + ordersSynced;
}
```

### 4.5 — Sync Priority Order

1. **Sessions** — harus di-sync dulu karena orders reference `session_id`
2. **Orders** — setelah session parent di-sync
3. **Order Items** — di-sync bersama parent order

---

## Step 5: Update Repository Implementations

### 5.1 — `SessionRepositoryImpl` Update

Tambahkan sync trigger setelah write operations:

```dart
@override
Future<Either<Failure, Session>> openSession({ ... }) async {
  // ... existing local save logic ...

  // Trigger sync in background (fire-and-forget)
  unawaited(syncManager.syncAll());

  return Right(session);
}
```

### 5.2 — `OrderRepositoryImpl` Update

Sama — trigger sync setelah `createOrder` dan `updateOrder`.

**Penting:**

- Sync TIDAK boleh blocking. User flow harus tetap lancar offline.
- Gunakan `unawaited()` untuk fire-and-forget sync attempts
- Jika sync gagal, data tetap aman di SQFlite

---

## Step 6: Buat `SyncStatusBadgeWidget`

**File: `lib/presentation/shared/widgets/sync_status_badge_widget.dart`**

| Status  | Icon        | Warna  | Tooltip                 |
| ------- | ----------- | ------ | ----------------------- |
| Synced  | ✓ (check)   | Hijau  | "Data tersinkronisasi"  |
| Pending | ⟳ (refresh) | Kuning | "Menunggu sinkronisasi" |
| Failed  | ✗ (x)       | Merah  | "Gagal sinkronisasi"    |

```dart
class SyncStatusBadge extends StatelessWidget {
  const SyncStatusBadge({
    required this.isSynced,
    super.key,
  });

  final bool isSynced;

  @override
  Widget build(BuildContext context) {
    return Icon(
      isSynced ? Icons.cloud_done : Icons.cloud_upload,
      color: isSynced ? Colors.green : Colors.orange,
      size: 16,
    );
  }
}
```

---

## Step 7: Integrasikan Sync ke UI

### 7.1 — Tambahkan Sync Badge ke Order Card (History)

Di `OrderCardWidget`, tampilkan `SyncStatusBadge` di setiap order card.

### 7.2 — Tambahkan Sync Badge ke Closing Summary

Di `ClosingView`, tampilkan:

- Jumlah transaksi yang belum di-sync
- Tombol "Sync Sekarang" (manual trigger)

### 7.3 — Global Sync Indicator (Opsional)

Di AppBar atau status bar, tampilkan sync status global:

- Online + semua synced → ✓
- Online + ada pending → ⟳ (dengan counter)
- Offline → ☁️✗ "Offline mode"

### 7.4 — Manual Sync Trigger

Tambahkan tombol "Sync Sekarang" di:

- Closing page (sebelum tutup sesi)
- History page (di AppBar atau pull-to-refresh)

```dart
// In BLoC or directly
onTap: () async {
  final result = await syncManager.syncAll();
  // Show snackbar with result
}
```

---

## Step 8: Handle Edge Cases

### 8.1 — Offline Write → Later Sync

**Scenario:** User membuat 10 transaksi offline, lalu connect ke internet.

**Expected:**

1. ✅ Semua 10 transaksi tersimpan di SQFlite
2. ✅ Saat online → SyncManager auto-trigger
3. ✅ Semua 10 transaksi di-upload ke Firestore
4. ✅ Setiap sukses → `synced = true` di SQFlite

**Test:**

- Disable WiFi → buat beberapa transaksi → enable WiFi → verify Firestore docs

### 8.2 — Partial Sync Failure

**Scenario:** Dari 10 transaksi, 7 berhasil sync, 3 gagal (server error).

**Expected:**

1. ✅ 7 transaksi di-mark `synced = true`
2. ✅ 3 transaksi tetap `synced = false`
3. ✅ Retry pada connectivity event berikutnya
4. ✅ UI menampilkan berapa yang belum sync

**Implementasi di SyncManager:**

- Jangan stop sync process saat satu record gagal
- Log error, lanjut ke record berikutnya
- Return error count di `SyncResult`

### 8.3 — Concurrent Sync Prevention

**Scenario:** SyncManager trigger berturut-turut (connectivity flapping).

**Expected:**

1. ✅ Hanya 1 sync proses berjalan sekaligus
2. ✅ Request sync ke-2 di-skip (bukan di-queue)

**Implementasi:**

```dart
Future<SyncResult> syncAll() async {
  if (_isSyncing) return const SyncResult(); // Skip
  _isSyncing = true;
  try {
    // ... sync logic
  } finally {
    _isSyncing = false;
  }
}
```

### 8.4 — App Killed During Sync

**Scenario:** User close app di tengah sync process.

**Expected:**

1. ✅ Data yang belum synced tetap di SQFlite (`synced = false`)
2. ✅ Data yang sudah synced tetap `synced = true`
3. ✅ Saat app dibuka lagi → SyncManager restart → retry yang tersisa

**Tidak perlu special handling** — karena sync mark `synced = true` per record secara individual setelah upload berhasil.

### 8.5 — Duplicate Prevention (Idempotent Sync)

**Scenario:** Record sudah berhasil di-upload ke Firestore, tapi app crash sebelum mark `synced = true`.

**Expected:**

1. ✅ SyncManager akan re-upload record yang sama
2. ✅ Karena gunakan `set(merge: true)` dengan document ID = record ID → Firestore overwrite, bukan duplicate
3. ✅ Data konsisten

### 8.6 — Closing Session: Force Sync

**Scenario:** Kasir tutup sesi → pastikan semua transaksi sudah sync.

**Expected:**

1. ✅ Sebelum closing, tampilkan warning jika ada transaksi unsynced
2. ✅ Tombol "Sync dulu" → attempt sync → tampilkan result
3. ✅ Jika masih ada yang gagal sync → izinkan closing dengan warning
4. ✅ Closing record sendiri juga akan masuk sync queue

**Implementasi di ClosingBloc:**

```dart
on<ClosingConfirmed>((event, emit) async {
  // 1. Attempt final sync
  final syncResult = await syncManager.syncAll();

  // 2. Proceed with closing regardless
  final result = await closeSessionUseCase(params);

  // 3. Emit result with sync info
  emit(state.copyWith(
    status: ClosingStatus.closed,
    unsyncedCount: syncResult.hasErrors ? ... : 0,
  ));
});
```

---

## Step 9: Register Dependencies

Tambahkan/update di `lib/injection_container.dart`:

```dart
// ─── Network ───
sl.registerLazySingleton<Connectivity>(() => Connectivity());
sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

// ─── Remote Data Sources ───
sl.registerLazySingleton(() => SessionRemoteDataSource(sl<FirebaseFirestore>()));
sl.registerLazySingleton(() => OrderRemoteDataSource(sl<FirebaseFirestore>()));

// ─── Sync ───
sl.registerLazySingleton(() => SyncManager(
  networkInfo: sl(),
  sessionLocalDs: sl(),
  sessionRemoteDs: sl(),
  orderLocalDs: sl(),
  orderRemoteDs: sl(),
));

// ─── Firebase ───
sl.registerLazySingleton(() => FirebaseFirestore.instance);
```

**Di `bootstrap.dart`:**

```dart
// Setelah initDependencies()
await sl<SyncManager>().startListening();
```

---

## Step 10: Tulis Unit Tests

### 10.1 — `NetworkInfoImpl` Tests

**`test/data/datasources/network/network_info_impl_test.dart`**

| Test Case                                  | Expected |
| ------------------------------------------ | -------- |
| WiFi connected → `isConnected = true`      | ✅       |
| Mobile connected → `isConnected = true`    | ✅       |
| No connection → `isConnected = false`      | ✅       |
| Connectivity change stream emits correctly | ✅       |

### 10.2 — Remote DataSource Tests

**`test/data/datasources/remote/session_remote_datasource_test.dart`**

| Test Case                                               | Expected |
| ------------------------------------------------------- | -------- |
| Upsert session → Firestore set called with correct data | ✅       |
| Firestore error → throw ServerException                 | ✅       |

**`test/data/datasources/remote/order_remote_datasource_test.dart`**

| Test Case                               | Expected |
| --------------------------------------- | -------- |
| Upsert order → Firestore set called     | ✅       |
| Upsert order items → batch write called | ✅       |
| Firestore error → throw ServerException | ✅       |

### 10.3 — SyncManager Tests

**`test/data/datasources/remote/sync_manager_test.dart`**

| Test Case                                                    | Expected |
| ------------------------------------------------------------ | -------- |
| Sync all → sessions synced first, then orders                | ✅       |
| Offline → sync skipped                                       | ✅       |
| Concurrent sync → second call skipped                        | ✅       |
| Partial failure → successful records marked, failed retained | ✅       |
| Empty queue → no remote calls made                           | ✅       |
| Connectivity change online → syncAll triggered               | ✅       |
| Session synced → `markSessionSynced` called                  | ✅       |
| Order synced → `markOrderSynced` called                      | ✅       |

### 10.4 — Updated Repository Tests

Update existing repository tests untuk verify sync trigger:

**`test/data/repositories/session_repository_impl_test.dart`** (update)

- Verify `syncManager.syncAll()` called after `openSession`
- Verify `syncManager.syncAll()` called after `closeSession`

**`test/data/repositories/order_repository_impl_test.dart`** (update)

- Verify `syncManager.syncAll()` called after `createOrder`
- Verify `syncManager.syncAll()` called after `updateOrder`

---

## Step 11: Tulis Integration Tests

### 11.1 — Full Offline → Online Cycle

**`test/integration/sync_cycle_test.dart`** (atau manual testing checklist)

**Scenario:**

1. 🔴 Set offline mode
2. Buat session (opening)
3. Buat 3 orders (completed)
4. Buat 1 order (pending)
5. Void 1 order
6. Close session
7. 🟢 Set online mode
8. Verify:
   - [ ] Session (open & close) ada di Firestore
   - [ ] 3 completed orders ada di Firestore
   - [ ] 1 pending order ada di Firestore
   - [ ] 1 voided order ada di Firestore
   - [ ] Order items ada di Firestore
   - [ ] Semua SQFlite records `synced = true`

### 11.2 — Manual Testing Checklist

| #   | Test Scenario      | Langkah                                | Expected Result                                 |
| --- | ------------------ | -------------------------------------- | ----------------------------------------------- |
| 1   | Normal sync        | Buat transaksi online                  | Record muncul di Firestore                      |
| 2   | Offline mode       | Matikan WiFi → buat transaksi          | Transaksi tersimpan lokal, badge "pending sync" |
| 3   | Reconnect sync     | Nyalakan WiFi setelah offline          | Auto-sync, badge berubah ke "synced"            |
| 4   | Mixed connectivity | Buat 5 transaksi (3 online, 2 offline) | Semua 5 ada di Firestore setelah reconnect      |
| 5   | Closing force sync | Tutup sesi → lihat sync attempt        | Warning jika ada unsynced, attempt sync         |
| 6   | Kill app saat sync | Force close saat sync berlangsung      | Reopen → unsynced records retry                 |
| 7   | Large batch        | 50+ transaksi offline → reconnect      | Semua sync tanpa crash                          |

---

## Definition of Done — Phase 6

- [ ] `NetworkInfoImpl` detect online/offline status akurat
- [ ] `SessionRemoteDataSource` bisa upsert session ke Firestore
- [ ] `OrderRemoteDataSource` bisa upsert orders dan items ke Firestore
- [ ] `SyncManager` auto-sync saat connectivity berubah ke online
- [ ] Sync priority: sessions → orders → order items
- [ ] Sync idempotent (re-sync tidak duplicate)
- [ ] Partial failure handled (failed records retained, successful marked)
- [ ] Concurrent sync prevented
- [ ] `SyncStatusBadge` tampil di order cards dan closing page
- [ ] Manual sync trigger tersedia di UI
- [ ] Closing page memperingatkan jika ada data unsynced
- [ ] Full offline → online cycle berhasil
- [ ] Semua unit tests pass
- [ ] `flutter analyze` clean, `flutter test` pass

---

## Final — Project Completion Checklist

Setelah semua 6 phase selesai, verify end-to-end:

- [ ] **Login** → PIN login berfungsi dengan lockout
- [ ] **Opening** → Saldo awal tercatat, 1 session/hari
- [ ] **Cashier** → Produk browse, cart, bayar tunai, bayar QRIS, receipt
- [ ] **Bayar Nanti** → Order pending tersimpan
- [ ] **History** → List, filter, search, detail order
- [ ] **Bayar Pending** → Complete pending order dari history
- [ ] **Void** → Batalkan order (dengan time window)
- [ ] **Closing** → Summary akurat, variance, PIN confirm, PDF report
- [ ] **Logout** → Clean state, warning jika session open
- [ ] **Offline Mode** → Semua fitur berfungsi tanpa internet
- [ ] **Sync** → Auto-sync saat online, idempotent, partial failure handled
- [ ] **3 Flavors** → Dev, staging, production build semua sukses
- [ ] **Tests** → All unit tests, BLoC tests, dan widget tests pass
- [ ] **Clean Code** → `flutter analyze` clean, `bloc lint` clean
