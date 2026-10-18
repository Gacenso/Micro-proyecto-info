import 'package:flutter/material.dart';

import '../models/difficulty.dart';

/// Tarjetas para elegir la dificultad. Se usa en Configuración y en el
/// diálogo que aparece al pulsar "Jugar" por primera vez.
class DifficultySelector extends StatelessWidget {
  const DifficultySelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final Difficulty? selected;
  final ValueChanged<Difficulty> onSelected;

  static String descriptionOf(Difficulty difficulty) => switch (difficulty) {
        Difficulty.easy => 'Cuadrícula 3x3 · 8 piezas',
        Difficulty.medium => 'Cuadrícula 4x4 · 15 piezas (clásico)',
        Difficulty.hard => 'Cuadrícula 5x5 · 24 piezas',
      };

  static IconData iconOf(Difficulty difficulty) => switch (difficulty) {
        Difficulty.easy => Icons.sentiment_satisfied_alt_rounded,
        Difficulty.medium => Icons.extension_rounded,
        Difficulty.hard => Icons.local_fire_department_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final difficulty in Difficulty.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: difficulty == selected
                  ? scheme.primaryContainer
                  : scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onSelected(difficulty),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(
                        iconOf(difficulty),
                        color: difficulty == selected
                            ? scheme.onPrimaryContainer
                            : scheme.primary,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              difficulty.label,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              descriptionOf(difficulty),
                              style: TextStyle(
                                fontSize: 13,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (difficulty == selected)
                        Icon(Icons.check_circle_rounded, color: scheme.primary),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Diálogo para elegir dificultad antes de jugar. Devuelve la elegida, o
/// `null` si el usuario lo cierra.
Future<Difficulty?> showDifficultyDialog(
  BuildContext context, {
  Difficulty? current,
}) {
  return showDialog<Difficulty>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Elige la dificultad'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: DifficultySelector(
            selected: current,
            onSelected: (difficulty) => Navigator.of(context).pop(difficulty),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    ),
  );
}
