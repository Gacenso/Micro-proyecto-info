import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../logica/game_session.dart';
import '../models/difficulty.dart';
import '../models/high_score.dart';
import '../utils/formatters.dart';

/// Panel de fin de partida: "¡Ganaste!" o "Perdiste", el resumen
/// (tiempo, movimientos y dificultad), los récords batidos y los botones
/// para reiniciar, volver a ver el tablero o salir al menú.
class GameOverPanel extends StatelessWidget {
  const GameOverPanel({
    super.key,
    required this.won,
    required this.lossReason,
    required this.difficulty,
    required this.time,
    required this.moves,
    required this.record,
    required this.animate,
    required this.onRestart,
    required this.onViewBoard,
    required this.onMenu,
  });

  final bool won;
  final LossReason? lossReason;
  final Difficulty difficulty;
  final Duration time;
  final int moves;
  final RecordUpdate? record;
  final bool animate;
  final VoidCallback onRestart;
  final VoidCallback onViewBoard;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = won ? scheme.primary : scheme.error;
    final isRecord = won && (record?.isNewRecord ?? false);

    final subtitle = won
        ? 'Ordenaste el tablero ${difficulty.gridLabel}.'
        : lossReason == LossReason.timeUp
            ? 'Se acabó el tiempo antes de ordenar el tablero.'
            : 'Te rendiste. ¡La próxima sale!';

    final card = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Card(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  won ? Icons.emoji_events_rounded : Icons.timer_off_rounded,
                  size: 56,
                  color: accent,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                won ? '¡Ganaste!' : 'Perdiste',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              if (isRecord) ...[
                const SizedBox(height: 14),
                _RecordBadge(record: record!, animate: animate),
              ],
              const SizedBox(height: 18),
              _SummaryRow(
                icon: Icons.timer_rounded,
                label: 'Tiempo total',
                value: formatDurationPrecise(time),
                highlight: record?.isBestTime ?? false,
              ),
              _SummaryRow(
                icon: Icons.swipe_rounded,
                label: 'Movimientos',
                value: '$moves',
                highlight: record?.isFewestMoves ?? false,
              ),
              _SummaryRow(
                icon: Icons.grid_view_rounded,
                label: 'Dificultad',
                value: '${difficulty.label} (${difficulty.gridLabel})',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onRestart,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Reiniciar'),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onViewBoard,
                      icon: const Icon(Icons.grid_on_rounded),
                      label: const Text('Ver tablero'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onMenu,
                      icon: const Icon(Icons.home_rounded),
                      label: const Text('Menú'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (!animate) return card;
    return ZoomIn(duration: const Duration(milliseconds: 350), child: card);
  }
}

class _RecordBadge extends StatelessWidget {
  const _RecordBadge({required this.record, required this.animate});

  final RecordUpdate record;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final detail = record.isBestTime && record.isFewestMoves
        ? 'Mejor tiempo y menos movimientos'
        : record.isBestTime
            ? 'Mejor tiempo'
            : 'Menos movimientos';
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '¡Nuevo récord!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: scheme.onSecondaryContainer,
            ),
          ),
          Text(
            detail,
            style: TextStyle(fontSize: 13, color: scheme.onSecondaryContainer),
          ),
        ],
      ),
    );
    if (!animate) return badge;
    return Pulse(
      delay: const Duration(milliseconds: 400),
      child: badge,
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: scheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          if (highlight)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(Icons.star_rounded, size: 18, color: scheme.secondary),
            ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
