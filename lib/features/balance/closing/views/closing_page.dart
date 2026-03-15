import 'package:flutter/material.dart';

class ClosingPage extends StatelessWidget {
  const ClosingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ClosingPageView();
  }
}

class _ClosingPageView extends StatelessWidget {
  const _ClosingPageView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Closing'),
    );
  }
}
