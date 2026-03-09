# Flutter POS Mobile App — Master Plan
### Hybrid · Offline First + Firebase Sync · BLoC · SQFlite · SharedPreferences

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [App Flow & Navigation](#2-app-flow--navigation)
3. [Feature Specifications](#3-feature-specifications)
   - 3.1 [Login with PIN](#31-login-with-pin)
   - 3.2 [Opening Balance](#32-opening-balance)
   - 3.3 [Cashier (Kasir)](#33-cashier-kasir)
   - 3.4 [Order History (Riwayat Pesanan)](#34-order-history-riwayat-pesanan)
   - 3.5 [Closing](#35-closing)
   - 3.6 [Logout](#36-logout)
4. [Data Architecture](#4-data-architecture)
5. [Offline-First & Sync Strategy](#5-offline-first--sync-strategy)
6. [Tech Stack](#6-tech-stack)
7. [Database Schema](#7-database-schema)
8. [BLoC Map](#8-bloc-map)
9. [Development Phases](#9-development-phases)

---

## 1. Project Overview

A **mobile Point-of-Sale (POS)** application built with Flutter, designed to operate reliably in both online and offline environments. All transactions are stored locally using SQFlite and automatically synchronized to Firebase when connectivity is restored.

| Property | Detail |
|---|---|
| Platform | Android & iOS |
| Mode | Hybrid (Offline-first + Cloud Sync) |
| State Management | BLoC |
| Local Storage | SQFlite (transactions) · SharedPreferences (session) |
| Cloud Backend | Firebase (Firestore + Auth) |
| Payment Methods | Tunai (Cash) · QRIS / E-Wallet |
| Architecture | Clean Architecture (Data · Domain · Presentation) |

---

## 2. App Flow & Navigation

```
┌─────────────────────────────────────────────────────────┐
│                        App Start                        │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                  PIN Login Screen                       │
│   User enters 4-6 digit PIN to authenticate             │
└─────────────────────────┬───────────────────────────────┘
                          │ PIN valid
                          ▼
┌─────────────────────────────────────────────────────────┐
│               Check Session State                       │
│   Has today's session been opened?                      │
└──────────┬──────────────────────────────┬───────────────┘
           │ No                           │ Yes
           ▼                             ▼
┌──────────────────────┐     ┌───────────────────────────┐
│   Opening Balance    │     │      Main POS Screen      │
│   Enter cash modal   │     │         (Kasir)           │
└──────────┬───────────┘     └───────────────────────────┘
           │ Confirmed                   │
           └─────────────────────────────┘
                          │
          ┌───────────────┼───────────────┐
          ▼               ▼               ▼
    ┌──────────┐  ┌──────────────┐  ┌──────────┐
    │  Kasir   │  │  Riwayat     │  │ Closing  │
    │ (Home)   │  │  Pesanan     │  │          │
    └──────────┘  └──────────────┘  └──────────┘
                                         │
                                         ▼
                                   ┌──────────┐
                                   │  Logout  │
                                   └──────────┘
```

### Route Map

| Route Name | Path | Description |
|---|---|---|
| `login` | `/` | PIN entry screen |
| `opening` | `/opening` | Opening balance entry |
| `cashier` | `/cashier` | Main POS / transaction screen |
| `order_history` | `/history` | List of all orders in current session |
| `order_detail` | `/history/:id` | Detail view of a single order |
| `closing` | `/closing` | End-of-day closing summary |
| `closing_result` | `/closing/result` | Final closing report |

---

## 3. Feature Specifications

---

### 3.1 Login with PIN

**Purpose:** Authenticate the cashier before starting any session. Prevents unauthorized access without requiring a full username/password flow.

#### User Flow
1. App launches and displays a PIN pad screen.
2. User enters their 4–6 digit PIN.
3. PIN is validated against the locally stored hashed PIN (from SharedPreferences).
4. On success → check if a session is already open.
5. On failure → show error, increment failed attempt counter.
6. After 5 failed attempts → lock the app for a configurable duration.

#### Functional Requirements

| # | Requirement |
|---|---|
| FR-01 | PIN must be 4 to 6 digits in length |
| FR-02 | PIN is stored as a hashed value, never plain text |
| FR-03 | Display masked input (●●●●) as user types |
| FR-04 | Failed attempt counter resets on successful login |
| FR-05 | App lockout after 5 consecutive failed attempts |
| FR-06 | Session token saved to SharedPreferences upon success |
| FR-07 | Auto-redirect to Kasir if a valid session token exists and has not expired |

#### Local Storage
- `SharedPreferences`: stores hashed PIN, session token, session expiry, failed attempt count, lockout timestamp.

---

### 3.2 Opening Balance

**Purpose:** Record the initial cash amount in the cash drawer before the cashier session begins. This becomes the baseline for the end-of-day closing calculation.

#### User Flow
1. After successful PIN login, app checks if today's session has an opening balance recorded.
2. If not → display the Opening Balance screen.
3. Cashier enters the physical cash amount in the drawer.
4. Cashier confirms the amount.
5. Session is created and recorded in SQFlite and synced to Firestore.
6. User is navigated to the main Kasir screen.

#### Functional Requirements

| # | Requirement |
|---|---|
| FR-01 | Opening balance must be a non-negative numeric value |
| FR-02 | Only one opening balance is allowed per calendar day per device |
| FR-03 | Opening balance is recorded with timestamp and cashier ID |
| FR-04 | Confirmation dialog shown before session is opened |
| FR-05 | Opening balance value is visible in the session summary throughout the day |
| FR-06 | Session record is persisted locally first, then synced to Firestore |

#### Data Stored (SQFlite — `sessions` table)
- `session_id`, `cashier_id`, `opened_at`, `opening_balance`, `status`, `synced`

---

### 3.3 Cashier (Kasir)

**Purpose:** The core transaction screen where products are selected, quantities adjusted, payment is processed, and receipts are issued.

#### User Flow

**Alur Normal (Bayar Sekarang)**
1. Cashier browses or searches for products.
2. Taps a product to add it to the current order (cart).
3. Adjusts quantities or removes items from the cart.
4. Reviews the order total.
5. Taps **"Bayar"** → selects payment method: **Tunai (Cash)** or **QRIS / E-Wallet**.
6. For Cash: enters amount tendered → system calculates change.
7. For QRIS: displays QR code → cashier confirms payment received.
8. Transaction is saved to SQFlite with status `completed`.
9. Receipt summary is shown.
10. Cart is cleared, ready for next transaction.

**Alur Bayar Nanti (Pending Order)**
1. Cashier builds the order as usual (steps 1–4 above).
2. Taps **"Bayar Nanti"** → confirmation dialog is shown.
3. Order is saved to SQFlite with status `pending` and an auto-generated order number.
4. Cart is cleared, ready for a new transaction.
5. When the customer is ready to pay, cashier navigates to **Riwayat Pesanan**.
6. Cashier searches or locates the order by order number or filters by status `pending`.
7. Taps the pending order → directed to the Payment screen to complete payment.
8. After payment is confirmed, order status is updated to `completed`.

#### Functional Requirements

| # | Requirement |
|---|---|
| FR-01 | Product list loaded from local SQFlite `products` table |
| FR-02 | Search products by name or SKU |
| FR-03 | Filter products by category |
| FR-04 | Cart supports multiple items with quantity adjustment |
| FR-05 | Cart persists if app is minimized (in-memory via BLoC state) |
| FR-06 | Support discount per item or per order (percentage or fixed) |
| FR-07 | Cash payment: validate tendered amount ≥ order total |
| FR-08 | Cash payment: display change amount clearly |
| FR-09 | QRIS payment: display a static or dynamic QR code |
| FR-10 | QRIS payment: manual confirmation by cashier |
| FR-11 | Each transaction saved with timestamp, items, payment method, and cashier ID |
| FR-12 | Transaction saved to SQFlite immediately; queued for Firestore sync |
| FR-13 | Receipt screen shown after every successful transaction |
| FR-14 | Receipt can be shared via device share sheet (PDF or image) |
| FR-15 | "Bayar Nanti" button available on the cart screen |
| FR-16 | Tapping "Bayar Nanti" shows a confirmation dialog before saving |
| FR-17 | Pending order saved with status `pending` and a unique order number |
| FR-18 | Pending order does not trigger a receipt screen |
| FR-19 | Multiple pending orders can exist simultaneously within a session |

#### Sub-screens

| Screen | Purpose |
|---|---|
| Product Grid / List | Browse and select products |
| Cart Panel | Review items, quantities, and subtotals |
| Payment Method Sheet | Select Cash or QRIS |
| Cash Payment Screen | Enter tendered amount, view change |
| QRIS Payment Screen | Display QR code, confirm payment |
| Receipt Screen | Show order summary post-transaction |

#### Data Stored (SQFlite — `orders` + `order_items` tables)
- `order_id`, `session_id`, `cashier_id`, `created_at`, `total_amount`, `discount`, `payment_method`, `amount_tendered`, `change_amount`, `status` (`pending` / `completed` / `voided`), `synced`
- `order_item_id`, `order_id`, `product_id`, `product_name`, `unit_price`, `quantity`, `subtotal`

---

### 3.4 Order History (Riwayat Pesanan)

**Purpose:** Allow the cashier to review all transactions in the current session, including completing payment for orders that were previously saved with "Bayar Nanti".

#### User Flow

**Melihat Riwayat**
1. Cashier taps "Riwayat Pesanan" from the main navigation.
2. List of orders is displayed, sorted by most recent first.
3. Orders are visually distinguished by status: `pending`, `completed`, `voided`.
4. Cashier can filter by status, payment method, or search by order number.
5. Tapping a `completed` or `voided` order opens the Order Detail screen (read-only).

**Menyelesaikan Pembayaran Pending**
1. Cashier locates the pending order by searching by order number or filtering by status `pending`.
2. Taps the pending order → a detail screen is shown with full item breakdown.
3. Cashier taps **"Proses Pembayaran"** button.
4. App navigates to the Payment Method screen (same flow as normal checkout).
5. After payment is confirmed, order status is updated to `completed` in SQFlite.
6. Receipt screen is shown.

#### Functional Requirements

| # | Requirement |
|---|---|
| FR-01 | Display all orders from the current session by default |
| FR-02 | Allow filtering by order status (`pending`, `completed`, `voided`) |
| FR-03 | Allow filtering by payment method (Cash / QRIS) |
| FR-04 | Allow filtering by date range |
| FR-05 | Search by order number or product name |
| FR-06 | Each list item shows: order number, time, total, payment method, status badge |
| FR-07 | Pending orders are visually highlighted to distinguish from completed ones |
| FR-08 | Order detail shows full item list with quantities and prices |
| FR-09 | Show sync status indicator (synced / pending / failed) |
| FR-10 | Pending order detail screen shows a "Proses Pembayaran" button |
| FR-11 | Tapping "Proses Pembayaran" navigates to the payment method selection screen |
| FR-12 | After payment is completed, order status is updated from `pending` to `completed` |
| FR-13 | Completed and voided orders are read-only — no payment button shown |
| FR-14 | Support void/cancel order with confirmation (only for `pending` or `completed` orders within a configurable time window) |

---

### 3.5 Closing

**Purpose:** End the cashier session for the day. Summarizes all transactions, reconciles cash, and records the closing balance.

#### User Flow
1. Cashier navigates to "Closing" from the main menu.
2. App displays the session summary:
   - Opening balance
   - Total cash sales
   - Total QRIS sales
   - Expected cash in drawer
3. Cashier counts physical cash and enters the actual closing cash amount.
4. System calculates the difference (over/short).
5. Cashier confirms closing with PIN re-entry.
6. Session is marked as `closed` in SQFlite and synced to Firestore.
7. Closing report is displayed and can be exported/shared.

#### Functional Requirements

| # | Requirement |
|---|---|
| FR-01 | Closing is only allowed if an open session exists |
| FR-02 | Session summary auto-calculated from all orders in the session |
| FR-03 | Cashier must enter actual physical cash count |
| FR-04 | System displays variance (expected vs. actual cash) |
| FR-05 | PIN re-entry required to confirm closing |
| FR-06 | Session status updated to `closed` with `closed_at` timestamp |
| FR-07 | Closing report exportable as PDF or shareable via share sheet |
| FR-08 | Sync all pending transactions before finalizing closing |
| FR-09 | Prevent new transactions after session is closed |

#### Closing Report Contents
- Session date & ID
- Cashier name / ID
- Opening balance
- Total transactions count
- Total sales by payment method (Cash, QRIS)
- Expected cash in drawer
- Actual cash counted
- Variance (over / short)
- Session open & close timestamps

#### Data Stored (SQFlite — `sessions` table update)
- `closed_at`, `closing_balance`, `expected_cash`, `variance`, `total_cash_sales`, `total_qris_sales`, `total_orders`

---

### 3.6 Logout

**Purpose:** Safely end the authenticated cashier session and return the app to the PIN login screen.

#### User Flow
1. Cashier taps "Logout" from the main menu.
2. If there is an **open session** (not yet closed):
   - Warning dialog is shown: *"Sesi belum ditutup. Apakah Anda yakin ingin logout?"*
   - Cashier must confirm.
3. If no open session or confirmed:
   - Session token cleared from SharedPreferences.
   - BLoC states reset.
   - App navigates back to PIN Login screen.

#### Functional Requirements

| # | Requirement |
|---|---|
| FR-01 | Always show a confirmation dialog before logging out |
| FR-02 | Warn explicitly if the current session has not been closed |
| FR-03 | Clear session token and all in-memory state on logout |
| FR-04 | Local SQFlite data is preserved after logout |
| FR-05 | Pending sync queue is retained and resumes on next login |

---

## 4. Data Architecture

```
┌──────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                     │
│   PIN Login · Opening · Kasir · History · Closing        │
│                   (BLoC per feature)                     │
└─────────────────────────┬────────────────────────────────┘
                          │
┌─────────────────────────▼────────────────────────────────┐
│                    DOMAIN LAYER                          │
│   Entities · Use Cases · Repository Interfaces           │
└─────────────────────────┬────────────────────────────────┘
                          │
┌─────────────────────────▼────────────────────────────────┐
│                     DATA LAYER                           │
│                                                          │
│  ┌─────────────────────┐   ┌──────────────────────────┐  │
│  │    LOCAL (SQFlite)  │   │   REMOTE (Firebase)      │  │
│  │  sessions           │   │   Firestore              │  │
│  │  orders             │◄──►  /sessions/{id}          │  │
│  │  order_items        │   │  /orders/{id}            │  │
│  │  products           │   │  /order_items/{id}       │  │
│  └─────────────────────┘   └──────────────────────────┘  │
│                                                          │
│  ┌─────────────────────────────────────────────────┐     │
│  │         SharedPreferences                        │     │
│  │  hashed_pin · session_token · session_expiry    │     │
│  │  failed_attempts · lockout_until                │     │
│  └─────────────────────────────────────────────────┘     │
└──────────────────────────────────────────────────────────┘
```

---

## 5. Offline-First & Sync Strategy

The app is designed to work fully without internet connectivity. Firebase sync happens opportunistically when connectivity is available.

### Principles
- All writes go to **SQFlite first**, always.
- Every record in SQFlite has a `synced` boolean flag and a `synced_at` timestamp.
- A background **SyncManager** service monitors connectivity and processes the sync queue.
- Sync is **idempotent** — re-syncing the same record does not create duplicates (uses `order_id` as Firestore document ID).

### Sync Flow

```
User Action
    │
    ▼
Write to SQFlite (synced = false)
    │
    ▼
SyncManager detects connectivity
    │
    ▼
Read all records where synced = false
    │
    ▼
Upload to Firestore (upsert by document ID)
    │
    ▼
On success → update SQFlite: synced = true, synced_at = now
On failure → retain in queue, retry on next connectivity event
```

### Sync Priority Order
1. Sessions (opening & closing)
2. Orders
3. Order Items

### Conflict Strategy
- Local data is always the **source of truth** for the current device.
- Firestore data is used only for reporting and cross-device visibility.
- No two-way merge is required for this version.

## 6. Tech Stack

| Category | Package | Purpose |
|---|---|---|
| Scaffolding | `very_good_cli` | Project structure, flavors, lint setup |
| State Management | `flutter_bloc` | Feature-level BLoC state management |
| Local DB | `sqflite` | Persistent transaction and session storage |
| Key-Value Storage | `shared_preferences` | PIN hash, session token, auth state |
| Firebase Core | `firebase_core` | Firebase SDK initialization |
| Cloud Firestore | `cloud_firestore` | Cloud sync for sessions and orders |
| DI | `get_it` | Service locator and dependency injection |
| Equatable | `equatable` | Value equality in BLoC states |
| Connectivity | `connectivity_plus` | Detect online/offline status for sync |
| Asset Generation | `flutter_gen` | Type-safe asset references |
| Crypto | `crypto` | SHA-256 PIN hashing |
| PDF Export | `pdf` + `printing` | Closing report and receipt PDF generation |
| Share | `share_plus` | Share receipts and reports via device share sheet |
| UUID | `uuid` | Generate unique IDs for orders and sessions |

---

## 7. Database Schema

### `sessions`
| Column | Type | Description |
|---|---|---|
| `session_id` | TEXT PK | Unique session identifier (UUID) |
| `cashier_id` | TEXT | Identifier of the logged-in cashier |
| `opened_at` | INTEGER | Unix timestamp of session open |
| `closed_at` | INTEGER | Unix timestamp of session close (nullable) |
| `opening_balance` | REAL | Cash in drawer at session start |
| `closing_balance` | REAL | Physical cash counted at close (nullable) |
| `expected_cash` | REAL | Calculated expected cash at close (nullable) |
| `variance` | REAL | Difference: closing_balance − expected_cash |
| `total_cash_sales` | REAL | Sum of all cash transactions |
| `total_qris_sales` | REAL | Sum of all QRIS transactions |
| `total_orders` | INTEGER | Count of transactions in session |
| `status` | TEXT | `open` or `closed` |
| `synced` | INTEGER | 0 = pending, 1 = synced |
| `synced_at` | INTEGER | Timestamp of last successful sync |

### `orders`
| Column | Type | Description |
|---|---|---|
| `order_id` | TEXT PK | Unique order identifier (UUID) |
| `session_id` | TEXT FK | References `sessions.session_id` |
| `cashier_id` | TEXT | Identifier of the cashier |
| `created_at` | INTEGER | Unix timestamp of order creation |
| `total_amount` | REAL | Total before discount |
| `discount_amount` | REAL | Total discount applied |
| `grand_total` | REAL | Final amount charged |
| `payment_method` | TEXT | `cash` or `qris` |
| `amount_tendered` | REAL | Amount given by customer (cash only) |
| `change_amount` | REAL | Change returned (cash only) |
| `status` | TEXT | `pending`, `completed`, or `voided` |
| `synced` | INTEGER | 0 = pending, 1 = synced |
| `synced_at` | INTEGER | Timestamp of last successful sync |

### `order_items`
| Column | Type | Description |
|---|---|---|
| `order_item_id` | TEXT PK | Unique item identifier (UUID) |
| `order_id` | TEXT FK | References `orders.order_id` |
| `product_id` | TEXT | Product identifier |
| `product_name` | TEXT | Snapshot of product name at time of sale |
| `unit_price` | REAL | Snapshot of unit price at time of sale |
| `quantity` | INTEGER | Quantity sold |
| `discount_amount` | REAL | Item-level discount |
| `subtotal` | REAL | (unit_price × quantity) − discount |

### `products`
| Column | Type | Description |
|---|---|---|
| `product_id` | TEXT PK | Unique product identifier |
| `name` | TEXT | Product display name |
| `sku` | TEXT | Stock keeping unit code |
| `category` | TEXT | Product category |
| `price` | REAL | Selling price |
| `image_url` | TEXT | Local or remote image path |
| `is_active` | INTEGER | 1 = active, 0 = inactive |
| `updated_at` | INTEGER | Last update timestamp |

---

## 8. BLoC Map

| Feature | BLoC | Responsibilities |
|---|---|---|
| Auth | `AuthBloc` | Validate PIN, manage lockout counter, handle logout |
| Opening | `OpeningBloc` | Submit opening balance, create session record |
| Cashier | `CashierBloc` | Manage cart state, process payment, save order |
| History | `HistoryBloc` | Load and filter order list, complete pending payment, load order detail |
| Closing | `ClosingBloc` | Compute session summary, submit closing, export report |

### BLoC Dependency Flow
```
AuthBloc
    ├── VerifyPinUseCase
    ├── GetActiveSessionUseCase
    └── LogoutUseCase

OpeningBloc
    └── OpenSessionUseCase

CashierBloc
    └── CreateOrderUseCase

HistoryBloc
    ├── GetOrdersUseCase
    ├── GetOrderDetailUseCase
    ├── CompleteOrderUseCase
    └── VoidOrderUseCase

ClosingBloc
    ├── GetActiveSessionUseCase
    ├── GetOrdersUseCase
    └── CloseSessionUseCase
```

---

## 9. Development Phases

### Phase 1 — Foundation
> Setup project scaffolding, architecture skeleton, and local database.

- [ ] Scaffold project with Very Good CLI
- [ ] Configure flavors (dev, staging, production)
- [ ] Set up Clean Architecture folder structure
- [ ] Implement `DatabaseHelper` with schema (sessions, orders, order_items, products)
- [ ] Implement `AuthPreferencesDataSource` (PIN hash, session token)
- [ ] Implement `SyncManager` skeleton with connectivity detection
- [ ] Configure Firebase and Firestore collections
- [ ] Set up `GetIt` dependency injection container

### Phase 2 — Authentication
> PIN login, lockout, and session token management.

- [ ] Implement `VerifyPinUseCase` and `SavePinUseCase`
- [ ] Implement `AuthBloc` with lockout logic and post-login session check
- [ ] Build `LoginPage` with `PinPadWidget` and `PinIndicatorWidget`
- [ ] Write unit tests for auth use cases and BLoC

### Phase 3 — Session Lifecycle
> Opening balance and session closing flows.

- [ ] Implement `SessionLocalDataSource` and `SessionRepositoryImpl`
- [ ] Implement `OpenSessionUseCase` and `CloseSessionUseCase`
- [ ] Build `OpeningPage` with balance input
- [ ] Build `ClosingPage` with session summary and cash count input
- [ ] Build `ClosingResultPage` with exportable report
- [ ] Implement PDF generation for closing report
- [ ] Write unit tests for session use cases and BLoCs

### Phase 4 — Cashier & Transactions
> Core POS transaction flow with payment processing.

- [ ] Seed product data into local SQFlite
- [ ] Implement `OrderLocalDataSource` and `OrderRepositoryImpl`
- [ ] Implement `CreateOrderUseCase`
- [ ] Build `CashierPage` with `ProductGridWidget` and cart panel
- [ ] Build `CashPaymentPage` with change calculation
- [ ] Build `QrisPaymentPage` with QR display
- [ ] Build `ReceiptPage` with share functionality
- [ ] Write unit tests for order use cases and `CashierBloc`

### Phase 5 — Order History
> Transaction review and void functionality.

- [ ] Implement `GetOrdersUseCase` and `GetOrderDetailUseCase`
- [ ] Implement `VoidOrderUseCase`
- [ ] Build `HistoryPage` with filtering and search
- [ ] Build `OrderDetailPage`
- [ ] Write unit tests for history use cases and BLoC

### Phase 6 — Sync & Offline Hardening
> Complete Firestore sync and offline resilience.

- [ ] Implement `SessionRemoteDataSource` and `OrderRemoteDataSource`
- [ ] Complete `SyncManager` with retry logic and queue processing
- [ ] Add `SyncStatusBadgeWidget` to relevant screens
- [ ] Test full offline → online sync cycle
- [ ] Handle edge cases: sync conflict, partial upload failure

### Phase 7 — Polish & Release
> UI refinement, testing, and deployment preparation.

- [ ] Apply final UI/UX polish across all screens
- [ ] Complete widget test coverage for critical flows
- [ ] Configure FlutterGen for all assets
- [ ] Performance profiling and optimization
- [ ] Configure Firebase App Check for production
- [ ] Build and sign release APK / IPA

---

> **Master Plan Version:** 1.0.0  
> **Flutter SDK:** ≥ 3.x · **Dart SDK:** ≥ 3.x  
> **Last Updated:** March 2026
