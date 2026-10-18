import 'package:flutter/material.dart';

/// Logo del juego: una mini cuadrícula 3x3 con una pieza faltante y el
/// título "15-Puzzle Flutter".
class GameLogo extends StatelessWidget {
  const GameLogo({super.key, this.size = 120, this.showTitle = true});

  final double size;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cell = size / 3;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              for (var i = 0; i < 8; i++)
                Positioned(
                  left: (i % 3) * cell + 3,
                  top: (i ~/ 3) * cell + 3,
                  width: cell - 6,
                  height: cell - 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: i == 4 ? scheme.secondary : scheme.primary,
                      borderRadius: BorderRadius.circular(cell * 0.22),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: i == 4 ? scheme.onSecondary : scheme.onPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: cell * 0.42,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (showTitle) ...[
          const SizedBox(height: 20),
          Text(
            '15-Puzzle',
            style: TextStyle(
              fontSize: size * 0.32,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
              height: 1,
            ),
          ),
          Text(
            'FLUTTER',
            style: TextStyle(
              fontSize: size * 0.13,
              fontWeight: FontWeight.w600,
              letterSpacing: size * 0.06,
              color: scheme.primary,
            ),
          ),
        ],
      ],
    );
  }
}
