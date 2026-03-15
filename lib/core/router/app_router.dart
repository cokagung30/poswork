import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poswork/core/router/animation/animation.dart';
import 'package:poswork/features/balance/closing/closing.dart';
import 'package:poswork/features/balance/opening/opening_balance.dart';
import 'package:poswork/features/cashier/cashier.dart';
import 'package:poswork/features/history/history.dart';
import 'package:poswork/features/login/login.dart';
import 'package:poswork/features/main/main.dart';
import 'package:poswork/features/payment/payment.dart';

part 'app_router_name.dart';
part 'app_router_paths.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final routers = GoRouter(
  debugLogDiagnostics: true,
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRouterPaths.cashier,
  routes: [
    GoRoute(
      path: AppRouterPaths.login,
      name: AppRouterName.login,
      pageBuilder: (_, _) {
        return FadeTransitionPage(child: const LoginPage());
      },
    ),
    GoRoute(
      path: AppRouterPaths.openingBalance,
      name: AppRouterName.openingBalance,
      pageBuilder: (_, _) {
        return FadeTransitionPage(child: const OpeningBalancePage());
      },
    ),
    StatefulShellRoute(
      builder: (context, state, navigationShell) {
        return navigationShell;
      },
      navigatorContainerBuilder: (context, navigationShell, children) {
        return MainPage(navigationShell: navigationShell, children: children);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRouterPaths.cashier,
              name: AppRouterName.cashier,
              builder: (_, _) => const CashierPage(),
            ),
            GoRoute(
              path: AppRouterPaths.payment,
              name: AppRouterName.payment,
              builder: (_, state) {
                final paymentId = state.pathParameters['id'];

                if (paymentId == null) {
                  throw Exception('Payment id cannot be null');
                }

                return PaymentPage(paymentId: paymentId);
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRouterPaths.history,
              name: AppRouterName.history,
              builder: (_, _) => const HistoryPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRouterPaths.closing,
              name: AppRouterName.closing,
              builder: (_, _) => const ClosingPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
