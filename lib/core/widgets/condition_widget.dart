import 'package:flutter/material.dart';

class ConditionWidget extends StatelessWidget {
  const ConditionWidget({
    required this.isFirstCondition,
    required this.firstChild,
    required this.secondChild,
    super.key,
  });

  final bool isFirstCondition;

  final Widget firstChild;

  final Widget secondChild;

  @override
  Widget build(BuildContext context) {
    if (isFirstCondition) return firstChild;

    return secondChild;
  }
}
