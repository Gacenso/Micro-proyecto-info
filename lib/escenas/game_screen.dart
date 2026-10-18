import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logica/game_session.dart';
import '../logica/puzzle_board.dart';
import '../models/app_settings.dart';
import '../models/difficulty.dart';
import '../models/high_score.dart';
import '../models/tile_style.dart';
import '../state/scores_scope.dart';
import '../state/settings_controller.dart';
import '../utils/formatters.dart';
import '../widgets/app_background.dart';
import '../widgets/game_over_panel.dart';
import '../widgets/puzzle_board_view.dart';
import '../widgets/stat_chip.dart';

/// Pantalla de juego.
///
/// Es un StatefulWidget porque todo lo que muestra cambia mientras se
/// juega: el tablero, los movimientos y el cronómetro. La lógica vive en
/// [GameSession] (sin UI); esta pantalla solo llama a sus métodos y usa
/// `setState` para redibujar después de cada cambio.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.difficulty});

  final Difficulty difficulty;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late GameSession _session;
  late AppSettings _settings;
  bool _initialized = false;

  /// Redibuja el cronómetro mientras se juega.
  Timer? _ticker;

  /// Récords batidos en la última victoria (si los hubo).
  RecordUpdate? _record;

  /// Si se muestra el panel de fin de partida (se oculta con "Ver tablero").
  bool _showResult = false;

  final FocusNode _focusNode = FocusNode(debugLabel: 'tablero');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settings = SettingsScope.of(context).settings;
    if (!_initialized) {
      _initialized = true;
      _session = GameSession(
        difficulty: widget.difficulty,
        timeLimitEnabled: _settings.timeLimitEnabled,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  /// Si la app pasa a segundo plano, la partida se pausa sola para que el
  /// cronómetro no siga corriendo.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed &&
        _session.status == GameStatus.playing) {
      _pause();
    }
  }

  // ---------------------------------------------------------------------
  // Acciones del juego
  // ---------------------------------------------------------------------

  void _onTileTap(int index) {
    _handleMove(() => _session.tapTile(index));
  }

  void _onSlide(SlideDirection direction) {
    _handleMove(() => _session.slide(direction));
  }

  void _handleMove(bool Function() move) {
    final wasReady = _session.status == GameStatus.ready;
    final moved = move();
    if (!moved) {
      if (_session.acceptsMoves && _settings.soundEnabled) {
        HapticFeedback.lightImpact();
      }
      return;
    }
    if (_settings.soundEnabled) {
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.selectionClick();
    }
    setState(() {});
    if (wasReady) _startTicker();
    if (_session.status == GameStatus.won) _onWin();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted) return;
      final timeUp = _session.checkTimeUp();
      setState(() {});
      if (timeUp) _onLose();
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  Future<void> _onWin() async {
    _stopTicker();
    final repository = ScoresScope.of(context);
    final update = await repository.registerWin(
      widget.difficulty,
      GameRecord(
        timeMs: _session.elapsed.inMilliseconds,
        moves: _session.moves,
        date: DateTime.now(),
      ),
    );
    if (_settings.soundEnabled) HapticFeedback.heavyImpact();
    // Se espera un momento para que se vea la última pieza deslizarse
    // (y, en Modo imagen, la imagen completa) antes del panel.
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() {
      _record = update;
      _showResult = true;
    });
  }

  void _onLose() {
    _stopTicker();
    if (_settings.soundEnabled) HapticFeedback.mediumImpact();
    setState(() {
      _record = null;
      _showResult = true;
    });
  }

  void _pause() {
    _session.pause();
    _stopTicker();
    setState(() {});
  }

  void _resume() {
    _session.resume();
    _startTicker();
    setState(() {});
    _focusNode.requestFocus();
  }

  void _restart() {
    _stopTicker();
    setState(() {
      _session = GameSession(
        difficulty: widget.difficulty,
        timeLimitEnabled: _settings.timeLimitEnabled,
      );
      _record = null;
      _showResult = false;
    });
    _focusNode.requestFocus();
  }

  Future<void> _confirmRestart() async {
    if (_session.moves == 0 || _session.isFinished) {
      _restart();
      return;
    }
    final wasPlaying = _session.status == GameStatus.playing;
    if (wasPlaying) _pause();
    final ok = await _confirm(
      title: '¿Reiniciar la partida?',
      message: 'Se mezclará un tablero nuevo y perderás el progreso actual.',
      confirmLabel: 'Reiniciar',
    );
    if (!mounted) return;
    if (ok) {
      _restart();
    } else if (wasPlaying) {
      _resume();
    }
  }

  Future<void> _confirmGiveUp() async {
    final wasPlaying = _session.status == GameStatus.playing;
    if (wasPlaying) _pause();
    final ok = await _confirm(
      title: '¿Rendirte?',
      message: 'La partida terminará y contará como perdida.',
      confirmLabel: 'Rendirme',
      destructive: true,
    );
    if (!mounted) return;
    if (ok) {
      _session.giveUp();
      _onLose();
    } else if (wasPlaying) {
      _resume();
    }
  }

  /// Hay progreso que se perdería al salir.
  bool get _hasProgress => !_session.isFinished && _session.moves > 0;

  Future<void> _confirmLeave() async {
    final wasPlaying = _session.status == GameStatus.playing;
    if (wasPlaying) _pause();
    final ok = await _confirm(
      title: '¿Salir al menú?',
      message: 'La partida en curso no se guardará.',
      confirmLabel: 'Salir',
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else if (wasPlaying) {
      _resume();
    }
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: destructive
                  ? FilledButton.styleFrom(
                      backgroundColor: scheme.error,
                      foregroundColor: scheme.onError,
                    )
                  : null,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  /// Flechas del teclado (y WASD) para jugar en computadora.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    SlideDirection? direction;
    if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.keyW) {
      direction = SlideDirection.up;
    } else if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.keyS) {
      direction = SlideDirection.down;
    } else if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.keyA) {
      direction = SlideDirection.left;
    } else if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.keyD) {
      direction = SlideDirection.right;
    } else if (key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.keyP) {
      if (_session.status == GameStatus.playing) {
        _pause();
        return KeyEventResult.handled;
      }
      if (_session.status == GameStatus.paused) {
        _resume();
        return KeyEventResult.handled;
      }
    }
    if (direction == null) return KeyEventResult.ignored;
    _onSlide(direction);
    return KeyEventResult.handled;
  }

  // ---------------------------------------------------------------------
  // Interfaz
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final status = _session.status;
    return PopScope(
      canPop: !_hasProgress,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmLeave();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text('${widget.difficulty.label} · ${widget.difficulty.gridLabel}'),
          actions: [
            if (status == GameStatus.playing)
              IconButton(
                tooltip: 'Pausar',
                onPressed: _pause,
                icon: const Icon(Icons.pause_rounded),
              )
            else if (status == GameStatus.paused)
              IconButton(
                tooltip: 'Reanudar',
                onPressed: _resume,
                icon: const Icon(Icons.play_arrow_rounded),
              ),
            IconButton(
              tooltip: 'Reiniciar',
              onPressed: _confirmRestart,
              icon: const Icon(Icons.refresh_rounded),
            ),
            if (!_session.isFinished && _session.moves > 0)
              IconButton(
                tooltip: 'Rendirse',
                onPressed: _confirmGiveUp,
                icon: const Icon(Icons.flag_outlined),
              ),
          ],
        ),
        body: AppBackground(
          child: SafeArea(
            child: Focus(
              focusNode: _focusNode,
              autofocus: true,
              onKeyEvent: _onKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > constraints.maxHeight &&
                      constraints.maxWidth >= 720;
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: wide ? _wideLayout() : _narrowLayout(),
                      ),
                      if (_showResult)
                        Positioned.fill(child: _resultOverlay()),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Teléfono o ventana vertical: indicadores arriba y tablero debajo.
  Widget _narrowLayout() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          _stats(Axis.horizontal),
          const SizedBox(height: 12),
          _hint(),
          const SizedBox(height: 12),
          Expanded(child: _boardArea()),
          if (_session.isFinished && !_showResult) ...[
            const SizedBox(height: 12),
            _finishedBar(),
          ],
        ],
      ),
    );
  }

  /// Tablet horizontal o escritorio: tablero a la izquierda y panel a la
  /// derecha.
  Widget _wideLayout() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Row(
        children: [
          Expanded(child: _boardArea()),
          const SizedBox(width: 28),
          SizedBox(
            width: 260,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _stats(Axis.vertical),
                    const SizedBox(height: 16),
                    _hint(),
                    if (_session.isFinished && !_showResult) ...[
                      const SizedBox(height: 16),
                      _finishedBar(),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      'Teclado: flechas o WASD para mover · Espacio para pausar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stats(Axis axis) {
    final remaining = _session.remaining;
    final lowTime = remaining != null && remaining.inSeconds < 20;
    final chips = [
      remaining != null
          ? StatChip(
              icon: Icons.hourglass_bottom_rounded,
              label: 'Restante',
              value: formatDuration(remaining),
              highlight: lowTime && !_session.isFinished,
            )
          : StatChip(
              icon: Icons.timer_rounded,
              label: 'Tiempo',
              value: formatDuration(_session.elapsed),
            ),
      StatChip(
        icon: Icons.swipe_rounded,
        label: 'Movimientos',
        value: '${_session.moves}',
      ),
      StatChip(
        icon: Icons.check_circle_outline_rounded,
        label: 'En su lugar',
        value: '${_session.board.correctTiles}/${widget.difficulty.pieceCount}',
      ),
    ];
    if (axis == Axis.vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final chip in chips)
            Padding(padding: const EdgeInsets.only(bottom: 10), child: chip),
        ],
      );
    }
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: chips,
    );
  }

  Widget _hint() {
    final scheme = Theme.of(context).colorScheme;
    final text = switch (_session.status) {
      GameStatus.ready => 'Toca una pieza junto al espacio vacío para empezar',
      GameStatus.playing => _session.timeLimit != null
          ? 'Ordena el tablero antes de que se acabe el tiempo'
          : 'Ordena las piezas del 1 al ${widget.difficulty.pieceCount}',
      GameStatus.paused => 'Partida en pausa',
      GameStatus.won => '¡Tablero resuelto!',
      GameStatus.lost => _session.lossReason == LossReason.timeUp
          ? 'Se acabó el tiempo'
          : 'Te rendiste',
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Text(
        text,
        key: ValueKey(text),
        textAlign: TextAlign.center,
        style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
      ),
    );
  }

  Widget _boardArea() {
    final paused = _session.status == GameStatus.paused;
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !_session.acceptsMoves,
            child: AnimatedOpacity(
              opacity: paused ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: PuzzleBoardView(
                board: _session.board,
                style: _settings.tileStyle,
                animate: _settings.animationsEnabled,
                showSolvedImage: _session.status == GameStatus.won &&
                    _settings.tileStyle == TileStyle.image,
                onTileTap: _onTileTap,
                onSwipe: _onSlide,
              ),
            ),
          ),
        ),
        if (paused) Positioned.fill(child: _pausedCard()),
      ],
    );
  }

  /// En pausa se oculta el tablero (para que no se pueda pensar con el
  /// cronómetro detenido) y se muestra este aviso.
  Widget _pausedCard() {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pause_circle_rounded, size: 64, color: scheme.primary),
              const SizedBox(height: 12),
              const Text(
                'Pausa',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'El cronómetro está detenido.',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _resume,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Reanudar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Barra que aparece al cerrar el panel de resultado con "Ver tablero".
  Widget _finishedBar() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 10,
      children: [
        OutlinedButton.icon(
          onPressed: () => setState(() => _showResult = true),
          icon: const Icon(Icons.leaderboard_rounded),
          label: const Text('Ver resultado'),
        ),
        FilledButton.icon(
          onPressed: _restart,
          icon: const Icon(Icons.replay_rounded),
          label: const Text('Jugar de nuevo'),
        ),
      ],
    );
  }

  Widget _resultOverlay() {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.45),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: GameOverPanel(
            won: _session.status == GameStatus.won,
            lossReason: _session.lossReason,
            difficulty: widget.difficulty,
            time: _session.elapsed,
            moves: _session.moves,
            record: _record,
            animate: _settings.animationsEnabled,
            onRestart: _restart,
            onViewBoard: () => setState(() => _showResult = false),
            onMenu: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}
