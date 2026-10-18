import 'package:flutter/material.dart';

/// Dibuja un paisaje (atardecer, montañas, lago y árboles) del tamaño
/// del tablero. En "Modo imagen" cada pieza muestra solo su recorte, así
/// que al ordenar el tablero se forma la imagen completa.
///
/// Se dibuja con código para no depender de archivos de imagen y para
/// que funcione sin conexión.
class ScenePainter extends CustomPainter {
  const ScenePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    // Cielo.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2B2D6E), Color(0xFFE35D6A), Color(0xFFFFB86B)],
          stops: [0.0, 0.45, 0.62],
        ).createShader(rect),
    );

    // Sol.
    canvas.drawCircle(
      Offset(w * 0.68, h * 0.46),
      w * 0.13,
      Paint()..color = const Color(0xFFFFE29A),
    );

    // Montañas lejanas.
    final far = Path()
      ..moveTo(0, h * 0.58)
      ..lineTo(w * 0.18, h * 0.38)
      ..lineTo(w * 0.34, h * 0.52)
      ..lineTo(w * 0.52, h * 0.30)
      ..lineTo(w * 0.74, h * 0.54)
      ..lineTo(w * 0.88, h * 0.40)
      ..lineTo(w, h * 0.50)
      ..lineTo(w, h * 0.66)
      ..lineTo(0, h * 0.66)
      ..close();
    canvas.drawPath(far, Paint()..color = const Color(0xFF6B3F7A));

    // Montañas cercanas.
    final near = Path()
      ..moveTo(0, h * 0.66)
      ..lineTo(w * 0.22, h * 0.50)
      ..lineTo(w * 0.40, h * 0.64)
      ..lineTo(w * 0.62, h * 0.48)
      ..lineTo(w * 0.86, h * 0.66)
      ..lineTo(w, h * 0.60)
      ..lineTo(w, h * 0.70)
      ..lineTo(0, h * 0.70)
      ..close();
    canvas.drawPath(near, Paint()..color = const Color(0xFF3B2A5C));

    // Lago con reflejo.
    final lake = Rect.fromLTWH(0, h * 0.70, w, h * 0.30);
    canvas.drawRect(
      lake,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE88A7A), Color(0xFF2E4A7D)],
        ).createShader(lake),
    );
    final reflection = Paint()..color = const Color(0x66FFE29A);
    for (var i = 0; i < 5; i++) {
      final y = h * (0.74 + i * 0.04);
      final half = w * (0.10 - i * 0.015);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(w * 0.68, y),
            width: half * 2,
            height: h * 0.012,
          ),
          Radius.circular(h * 0.01),
        ),
        reflection,
      );
    }

    // Árboles (samanes) en la orilla.
    _drawTree(canvas, Offset(w * 0.12, h * 0.70), w * 0.10);
    _drawTree(canvas, Offset(w * 0.30, h * 0.72), w * 0.07);
  }

  void _drawTree(Canvas canvas, Offset base, double radius) {
    final trunk = Paint()..color = const Color(0xFF2A1A2E);
    canvas.drawRect(
      Rect.fromLTWH(base.dx - radius * 0.08, base.dy - radius * 0.9,
          radius * 0.16, radius * 0.9),
      trunk,
    );
    final crown = Paint()..color = const Color(0xFF243B2F);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(base.dx, base.dy - radius * 1.05),
        width: radius * 2.4,
        height: radius * 1.1,
      ),
      crown,
    );
  }

  @override
  bool shouldRepaint(covariant ScenePainter oldDelegate) => false;
}
