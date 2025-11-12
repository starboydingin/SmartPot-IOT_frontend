import 'package:flutter/material.dart';

Route createFadeSlideRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 600), 
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {

      final slideTween = Tween<Offset>(
        begin: const Offset(1.0, 0.0), 
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));

      final fadeTween = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeInOut));

      return SlideTransition(
        position: animation.drive(slideTween),
        child: FadeTransition(
          opacity: animation.drive(fadeTween),
          child: child,
        ),
      );
    },
  );
}
