import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:poswork/core/widgets/widgets.dart';
import 'package:poswork/data/models/models.dart';
import 'package:poswork/features/balance/opening/opening_balance.dart';

class ConfrimBalanceListener extends StatelessWidget {
  const ConfrimBalanceListener({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<OpeningBalanceBloc, OpeningBalanceState>(
      listenWhen: (p, c) => p.submitStatus != c.submitStatus,
      listener: (context, state) {
        if (state.submitStatus.isLoading) {
          context.pop();
          unawaited(showLoadingDialog(context));
        }

        if (state.submitStatus.isSuccess) {
          context.pop();
        }
      },
      child: child,
    );
  }
}
