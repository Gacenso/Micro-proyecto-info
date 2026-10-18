import 'dart:math';

import 'package:flutter/material.dart';

import '../logica/puzzle_board.dart';
import '../models/tile_style.dart';
import 'puzzle_tile.dart';
import 'scene_painter.dart';

/// Dibuja el tablero. Cada pieza es un [AnimatedPositioned] identificado
/// por su número, así que al cambiar de lugar se desliza suavemente.
///
/// Se adapta al espacio disponible con [LayoutBuilder]: el tablero es
/// siempre cuadrado y tan grande como permita la pantalla.
class PuzzleBoardView extends StatelessWidget {
  const PuzzleBoardView({
    super.key,
    required this.board,
    required this.style,
    required this.onTileTap,
    required this.onSwipe,
    this.animate = true,
    this.showSolvedImage = false,
  });

  final PuzzleBoard board;
  final TileStyle style;
  final ValueChanged<int> onTileTap;
  final ValueChanged<SlideDirection> onSwipe;
  final bool animate;

  /// Al ganar en "Modo imagen" se muestra la imagen completa.
  final bool showSolvedImage;

  static const double _padding = 10;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = min(constraints.maxWidth, constraints.maxHeight);
        final inner = side - _padding * 2;
        final gap = board.size >= 5 ? 6.0 : 8.0;
        final cell = inner / board.size;
        final tileExtent = cell - gap;

        return Center(
          child: GestureDetector(
            onPanEnd: (details) => _handleSwipe(details.velocity),
            child: Container(
              width: side,
              height: side,
              padding: const EdgeInsets.all(_padding),
              decoration: BoxDecoration(
                color: style == TileStyle.retro
                    ? const Color(0xFF0B0B1A)
                    : scheme.surfaceContainerHighest.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(style == TileStyle.retro ? 6 : 24),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Stack(
                children: [
                  if (style == TileStyle.image)
                    Positioned.fill(
                      child: AnimatedOpacity(
                        opacity: showSolvedImage ? 1 : 0.18,
                        duration: const Duration(milliseconds: 400),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: const CustomPaint(painter: ScenePainter()),
                        ),
                      ),
                    ),
                  for (var index = 0; index < board.tiles.length; index++)
                    if (board.tiles[index] != 0)
                      AnimatedPositioned(
                        key: ValueKey(board.tiles[index]),
                        duration: animate
                            ? const Duration(milliseconds: 140)
                            : Duration.zero,
                        curve: Curves.easeOut,
                        left: board.columnOf(index) * cell + gap / 2,
                        top: board.rowOf(index) * cell + gap / 2,
                        width: tileExtent,
                        height: tileExtent,
                        child: AnimatedOpacity(
                          opacity: showSolvedImage ? 0 : 1,
                          duration: const Duration(milliseconds: 400),
                          child: PuzzleTile(
                            value: board.tiles[index],
                            gridSize: board.size,
                            extent: tileExtent,
                            boardExtent: inner,
                            style: style,
                            inPlace: board.tiles[index] == index + 1,
                            onTap: () => onTileTap(index),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Convierte un deslizamiento del dedo (o del mouse) en una dirección.
  void _handleSwipe(Velocity velocity) {
    final v = velocity.pixelsPerSecond;
    const minSpeed = 120;
    if (v.distance < minSpeed) return;
    if (v.dx.abs() > v.dy.abs()) {
      onSwipe(v.dx > 0 ? SlideDirection.right : SlideDirection.left);
    } else {
      onSwipe(v.dy > 0 ? SlideDirection.down : SlideDirection.up);
    }
  }
}
