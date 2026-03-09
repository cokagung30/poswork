# Phase 5 — Order History

> Review transaksi, selesaikan pembayaran pending, dan void order.

**Prasyarat:** Phase 4 (Cashier & Transactions) selesai.

---

## Checklist Overview

- [ ] Step 1: Buat Use Cases (`GetOrdersUseCase`, `GetOrderDetailUseCase`, `CompleteOrderUseCase`, `VoidOrderUseCase`)
- [ ] Step 2: Buat `HistoryBloc` (Events, States, BLoC)
- [ ] Step 3: Buat UI History List (`HistoryPage`, `HistoryView`)
- [ ] Step 4: Buat UI Order Detail (`OrderDetailPage`)
- [ ] Step 5: Buat flow "Proses Pembayaran" untuk pending orders
- [ ] Step 6: Buat flow "Void Order"
- [ ] Step 7: Register semua dependency di `injection_container.dart`
- [ ] Step 8: Tulis Unit Tests
- [ ] Step 9: Tulis Widget Tests

---

## Step 1: Buat Use Cases

### 1.1 — `GetOrdersUseCase`

**File: `lib/domain/usecases/get_orders_usecase.dart`**

| Input             | Output                         |
| ----------------- | ------------------------------ |
| `GetOrdersParams` | `Either<Failure, List<Order>>` |

**`GetOrdersParams`:**

```dart
class GetOrdersParams extends Equatable {
  final String sessionId;
  final String? statusFilter;       // 'pending' | 'completed' | 'voided' | null (semua)
  final String? paymentMethodFilter; // 'cash' | 'qris' | null
  final String? searchQuery;         // order number atau product name
  final DateTime? dateFrom;
  final DateTime? dateTo;
}
```

**Logic:**

1. Query `orders` table dengan session ID
2. Apply filters (status, payment method, date range)
3. Jika `searchQuery` ada → cari di `order_id` LIKE atau JOIN `order_items` cari `product_name`
4. Sort by `created_at` DESC (terbaru di atas)
5. Return list of `Order` (tanpa items, hanya summary)

### 1.2 — `GetOrderDetailUseCase`

**File: `lib/domain/usecases/get_order_detail_usecase.dart`**

| Input            | Output                   |
| ---------------- | ------------------------ |
| `String orderId` | `Either<Failure, Order>` |

**Logic:**

1. Query `orders` WHERE `order_id = ?`
2. Query `order_items` WHERE `order_id = ?`
3. Return `Order` lengkap dengan `items` list

### 1.3 — `CompleteOrderUseCase`

**File: `lib/domain/usecases/complete_order_usecase.dart`**

| Input                 | Output                   |
| --------------------- | ------------------------ |
| `CompleteOrderParams` | `Either<Failure, Order>` |

**`CompleteOrderParams`:**

```dart
class CompleteOrderParams extends Equatable {
  final String orderId;
  final String paymentMethod; // 'cash' | 'qris'
  final double? amountTendered;
}
```

**Logic:**

1. Get order by ID → validasi status == `pending`
2. Jika `paymentMethod = 'cash'`:
   - Validasi `amountTendered >= grandTotal`
   - Hitung `changeAmount`
3. Update order: `status → 'completed'`, set payment data, `synced = false`
4. Return updated `Order`

### 1.4 — `VoidOrderUseCase`

**File: `lib/domain/usecases/void_order_usecase.dart`**

| Input            | Output                   |
| ---------------- | ------------------------ |
| `String orderId` | `Either<Failure, Order>` |

**Logic:**

1. Get order by ID
2. Validasi: status `pending` atau `completed`
3. Jika `completed` → cek apakah masih dalam time window yang dikonfigurasi (e.g., 30 menit)
4. Update status → `voided`, `synced = false`
5. Return updated `Order`

---

## Step 2: Buat `HistoryBloc`

### 2.1 — Events

**File: `lib/presentation/features/history/bloc/history_event.dart`**

```dart
class HistoryOrdersLoadRequested extends HistoryEvent {
  final String sessionId;
}

class HistoryFilterChanged extends HistoryEvent {
  final String? statusFilter;
  final String? paymentMethodFilter;
}

class HistorySearchQueryChanged extends HistoryEvent {
  final String query;
}

class HistoryDateRangeChanged extends HistoryEvent {
  final DateTime? dateFrom;
  final DateTime? dateTo;
}

class HistoryOrderDetailRequested extends HistoryEvent {
  final String orderId;
}

class HistoryOrderPaymentRequested extends HistoryEvent {
  final String orderId;
}

class HistoryOrderPaymentCompleted extends HistoryEvent {
  final String orderId;
  final String paymentMethod;
  final double? amountTendered;
}

class HistoryOrderVoidRequested extends HistoryEvent {
  final String orderId;
}
```

### 2.2 — States

**File: `lib/presentation/features/history/bloc/history_state.dart`**

```dart
enum HistoryStatus {
  initial,
  loading,
  loaded,
  orderDetailLoading,
  orderDetailLoaded,
  processingPayment,
  paymentCompleted,
  voiding,
  voided,
  failure,
}

class HistoryState extends Equatable {
  const HistoryState({
    this.status = HistoryStatus.initial,
    this.orders = const [],
    this.selectedOrder,
    this.statusFilter,
    this.paymentMethodFilter,
    this.searchQuery = '',
    this.errorMessage = '',
  });

  final HistoryStatus status;
  final List<Order> orders;
  final Order? selectedOrder; // Order detail lengkap dengan items
  final String? statusFilter;
  final String? paymentMethodFilter;
  final String searchQuery;
  final String errorMessage;

  // Computed
  int get pendingCount => orders.where((o) => o.status == 'pending').length;
  int get completedCount => orders.where((o) => o.status == 'completed').length;
}
```

### 2.3 — BLoC

**File: `lib/presentation/features/history/bloc/history_bloc.dart`**

| Event                   | Handler Logic                                                       |
| ----------------------- | ------------------------------------------------------------------- |
| `OrdersLoadRequested`   | Call `GetOrdersUseCase` → emit `loaded`                             |
| `FilterChanged`         | Update filter → reload orders                                       |
| `SearchQueryChanged`    | Update query → reload orders (debounced)                            |
| `DateRangeChanged`      | Update date range → reload orders                                   |
| `OrderDetailRequested`  | Call `GetOrderDetailUseCase` → emit `orderDetailLoaded`             |
| `OrderPaymentCompleted` | Call `CompleteOrderUseCase` → emit `paymentCompleted` → reload list |
| `OrderVoidRequested`    | Confirm → call `VoidOrderUseCase` → emit `voided` → reload list     |

### 2.4 — Barrel File

**File: `lib/presentation/features/history/history.dart`**

---

## Step 3: Buat UI History List

### 3.1 — `HistoryPage`

**File: `lib/presentation/features/history/pages/history_page.dart`**

- Provides `HistoryBloc`
- Dispatch `HistoryOrdersLoadRequested` on init
- Child: `HistoryView`

### 3.2 — `HistoryView`

**File: `lib/presentation/features/history/pages/history_view.dart`**

**Layout:**

```
┌─────────────────────────────────────────────┐
│ AppBar: Riwayat Pesanan         [🔍 Search] │
├─────────────────────────────────────────────┤
│ Filter Chips:                               │
│ [Semua] [Pending (3)] [Selesai] [Void]      │
│ [Tunai] [QRIS]                              │
├─────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────┐ │
│ │ 🟡 POS-001     14:30   Rp 53.000       │ │
│ │    Tunai                    Pending     │ │
│ ├─────────────────────────────────────────┤ │
│ │ ✅ POS-002     14:15   Rp 35.000       │ │
│ │    QRIS                    Selesai      │ │
│ ├─────────────────────────────────────────┤ │
│ │ ❌ POS-003     13:45   Rp 22.000       │ │
│ │    Tunai                    Void        │ │
│ └─────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

**Komponen per Order Card:**

- Status icon/badge (warna berbeda per status)
- Order number
- Waktu pembuatan
- Grand total (Rp format)
- Payment method (atau "-" untuk pending)
- Status label
- Sync status indicator (icon kecil: ✓ synced, ⟳ pending, ✗ failed)

**Interaksi:**

- Tap order → navigate ke Order Detail
- Pull to refresh → reload orders
- Filter chips → dispatch `HistoryFilterChanged`
- Search → dispatch `HistorySearchQueryChanged`

### 3.3 — `OrderCardWidget`

**File: `lib/presentation/features/history/widgets/order_card_widget.dart`**

- Reusable card untuk list item
- Tampilkan: status badge, order number, time, total, payment method

### 3.4 — `StatusBadgeWidget`

**File: `lib/presentation/shared/widgets/status_badge_widget.dart`**

| Status      | Warna         | Label      |
| ----------- | ------------- | ---------- |
| `pending`   | Kuning/Orange | Menunggu   |
| `completed` | Hijau         | Selesai    |
| `voided`    | Merah         | Dibatalkan |

---

## Step 4: Buat UI Order Detail

### 4.1 — `OrderDetailPage`

**File: `lib/presentation/features/history/pages/order_detail_page.dart`**

**Layout:**

```
┌─────────────────────────────────────────────┐
│ AppBar: Detail Pesanan        [⋮ Actions]   │
├─────────────────────────────────────────────┤
│ No. Order: POS-001                          │
│ Status: 🟡 Menunggu Pembayaran              │
│ Waktu: 14:30, 15 Jan 2026                  │
│ Kasir: John                                 │
├─────────────────────────────────────────────┤
│ DAFTAR ITEM                                │
│ ┌─────────────────────────────────────────┐ │
│ │ Nasi Goreng        x2       Rp 50.000  │ │
│ │ Es Teh Manis       x1       Rp  8.000  │ │
│ └─────────────────────────────────────────┘ │
├─────────────────────────────────────────────┤
│ Subtotal                      Rp 58.000    │
│ Diskon                       -Rp  5.000    │
│ TOTAL                         Rp 53.000    │
├─────────────────────────────────────────────┤
│ Metode Bayar: -                             │
│ Sync: ⟳ Belum disinkronkan                 │
├─────────────────────────────────────────────┤
│                                             │
│  [🔴 Batalkan]   [💳 Proses Pembayaran]     │  ← Hanya untuk status pending
│                                             │
└─────────────────────────────────────────────┘
```

**Conditional UI:**

| Status                          | Tombol yang tampil               |
| ------------------------------- | -------------------------------- |
| `pending`                       | "Proses Pembayaran" + "Batalkan" |
| `completed` (dalam time window) | "Batalkan" saja                  |
| `completed` (lewat time window) | Tidak ada tombol                 |
| `voided`                        | Tidak ada tombol (read-only)     |

---

## Step 5: Buat Flow "Proses Pembayaran"

Alur menyelesaikan pembayaran order pending:

1. User tap "Proses Pembayaran" di Order Detail
2. Tampilkan Payment Method Sheet (sama seperti di Cashier)
3. User pilih Cash atau QRIS
4. **Cash:** navigate ke `CashPaymentPage` dengan pre-filled `grandTotal`
5. **QRIS:** navigate ke `QrisPaymentPage`
6. Setelah payment confirmed:
   - Dispatch `HistoryOrderPaymentCompleted`
   - BLoC call `CompleteOrderUseCase`
   - Update order status → `completed`
7. Tampilkan Receipt Page
8. Kembali ke History list (auto-refreshed)

**Penting:**

- Reuse payment pages dari Phase 4 (Cash & QRIS)
- Reuse Receipt Page dari Phase 4
- Perbedaan: data diambil dari existing order, bukan dari cart

---

## Step 6: Buat Flow "Void Order"

### 6.1 — Void Pending Order

1. User tap "Batalkan" di Order Detail (status: `pending`)
2. Tampilkan confirmation dialog:
   - "Batalkan pesanan POS-001?"
   - "Pesanan yang dibatalkan tidak bisa dikembalikan."
   - Tombol "Tidak" dan "Batalkan"
3. Jika confirm → dispatch `HistoryOrderVoidRequested`
4. BLoC call `VoidOrderUseCase`
5. Update order status → `voided`
6. Kembali ke History list

### 6.2 — Void Completed Order

1. User tap "Batalkan" di Order Detail (status: `completed`)
2. Cek time window (misalnya 30 menit dari `created_at`)
   - Jika lewat → tampilkan error: "Pesanan sudah melewati batas waktu pembatalan"
   - Jika masih dalam window → lanjut
3. Tampilkan confirmation dialog with warning:
   - "⚠️ Batalkan pesanan yang sudah selesai?"
   - "Transaksi ini sudah tercatat. Pembatalan akan mempengaruhi laporan."
   - Tombol "Tidak" dan "Batalkan"
4. Proses sama seperti void pending

### 6.3 — Konfigurasi Time Window

**File: `lib/core/constants/app_constants.dart`** (tambahkan)

```dart
static const Duration voidTimeWindow = Duration(minutes: 30);
```

---

## Step 7: Register Dependencies

Tambahkan ke `lib/injection_container.dart`:

```dart
// ─── History ───
// Use Cases
sl.registerLazySingleton(() => GetOrdersUseCase(sl()));
sl.registerLazySingleton(() => GetOrderDetailUseCase(sl()));
sl.registerLazySingleton(() => CompleteOrderUseCase(sl()));
sl.registerLazySingleton(() => VoidOrderUseCase(sl()));

// BLoC
sl.registerFactory(() => HistoryBloc(
  getOrdersUseCase: sl(),
  getOrderDetailUseCase: sl(),
  completeOrderUseCase: sl(),
  voidOrderUseCase: sl(),
));
```

---

## Step 8: Tulis Unit Tests

### 8.1 — Use Case Tests

**`test/domain/usecases/get_orders_usecase_test.dart`**

| Test Case                                        | Expected |
| ------------------------------------------------ | -------- |
| Return all orders in session                     | ✅       |
| Filter by status `pending` → only pending orders | ✅       |
| Filter by payment method → only matching orders  | ✅       |
| Search by order number → matching orders         | ✅       |
| Empty session → empty list                       | ✅       |

**`test/domain/usecases/get_order_detail_usecase_test.dart`**

| Test Case                   | Expected |
| --------------------------- | -------- |
| Return order with all items | ✅       |
| Order not found → failure   | ✅       |

**`test/domain/usecases/complete_order_usecase_test.dart`**

| Test Case                                  | Expected |
| ------------------------------------------ | -------- |
| Complete pending order with cash → success | ✅       |
| Complete pending order with QRIS → success | ✅       |
| Order not pending → failure                | ✅       |
| Cash insufficient → failure                | ✅       |
| Change calculated correctly                | ✅       |

**`test/domain/usecases/void_order_usecase_test.dart`**

| Test Case                                     | Expected |
| --------------------------------------------- | -------- |
| Void pending order → success                  | ✅       |
| Void completed order within window → success  | ✅       |
| Void completed order outside window → failure | ✅       |
| Void already voided order → failure           | ✅       |

### 8.2 — BLoC Tests

**`test/presentation/features/history/bloc/history_bloc_test.dart`**

| Test Case           | Expected                         |
| ------------------- | -------------------------------- |
| Load orders         | `loading` → `loaded` with orders |
| Filter changed      | reload with new filter           |
| Search query        | reload with search results       |
| Order detail loaded | `orderDetailLoaded` with items   |
| Payment completed   | `paymentCompleted` → reload list |
| Void order          | `voided` → reload list           |
| Error cases         | `failure` with message           |

---

## Step 9: Tulis Widget Tests

**`test/presentation/features/history/pages/history_page_test.dart`**

| Test Case                                | Expected |
| ---------------------------------------- | -------- |
| Render order list                        | ✅       |
| Status filter chips tampil dan berfungsi | ✅       |
| Tap order navigasi ke detail             | ✅       |
| Pull to refresh                          | ✅       |
| Empty state tampil saat tidak ada orders | ✅       |

**`test/presentation/features/history/pages/order_detail_page_test.dart`**

| Test Case                                               | Expected |
| ------------------------------------------------------- | -------- |
| Detail order tampil lengkap dengan items                | ✅       |
| Pending order: tombol pembayaran & batal tampil         | ✅       |
| Completed order: hanya tombol batal (jika dalam window) | ✅       |
| Voided order: read-only, tanpa tombol                   | ✅       |
| Tap "Proses Pembayaran" → payment flow                  | ✅       |
| Tap "Batalkan" → confirmation dialog                    | ✅       |

---

## Definition of Done — Phase 5

- [ ] History list menampilkan semua orders dalam session, sorted terbaru
- [ ] Filter by status (pending/completed/voided) berfungsi
- [ ] Filter by payment method berfungsi
- [ ] Search by order number berfungsi
- [ ] Order detail menampilkan semua item dengan subtotal
- [ ] Pending order bisa diselesaikan pembayarannya (Cash/QRIS)
- [ ] Setelah bayar, status update ke `completed` dan receipt tampil
- [ ] Void order berfungsi untuk pending dan completed (dalam time window)
- [ ] Void completed order di luar time window ditolak
- [ ] Sync status indicator tampil di setiap order
- [ ] Semua use case, repository, dan BLoC ter-unit-test
- [ ] Widget test untuk History dan Order Detail pages
- [ ] `flutter analyze` clean, `flutter test` pass
