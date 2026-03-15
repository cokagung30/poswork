import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({required this.paymentId, super.key});

  final String paymentId;

  @override
  Widget build(BuildContext context) {
    return const _PaymentPageView();
  }
}

class _PaymentPageView extends StatelessWidget {
  const _PaymentPageView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Payment'),
    );
  }
}
