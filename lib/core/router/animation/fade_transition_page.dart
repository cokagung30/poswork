import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FadeTransitionPage extends CustomTransitionPage<void> {
  FadeTransitionPage({
    required super.child,
    super.opaque,
  }) : super(
         transitionsBuilder: (c, animation, a2, child) => FadeTransition(
           opacity: animation.drive(_curveTween),
           child: child,
         ),
         transitionDuration: const Duration(milliseconds: 175),
       );

  static final _curveTween = CurveTween(curve: Curves.easeIn);
}
