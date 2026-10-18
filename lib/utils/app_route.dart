import 'package:flutter/material.dart';

/// Transición entre pantallas: deslizamiento suave con desvanecido.
/// Si el usuario desactivó las animaciones, el cambio es instantáneo.
Route<T> appRoute<T>(Widget page, {bool animate = true}) {
  return PageRouteBuilder<T>(
    transitionDuration:
        animate ? const Duration(milliseconds: 320) : Duration.zero,
    reverseTransitionDuration:
        animate ? const Duration(milliseconds: 260) : Duration.zero,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
