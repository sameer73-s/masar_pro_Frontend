import 'package:flutter/material.dart';

import '../../../config/constants.dart';

Route<T> premiumPageRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: kDefaultDuration,
    reverseTransitionDuration: kDefaultDuration,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curve,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1).animate(curve),
          child: child,
        ),
      );
    },
  );
}
