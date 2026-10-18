import 'package:flutter/material.dart';

import '../models/tile_style.dart';
import '../theme/app_theme.dart';
import 'scene_painter.dart';

/// Una pieza del tablero, dibujada según el estilo elegido.
class PuzzleTile extends StatelessWidget {
  const PuzzleTile({
    super.key,
    required this.value,
    required this.gridSize,
    required this.extent,
    required this.boardExtent,
    required this.style,
    required this.inPlace,
    required this.onTap,
  });

  /// Número de la pieza (1..n).
  final int value;

  /// Filas/columnas del tablero (3, 4 o 5).
  final int gridSize;

  /// Tamaño en píxeles de la pieza.
  final double extent;

  /// Tamaño del área de juego, para recortar la imagen en "Modo imagen".
  final double boardExtent;

  final TileStyle style;

  /// Si la pieza ya está en su posición final.
  final bool inPlace;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(
      style == TileStyle.retro ? 4 : extent * 0.18,
    );
    final fontSize = extent * (style == TileStyle.retro ? 0.26 : 0.38);

    return Semantics(
      button: true,
      label: 'Pieza $value${inPlace ? ', en su lugar' : ''}',
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          canRequestFocus: false,
          borderRadius: radius,
          child: Ink(
            decoration: _decoration(scheme, radius),
            child: ClipRRect(
              borderRadius: radius,
              child: style == TileStyle.image
                  ? _imageContent(scheme)
                  : Center(child: _number(scheme, fontSize)),
            ),
          ),
        ),
      ),
    );
  }

  Color _colorfulColor() {
    final total = gridSize * gridSize - 1;
    final hue = (value - 1) / total * 320;
    return HSLColor.fromAHSL(1, hue, 0.62, 0.52).toColor();
  }

  BoxDecoration _decoration(ColorScheme scheme, BorderRadius radius) {
    const neon = Color(0xFF39FF14);
    final colorful = _colorfulColor();
    return switch (style) {
      TileStyle.classic => BoxDecoration(
          color: inPlace ? scheme.primary : scheme.primaryContainer,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.18),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
      TileStyle.colorful => BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(colorful, Colors.white, 0.15)!,
              Color.lerp(colorful, Colors.black, 0.12)!,
            ],
          ),
          borderRadius: radius,
          border: inPlace ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: [
            BoxShadow(
              color: colorful.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      TileStyle.retro => BoxDecoration(
          color: const Color(0xFF14142B),
          borderRadius: radius,
          border: Border.all(
            color: inPlace ? neon : const Color(0xFFFF2E88),
            width: 3,
          ),
          boxShadow: const [
            BoxShadow(color: Color(0xFF000000), offset: Offset(4, 4)),
          ],
        ),
      TileStyle.minimal => BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.6),
          borderRadius: radius,
          border: Border.all(
            color: inPlace ? scheme.primary : scheme.outlineVariant,
            width: inPlace ? 2 : 1.2,
          ),
        ),
      TileStyle.image => BoxDecoration(
          borderRadius: radius,
          border: Border.all(
            color: Colors.white.withValues(alpha: inPlace ? 0.9 : 0.35),
            width: inPlace ? 2 : 1,
          ),
        ),
    };
  }

  Widget _number(ColorScheme scheme, double fontSize) {
    final textStyle = switch (style) {
      TileStyle.classic => TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: inPlace ? scheme.onPrimary : scheme.onPrimaryContainer,
        ),
      TileStyle.colorful => TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          shadows: const [Shadow(blurRadius: 4, color: Color(0x55000000))],
        ),
      TileStyle.retro => TextStyle(
          fontFamily: AppTheme.retroFontFamily,
          fontSize: fontSize,
          color: inPlace ? const Color(0xFF39FF14) : const Color(0xFFFFE66D),
        ),
      TileStyle.minimal => TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
          color: inPlace ? scheme.primary : scheme.onSurface,
        ),
      TileStyle.image => TextStyle(fontSize: fontSize, color: Colors.white),
    };
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text('$value', style: textStyle),
    );
  }

  /// Recorte del paisaje que le corresponde a esta pieza según su número
  /// (su posición final), más un número pequeño de ayuda en la esquina.
  Widget _imageContent(ColorScheme scheme) {
    final target = value - 1;
    final cell = boardExtent / gridSize;
    final dx = (target % gridSize) * cell;
    final dy = (target ~/ gridSize) * cell;
    return Stack(
      children: [
        Positioned(
          left: -dx,
          top: -dy,
          width: boardExtent,
          height: boardExtent,
          child: const CustomPaint(painter: ScenePainter()),
        ),
        Positioned(
          left: 6,
          top: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$value',
              style: TextStyle(
                color: Colors.white,
                fontSize: (extent * 0.16).clamp(10, 16).toDouble(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
