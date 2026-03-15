import 'package:flutter/material.dart';

Future<void> showLoadingDialog(BuildContext context) async {
  await showDialog<dynamic>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PopScope(
      canPop: false,
      child: Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
}
