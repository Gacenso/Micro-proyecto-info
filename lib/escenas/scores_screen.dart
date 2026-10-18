import 'package:flutter/material.dart';

import '../models/difficulty.dart';
import '../models/high_score.dart';
import '../services/score_repository.dart';
import '../state/scores_scope.dart';
import '../utils/formatters.dart';
import '../widgets/app_background.dart';
import '../widgets/difficulty_selector.dart';

/// Tabla de marcadores por dificultad. Es un StatefulWidget porque la
/// lista cambia al borrar los marcadores (se recarga con `setState`).
class ScoresScreen extends StatefulWidget {
  const ScoresScreen({super.key});

  @override
  State<ScoresScreen> createState() => _ScoresScreenState();
}

class _ScoresScreenState extends State<ScoresScreen> {
  late ScoreRepository _repository;
  Map<Difficulty, DifficultyScores> _scores = const {};
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _repository = ScoresScope.of(context);
      _scores = _repository.loadAll();
      _loaded = true;
    }
  }

  bool get _isEmpty => _scores.values.every((s) => s.isEmpty);

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_forever_rounded),
        title: const Text('¿Borrar todos los marcadores?'),
        content: const Text(
          'Se eliminarán los récords de las tres dificultades. '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _repository.clearAll();
    if (!mounted) return;
    setState(() => _scores = _repository.loadAll());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Marcadores borrados')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Marcadores'),
        actions: [
          IconButton(
            tooltip: 'Borrar marcadores',
            onPressed: _isEmpty ? null : _confirmClear,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: _isEmpty ? const _EmptyState() : _buildList(),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isEmpty ? null : _confirmClear,
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Borrar todo'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Menú'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        for (final difficulty in Difficulty.values)
          _DifficultyCard(
            difficulty: difficulty,
            scores: _scores[difficulty] ?? const DifficultyScores(),
          ),
      ],
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  const _DifficultyCard({required this.difficulty, required this.scores});

  final Difficulty difficulty;
  final DifficultyScores scores;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final best = scores.bestTime;
    final fewest = scores.fewestMoves;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(DifficultySelector.iconOf(difficulty), color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${difficulty.label} · ${difficulty.gridLabel}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                if (scores.gamesWon > 0)
                  Text(
                    scores.gamesWon == 1
                        ? '1 victoria'
                        : '${scores.gamesWon} victorias',
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (scores.isEmpty)
              Text(
                'Aún no hay partidas ganadas en esta dificultad.',
                style: TextStyle(color: scheme.onSurfaceVariant),
              )
            else ...[
              if (best != null)
                _RecordRow(
                  icon: Icons.timer_rounded,
                  title: 'Mejor tiempo',
                  value: formatDurationPrecise(best.time),
                  detail: '${movesLabel(best.moves)} · ${formatDate(best.date)}',
                ),
              if (best != null && fewest != null) const Divider(height: 20),
              if (fewest != null)
                _RecordRow(
                  icon: Icons.swipe_rounded,
                  title: 'Menos movimientos',
                  value: '${fewest.moves}',
                  detail: '${formatDurationPrecise(fewest.time)} · '
                      '${formatDate(fewest.date)}',
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 22, color: scheme.secondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                detail,
                style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events_outlined, size: 84, color: scheme.primary),
            const SizedBox(height: 16),
            const Text(
              '¡Todavía no hay récords!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Gana tu primera partida y aquí aparecerán tu mejor tiempo '
              'y tu menor número de movimientos en cada dificultad.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
