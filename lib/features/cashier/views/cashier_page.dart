import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poswork/core/router/app_router.dart';
import 'package:poswork/core/widgets/app_button.dart';

class CashierPage extends StatelessWidget {
  const CashierPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CashierView();
  }
}

class _CashierView extends StatelessWidget {
  const _CashierView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppButton.elevated(
        label: 'Go Payment',
        isWidthDynamic: true,
        onTap: () {
          unawaited(
            context.pushNamed(
              AppRouterName.payment,
              pathParameters: {'id': '1'},
            ),
          );
        },
      ),
    );
  }
}
