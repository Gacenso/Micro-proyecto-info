import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Fondo temático común a todas las pantallas: un degradado suave con
/// algunas piezas decorativas difuminadas.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppTheme.backgroundGradient(scheme)),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: _DecorTile(size: 160, color: scheme.primary, angle: 0.3),
          ),
          Positioned(
            bottom: -50,
            left: -40,
            child: _DecorTile(size: 200, color: scheme.secondary, angle: -0.25),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _DecorTile extends StatelessWidget {
  const _DecorTile({
    required this.size,
    required this.color,
    required this.angle,
  });

  final double size;
  final Color color;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(size * 0.22),
          ),
        ),
      ),
    );
  }
}
