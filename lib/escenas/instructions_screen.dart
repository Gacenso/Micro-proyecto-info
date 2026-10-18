import 'package:flutter/material.dart';

import '../models/difficulty.dart';
import '../utils/formatters.dart';
import '../widgets/app_background.dart';

/// Reglas del juego. Es un StatelessWidget porque su contenido es fijo.
class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Cómo jugar')),
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  const _Section(
                    icon: Icons.flag_rounded,
                    title: 'Objetivo',
                    body:
                        'Ordena las piezas en orden numérico (o forma la imagen '
                        'correcta) utilizando el espacio vacío para deslizar las '
                        'piezas adyacentes.',
                  ),
                  const _GoalPreview(),
                  const _Section(
                    icon: Icons.touch_app_rounded,
                    title: 'Cómo mover',
                    body:
                        'Toca una pieza que esté al lado del espacio vacío (arriba, '
                        'abajo, izquierda o derecha) y se deslizará hacia él. '
                        'También puedes deslizar el dedo sobre el tablero o usar '
                        'las flechas del teclado.',
                  ),
                  const _Section(
                    icon: Icons.emoji_events_rounded,
                    title: 'Cómo se gana',
                    body:
                        'Ganas cuando todas las piezas quedan ordenadas de izquierda '
                        'a derecha y de arriba hacia abajo (1, 2, 3...) con el '
                        'espacio vacío al final, en la esquina inferior derecha.',
                  ),
                  const _Section(
                    icon: Icons.timer_rounded,
                    title: 'Tiempo y movimientos',
                    body:
                        'El cronómetro empieza con tu primer movimiento y se detiene '
                        'si pausas la partida. Cada pieza que mueves suma un '
                        'movimiento. Tus mejores marcas se guardan en Marcadores.',
                  ),
                  _Section(
                    icon: Icons.hourglass_bottom_rounded,
                    title: '¿Se puede perder?',
                    body:
                        'Solo si activas el modo contrarreloj en Configuración: si '
                        'se acaba el tiempo antes de ordenar el tablero, pierdes '
                        '(${_limits()}). También pierdes si te rindes durante la '
                        'partida. Sin contrarreloj, puedes jugar sin límite.',
                  ),
                  const _Section(
                    icon: Icons.lightbulb_rounded,
                    title: 'Consejos',
                    body:
                        'Resuelve primero la fila de arriba y luego la columna de la '
                        'izquierda; así el tablero se va reduciendo. Las piezas que '
                        'ya están en su lugar se resaltan. Todos los tableros '
                        'generados tienen solución.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _limits() => Difficulty.values
      .map((d) => '${d.label}: ${formatDuration(d.timeLimit)}')
      .join(', ');
}

class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: scheme.onPrimaryContainer),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.5,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pequeño tablero 3x3 resuelto, para mostrar cómo se ve la meta.
class _GoalPreview extends StatelessWidget {
  const _GoalPreview();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (var i = 1; i <= 9; i++)
                    Container(
                      decoration: BoxDecoration(
                        color: i == 9 ? Colors.transparent : scheme.primary,
                        borderRadius: BorderRadius.circular(10),
                        border: i == 9
                            ? Border.all(color: scheme.outline, width: 1.5)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: i == 9
                          ? null
                          : Text(
                              '$i',
                              style: TextStyle(
                                color: scheme.onPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Así se ve un tablero 3x3 resuelto',
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
