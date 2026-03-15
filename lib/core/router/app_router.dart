import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poswork/core/router/animation/animation.dart';
import 'package:poswork/features/balance/opening/opening_balance.dart';
import 'package:poswork/features/login/login.dart';

part 'app_router_name.dart';
part 'app_router_paths.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final routers = GoRouter(
  debugLogDiagnostics: true,
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRouterPaths.openingBalance,
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
  ],
);
