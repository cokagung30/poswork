# Phase 4 — Cashier & Transactions

> Core POS transaction flow: product browsing, cart management, payment processing, dan receipt.

**Prasyarat:** Phase 3 (Session Lifecycle) selesai.

---

## Checklist Overview

- [ ] Step 1: Buat Entities (`Product`, `Order`, `OrderItem`, `Cart`)
- [ ] Step 2: Buat abstract Repositories (`ProductRepository`, `OrderRepository`)
- [ ] Step 3: Buat Use Cases (`GetProductsUseCase`, `CreateOrderUseCase`)
- [ ] Step 4: Buat Data Models (`ProductModel`, `OrderModel`, `OrderItemModel`)
- [ ] Step 5: Implementasi `ProductLocalDataSource`
- [ ] Step 6: Implementasi `OrderLocalDataSource`
- [ ] Step 7: Implementasi `ProductRepositoryImpl` dan `OrderRepositoryImpl`
- [ ] Step 8: Seed product data ke SQFlite
- [ ] Step 9: Buat `CashierBloc` (Events, States, BLoC)
- [ ] Step 10: Buat UI Cashier (`CashierPage`, `ProductGridWidget`, `CartPanel`)
- [ ] Step 11: Buat UI Payment (`CashPaymentPage`, `QrisPaymentPage`)
- [ ] Step 12: Buat UI Receipt (`ReceiptPage`)
- [ ] Step 13: Buat flow "Bayar Nanti" (Pending Order)
- [ ] Step 14: Register semua dependency di `injection_container.dart`
- [ ] Step 15: Tulis Unit Tests
- [ ] Step 16: Tulis Widget Tests

---

## Step 1: Buat Entities

### 1.1 — `Product`

**File: `lib/domain/entities/product.dart`**

```dart
class Product extends Equatable {
  const Product({
    required this.productId,
    required this.name,
    required this.price,
    this.sku,
    this.category,
    this.imageUrl,
    this.isActive = true,
  });

  final String productId;
  final String name;
  final String? sku;
  final String? category;
  final double price;
  final String? imageUrl;
  final bool isActive;

  @override
  List<Object?> get props => [productId, name, sku, category, price, imageUrl, isActive];
}
```

### 1.2 — `Order`

**File: `lib/domain/entities/order.dart`**

```dart
class Order extends Equatable {
  const Order({
    required this.orderId,
    required this.sessionId,
    required this.cashierId,
    required this.createdAt,
    required this.totalAmount,
    required this.grandTotal,
    required this.status,
    this.discountAmount = 0,
    this.paymentMethod,
    this.amountTendered,
    this.changeAmount,
    this.items = const [],
    this.synced = false,
  });

  final String orderId;
  final String sessionId;
  final String cashierId;
  final DateTime createdAt;
  final double totalAmount;
  final double discountAmount;
  final double grandTotal;
  final String? paymentMethod; // 'cash' | 'qris' | null (pending)
  final double? amountTendered;
  final double? changeAmount;
  final String status; // 'pending' | 'completed' | 'voided'
  final List<OrderItem> items;
  final bool synced;

  @override
  List<Object?> get props => [ ... ];
}
```

### 1.3 — `OrderItem`

**File: `lib/domain/entities/order_item.dart`**

```dart
class OrderItem extends Equatable {
  const OrderItem({
    required this.orderItemId,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
    this.discountAmount = 0,
  });

  final String orderItemId;
  final String orderId;
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double discountAmount;
  final double subtotal;

  @override
  List<Object?> get props => [ ... ];
}
```

### 1.4 — `CartItem` (value object, bukan entity DB)

**File: `lib/domain/entities/cart_item.dart`**

```dart
class CartItem extends Equatable {
  const CartItem({
    required this.product,
    required this.quantity,
    this.discountAmount = 0,
  });

  final Product product;
  final int quantity;
  final double discountAmount;

  double get subtotal => (product.price * quantity) - discountAmount;

  CartItem copyWith({int? quantity, double? discountAmount});

  @override
  List<Object?> get props => [product, quantity, discountAmount];
}
```

---

## Step 2: Buat Abstract Repositories

### 2.1 — `ProductRepository`

**File: `lib/domain/repositories/product_repository.dart`**

```dart
abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, List<Product>>> searchProducts(String query);
  Future<Either<Failure, List<Product>>> getProductsByCategory(String category);
  Future<Either<Failure, List<String>>> getCategories();
}
```

### 2.2 — `OrderRepository`

**File: `lib/domain/repositories/order_repository.dart`**

```dart
abstract class OrderRepository {
  /// Buat order baru (completed atau pending)
  Future<Either<Failure, Order>> createOrder(Order order);

  /// Update order (misalnya dari pending → completed)
  Future<Either<Failure, Order>> updateOrder(Order order);

  /// Ambil order by ID
  Future<Either<Failure, Order>> getOrderById(String orderId);

  /// Ambil semua orders dalam session
  Future<Either<Failure, List<Order>>> getOrdersBySession(String sessionId);
}
```

---

## Step 3: Buat Use Cases

### 3.1 — `GetProductsUseCase`

**File: `lib/domain/usecases/get_products_usecase.dart`**

| Input                               | Output                           |
| ----------------------------------- | -------------------------------- |
| `{String? query, String? category}` | `Either<Failure, List<Product>>` |

**Logic:**

1. Jika `query` ada → search by name/SKU
2. Jika `category` ada → filter by category
3. Jika keduanya null → return semua produk aktif

### 3.2 — `CreateOrderUseCase`

**File: `lib/domain/usecases/create_order_usecase.dart`**

| Input               | Output                   |
| ------------------- | ------------------------ |
| `CreateOrderParams` | `Either<Failure, Order>` |

**`CreateOrderParams`:**

```dart
class CreateOrderParams extends Equatable {
  final String sessionId;
  final String cashierId;
  final List<CartItem> items;
  final String status; // 'completed' | 'pending'
  final String? paymentMethod;
  final double? amountTendered;
  final double discountAmount;
}
```

**Logic:**

1. Validasi: minimal 1 item di cart
2. Generate `order_id` (UUID)
3. Hitung `totalAmount` = sum of all item subtotals
4. Hitung `grandTotal` = totalAmount - discountAmount
5. Jika `status = 'completed'` dan `paymentMethod = 'cash'`:
   - Validasi `amountTendered >= grandTotal`
   - Hitung `changeAmount = amountTendered - grandTotal`
6. Convert `CartItem` list ke `OrderItem` list (generate UUID per item)
7. Simpan order + order_items ke SQFlite dalam satu transaction
8. Return `Order`

---

## Step 4: Buat Data Models

### 4.1 — `ProductModel`

**File: `lib/data/models/product_model.dart`**

- `fromMap(Map<String, dynamic>)` — dari SQFlite row
- `toMap()` — ke SQFlite row
- Semua column names dari `DbConstants`

### 4.2 — `OrderModel`

**File: `lib/data/models/order_model.dart`**

- `fromMap(Map<String, dynamic>)` — dari SQFlite row
- `toMap()` — ke SQFlite row
- `fromFirestore` / `toFirestore` — untuk sync

### 4.3 — `OrderItemModel`

**File: `lib/data/models/order_item_model.dart`**

- `fromMap(Map<String, dynamic>)` — dari SQFlite row
- `toMap()` — ke SQFlite row
- `fromFirestore` / `toFirestore` — untuk sync

---

## Step 5: Implementasi `ProductLocalDataSource`

**File: `lib/data/datasources/local/sqflite/product_local_datasource.dart`**

| Method                               | SQL                                                          | Deskripsi          |
| ------------------------------------ | ------------------------------------------------------------ | ------------------ |
| `getProducts()`                      | `SELECT * FROM products WHERE is_active = 1`                 | Semua produk aktif |
| `searchProducts(String query)`       | `... WHERE (name LIKE ? OR sku LIKE ?) AND is_active = 1`    | Cari by nama/SKU   |
| `getProductsByCategory(String cat)`  | `... WHERE category = ? AND is_active = 1`                   | Filter by kategori |
| `getCategories()`                    | `SELECT DISTINCT category FROM products WHERE is_active = 1` | List kategori unik |
| `insertProduct(ProductModel)`        | `INSERT INTO products ...`                                   | Untuk seed data    |
| `insertProducts(List<ProductModel>)` | Batch insert                                                 | Seed banyak produk |

---

## Step 6: Implementasi `OrderLocalDataSource`

**File: `lib/data/datasources/local/sqflite/order_local_datasource.dart`**

| Method                                          | Deskripsi                                |
| ----------------------------------------------- | ---------------------------------------- |
| `insertOrder(OrderModel, List<OrderItemModel>)` | Insert order + items dalam 1 transaction |
| `getOrdersBySession(String sessionId)`          | List orders untuk sesi tertentu          |
| `getOrderById(String orderId)`                  | Order + items by ID                      |
| `updateOrder(OrderModel)`                       | Update order (status, payment info)      |
| `getOrderItems(String orderId)`                 | Items untuk order tertentu               |
| `getUnsyncedOrders()`                           | Untuk sync queue                         |
| `markOrderSynced(String orderId)`               | Setelah sync berhasil                    |

**Penting:**

- `insertOrder` HARUS menggunakan `batch` atau `transaction` untuk atomicity
- Order dan semua items di-insert bersamaan
- Jika salah satu gagal, rollback semua

---

## Step 7: Implementasi Repository Implementations

### 7.1 — `ProductRepositoryImpl`

**File: `lib/data/repositories/product_repository_impl.dart`**

- Delegate ke `ProductLocalDataSource`
- Wrap dalam try-catch → return `Left(CacheFailure)` on error

### 7.2 — `OrderRepositoryImpl`

**File: `lib/data/repositories/order_repository_impl.dart`**

- Delegate ke `OrderLocalDataSource`
- Convert antara Model dan Entity
- Wrap dalam try-catch → return `Left(CacheFailure)` on error

---

## Step 8: Seed Product Data

**File: `lib/data/datasources/local/sqflite/product_seeder.dart`** (atau utility)

Buat minimal 10-20 sample products untuk development:

```dart
final sampleProducts = [
  ProductModel(productId: '1', name: 'Nasi Goreng', sku: 'NG001', category: 'Makanan', price: 25000),
  ProductModel(productId: '2', name: 'Mie Goreng', sku: 'MG001', category: 'Makanan', price: 22000),
  ProductModel(productId: '3', name: 'Es Teh Manis', sku: 'ET001', category: 'Minuman', price: 8000),
  ProductModel(productId: '4', name: 'Es Jeruk', sku: 'EJ001', category: 'Minuman', price: 10000),
  ProductModel(productId: '5', name: 'Ayam Bakar', sku: 'AB001', category: 'Makanan', price: 35000),
  // ... tambahkan lebih banyak
];
```

**Jalankan seed:**

- Saat pertama kali app dibuka (cek flag di SharedPreferences)
- Atau via development-only button/command
- Pastikan idempotent (INSERT OR IGNORE)

---

## Step 9: Buat `CashierBloc`

### 9.1 — Events

**File: `lib/presentation/features/cashier/bloc/cashier_event.dart`**

```dart
class CashierProductsLoadRequested extends CashierEvent {}
class CashierProductSearched extends CashierEvent { final String query; }
class CashierCategorySelected extends CashierEvent { final String? category; }
class CashierProductAddedToCart extends CashierEvent { final Product product; }
class CashierCartItemQuantityChanged extends CashierEvent {
  final String productId;
  final int quantity;
}
class CashierCartItemRemoved extends CashierEvent { final String productId; }
class CashierCartCleared extends CashierEvent {}
class CashierDiscountChanged extends CashierEvent { final double discount; }
class CashierPaymentMethodSelected extends CashierEvent { final String method; } // 'cash' | 'qris'
class CashierCashAmountEntered extends CashierEvent { final double amount; }
class CashierPaymentConfirmed extends CashierEvent {}
class CashierPayLaterRequested extends CashierEvent {} // Bayar Nanti
```

### 9.2 — States

**File: `lib/presentation/features/cashier/bloc/cashier_state.dart`**

```dart
enum CashierStatus {
  initial,
  productsLoading,
  productsLoaded,
  processingPayment,
  paymentSuccess,
  payLaterSuccess,
  failure,
}

class CashierState extends Equatable {
  const CashierState({
    this.status = CashierStatus.initial,
    this.products = const [],
    this.filteredProducts = const [],
    this.cartItems = const [],
    this.categories = const [],
    this.selectedCategory,
    this.searchQuery = '',
    this.orderDiscount = 0,
    this.selectedPaymentMethod,
    this.cashAmountEntered,
    this.completedOrder,
    this.errorMessage = '',
  });

  final CashierStatus status;
  final List<Product> products;
  final List<Product> filteredProducts;
  final List<CartItem> cartItems;
  final List<String> categories;
  final String? selectedCategory;
  final String searchQuery;
  final double orderDiscount;
  final String? selectedPaymentMethod;
  final double? cashAmountEntered;
  final Order? completedOrder; // Untuk receipt
  final String errorMessage;

  // Computed getters
  double get cartTotal => cartItems.fold(0, (sum, item) => sum + item.subtotal);
  double get grandTotal => cartTotal - orderDiscount;
  double get changeAmount => (cashAmountEntered ?? 0) - grandTotal;
  int get cartItemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);
  bool get isCartEmpty => cartItems.isEmpty;
}
```

### 9.3 — BLoC

**File: `lib/presentation/features/cashier/bloc/cashier_bloc.dart`**

| Event                     | Handler Logic                                                                     |
| ------------------------- | --------------------------------------------------------------------------------- |
| `ProductsLoadRequested`   | Call `GetProductsUseCase` → load categories → emit `productsLoaded`               |
| `ProductSearched`         | Filter products by query → emit updated `filteredProducts`                        |
| `CategorySelected`        | Filter products by category → emit updated `filteredProducts`                     |
| `ProductAddedToCart`      | Jika product sudah di cart → increment qty, jika belum → add new `CartItem`       |
| `CartItemQuantityChanged` | Update quantity, jika 0 → remove dari cart                                        |
| `CartItemRemoved`         | Remove item dari cart                                                             |
| `CartCleared`             | Kosongkan cart                                                                    |
| `DiscountChanged`         | Update `orderDiscount`                                                            |
| `PaymentMethodSelected`   | Set `selectedPaymentMethod`                                                       |
| `CashAmountEntered`       | Set `cashAmountEntered`, hitung change                                            |
| `PaymentConfirmed`        | Validate → call `CreateOrderUseCase(status: 'completed')` → emit `paymentSuccess` |
| `PayLaterRequested`       | Confirm → call `CreateOrderUseCase(status: 'pending')` → emit `payLaterSuccess`   |

### 9.4 — Barrel File

**File: `lib/presentation/features/cashier/cashier.dart`**

---

## Step 10: Buat UI Cashier

### 10.1 — `CashierPage`

**File: `lib/presentation/features/cashier/pages/cashier_page.dart`**

- Provides `CashierBloc`
- Dispatch `CashierProductsLoadRequested` on init
- Child: `CashierView`

### 10.2 — `CashierView`

**File: `lib/presentation/features/cashier/pages/cashier_view.dart`**

**Layout (responsive, utamakan tablet/landscape):**

```
┌───────────────────────────────────────────────────┐
│ AppBar: [Search] [Category Filter]     [≡ Menu]   │
├──────────────────────────┬────────────────────────┤
│                          │                        │
│    Product Grid          │     Cart Panel         │
│    (scrollable grid)     │     (list + total)     │
│                          │                        │
│                          ├────────────────────────┤
│                          │  Total: Rp xxx.xxx     │
│                          │  [Bayar] [Bayar Nanti] │
└──────────────────────────┴────────────────────────┘
```

**Komponen:**

1. **Search Bar** — realtime filter saat mengetik
2. **Category Chips** — horizontal scroll, "Semua" + categories dari DB
3. **Product Grid** — `GridView` 2-4 kolom, tampilkan: nama, harga, gambar
4. **Cart Panel** — sidebar (tablet) atau bottom sheet (phone)

### 10.3 — `ProductGridWidget`

**File: `lib/presentation/features/cashier/widgets/product_grid_widget.dart`**

- Terima `List<Product>` dan callback `onProductTap`
- Setiap product card: gambar, nama, harga (Rp format)
- Tap → dispatch `CashierProductAddedToCart`

### 10.4 — `CartPanelWidget`

**File: `lib/presentation/features/cashier/widgets/cart_panel_widget.dart`**

| Elemen                          | Interaksi                           |
| ------------------------------- | ----------------------------------- |
| List item (nama, qty, subtotal) | Swipe to delete / tap to edit qty   |
| Qty stepper (+/-)               | Increment/decrement quantity        |
| Subtotal per item               | Auto calculate                      |
| Diskon order (opsional)         | Input field atau toggle             |
| Grand total                     | `cartTotal - discount`              |
| Tombol "Bayar"                  | Navigate ke payment selection       |
| Tombol "Bayar Nanti"            | Dispatch `CashierPayLaterRequested` |

### 10.5 — `PaymentMethodSheet`

**File: `lib/presentation/features/cashier/widgets/payment_method_sheet.dart`**

- Bottom sheet atau dialog
- 2 opsi: "Tunai (Cash)" dan "QRIS / E-Wallet"
- Tap → dispatch `CashierPaymentMethodSelected`
- Navigate ke screen yang sesuai

---

## Step 11: Buat UI Payment

### 11.1 — `CashPaymentPage`

**File: `lib/presentation/features/cashier/pages/cash_payment_page.dart`**

**Layout:**

1. Total yang harus dibayar: **Rp xxx.xxx** (large, prominent)
2. Input: "Uang diterima" — numeric keyboard
3. Quick amount buttons: Rp 50.000, Rp 100.000, "Uang Pas"
4. Display: Kembalian: **Rp xxx.xxx** (realtime calculation)
5. Tombol "Konfirmasi Pembayaran" — disabled jika `amountTendered < grandTotal`

**On Confirm:**

- Dispatch `CashierPaymentConfirmed`
- Navigate ke `ReceiptPage`

### 11.2 — `QrisPaymentPage`

**File: `lib/presentation/features/cashier/pages/qris_payment_page.dart`**

**Layout:**

1. Total: **Rp xxx.xxx**
2. QR Code display (static image atau generated)
3. Info text: "Tunjukkan QR code ini ke pembeli"
4. Tombol "Pembayaran Diterima" — manual confirmation oleh kasir
5. Tombol "Batal"

**On Confirm:**

- Dispatch `CashierPaymentConfirmed`
- Navigate ke `ReceiptPage`

---

## Step 12: Buat UI Receipt

### 12.1 — `ReceiptPage`

**File: `lib/presentation/features/cashier/pages/receipt_page.dart`**

**Layout:**

```
┌─────────────────────────────┐
│      [ Logo/Nama Toko ]     │
│      Tanggal & Waktu        │
│      No. Order: POS-001     │
├─────────────────────────────┤
│  Nasi Goreng   x2  50.000  │
│  Es Teh Manis  x1   8.000  │
│  ...                        │
├─────────────────────────────┤
│  Subtotal         58.000    │
│  Diskon           -5.000    │
│  TOTAL            53.000    │
├─────────────────────────────┤
│  Bayar (Tunai)   100.000    │
│  Kembalian        47.000    │
├─────────────────────────────┤
│  Kasir: John                │
│  Terima kasih!              │
└─────────────────────────────┘

[Bagikan]  [Transaksi Baru]
```

**Actions:**

- "Bagikan" → generate image/PDF → share via `share_plus`
- "Transaksi Baru" → clear cart → kembali ke `CashierView`

---

## Step 13: Buat Flow "Bayar Nanti"

**Alur:**

1. User tap "Bayar Nanti" di cart panel
2. Tampilkan confirmation dialog:
   - "Simpan pesanan untuk dibayar nanti?"
   - Tampilkan total dan jumlah item
   - Tombol "Batal" dan "Simpan"
3. Jika confirm → dispatch `CashierPayLaterRequested`
4. BLoC: call `CreateOrderUseCase(status: 'pending')` tanpa payment data
5. Emit `payLaterSuccess`
6. UI: tampilkan snackbar "Pesanan disimpan (No: POS-xxx)", clear cart

**Perbedaan dengan Bayar Sekarang:**

- `payment_method` = NULL
- `amount_tendered` = NULL
- `change_amount` = NULL
- `status` = 'pending'
- Tidak ada receipt screen

**Penyelesaian pembayaran dilakukan di Phase 5 (Order History).**

---

## Step 14: Register Dependencies

Tambahkan ke `lib/injection_container.dart`:

```dart
// ─── Products ───
sl.registerLazySingleton(() => ProductLocalDataSource(sl()));
sl.registerLazySingleton<ProductRepository>(
  () => ProductRepositoryImpl(localDataSource: sl()),
);
sl.registerLazySingleton(() => GetProductsUseCase(sl()));

// ─── Orders ───
sl.registerLazySingleton(() => OrderLocalDataSource(sl()));
sl.registerLazySingleton<OrderRepository>(
  () => OrderRepositoryImpl(localDataSource: sl()),
);
sl.registerLazySingleton(() => CreateOrderUseCase(sl()));

// ─── BLoC ───
sl.registerFactory(() => CashierBloc(
  getProductsUseCase: sl(),
  createOrderUseCase: sl(),
));
```

---

## Step 15: Tulis Unit Tests

### 15.1 — Use Case Tests

**`test/domain/usecases/get_products_usecase_test.dart`**

| Test Case                          | Expected |
| ---------------------------------- | -------- |
| Return all active products         | ✅       |
| Search by name → filtered list     | ✅       |
| Filter by category → filtered list | ✅       |
| No products → empty list           | ✅       |

**`test/domain/usecases/create_order_usecase_test.dart`**

| Test Case                                        | Expected |
| ------------------------------------------------ | -------- |
| Create completed order with cash → success       | ✅       |
| Create completed order with QRIS → success       | ✅       |
| Create pending order → success (no payment data) | ✅       |
| Empty cart → failure                             | ✅       |
| Cash tendered < total → failure                  | ✅       |
| Change amount calculated correctly               | ✅       |
| Discount applied correctly                       | ✅       |

### 15.2 — DataSource Tests

**`test/data/datasources/local/sqflite/product_local_datasource_test.dart`**
**`test/data/datasources/local/sqflite/order_local_datasource_test.dart`**

- Test CRUD operations
- Test transaction atomicity (order + items)
- Test search dan filter queries

### 15.3 — BLoC Tests

**`test/presentation/features/cashier/bloc/cashier_bloc_test.dart`**

| Test Case                          | Expected                                |
| ---------------------------------- | --------------------------------------- |
| Load products                      | `productsLoading` → `productsLoaded`    |
| Search products                    | filtered products updated               |
| Add to cart                        | cartItems updated, totals recalculated  |
| Update quantity                    | item qty updated, subtotal recalculated |
| Remove from cart                   | item removed                            |
| Clear cart                         | empty cart                              |
| Apply discount                     | grandTotal recalculated                 |
| Payment confirmed (cash)           | `processingPayment` → `paymentSuccess`  |
| Pay later                          | `processingPayment` → `payLaterSuccess` |
| Payment failed (insufficient cash) | `failure`                               |

---

## Step 16: Tulis Widget Tests

**`test/presentation/features/cashier/pages/cashier_page_test.dart`**

| Test Case                             | Expected |
| ------------------------------------- | -------- |
| Product grid renders products         | ✅       |
| Tap product adds to cart              | ✅       |
| Cart panel shows items dan total      | ✅       |
| Search filters products               | ✅       |
| Category chip filters products        | ✅       |
| Bayar button opens payment sheet      | ✅       |
| Cash payment page shows change        | ✅       |
| Receipt page tampil setelah payment   | ✅       |
| Bayar Nanti shows confirmation dialog | ✅       |

---

## Definition of Done — Phase 4

- [ ] Produk bisa di-browse, di-search, dan di-filter by category
- [ ] Cart bisa menambah item, ubah quantity, hapus item
- [ ] Diskon per order bisa diterapkan
- [ ] Pembayaran tunai: validasi uang diterima, hitung kembalian
- [ ] Pembayaran QRIS: tampilkan QR, manual confirm
- [ ] Receipt tampil setelah pembayaran berhasil dan bisa di-share
- [ ] "Bayar Nanti" menyimpan order sebagai `pending`
- [ ] Semua order tersimpan di SQFlite dengan `synced = false`
- [ ] Order items tersimpan atomically bersama order
- [ ] Semua use case, repository, dan BLoC ter-unit-test
- [ ] Widget test untuk CashierPage, payment screens, dan receipt
- [ ] `flutter analyze` clean, `flutter test` pass
