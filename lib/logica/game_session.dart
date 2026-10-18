import 'dart:math';

import '../models/difficulty.dart';
import 'puzzle_board.dart';

/// Estados posibles de una partida.
enum GameStatus {
  /// Tablero mezclado; el cronómetro arranca con el primer movimiento.
  ready,
  playing,
  paused,
  won,
  lost,
}

/// Motivo por el que se perdió una partida.
enum LossReason { timeUp, gaveUp }

/// Una partida en curso: tablero, movimientos, cronómetro y estado.
///
/// Es lógica pura: la pantalla de juego guarda una instancia y llama a
/// `setState` cada vez que esta cambia.
class GameSession {
  GameSession({
    required this.difficulty,
    this.timeLimitEnabled = false,
    Random? random,
    PuzzleBoard? initialBoard,
  })  : _random = random,
        board = initialBoard ?? PuzzleBoard.shuffled(difficulty.size, random: random);

  final Difficulty difficulty;
  final bool timeLimitEnabled;
  final Random? _random;

  PuzzleBoard board;
  int moves = 0;
  GameStatus status = GameStatus.ready;
  LossReason? lossReason;

  final Stopwatch _stopwatch = Stopwatch();

  /// Tiempo jugado (no cuenta las pausas).
  Duration get elapsed => _stopwatch.elapsed;

  /// Límite de tiempo, o `null` si el modo contrarreloj está apagado.
  Duration? get timeLimit => timeLimitEnabled ? difficulty.timeLimit : null;

  /// Tiempo restante en modo contrarreloj (nunca negativo).
  Duration? get remaining {
    final limit = timeLimit;
    if (limit == null) return null;
    final left = limit - elapsed;
    return left.isNegative ? Duration.zero : left;
  }

  bool get isFinished => status == GameStatus.won || status == GameStatus.lost;
  bool get acceptsMoves =>
      status == GameStatus.ready || status == GameStatus.playing;

  /// Intenta mover la pieza en [index]. Devuelve `true` si se movió.
  bool tapTile(int index) => _apply(board.move(index));

  /// Intenta deslizar una pieza en [direction]. Devuelve `true` si se movió.
  bool slide(SlideDirection direction) => _apply(board.slide(direction));

  bool _apply(PuzzleBoard? next) {
    if (!acceptsMoves || next == null) return false;
    if (status == GameStatus.ready) {
      status = GameStatus.playing;
      _stopwatch.start();
    }
    board = next;
    moves++;
    if (board.isSolved) {
      _stopwatch.stop();
      status = GameStatus.won;
    }
    return true;
  }

  /// Revisa si se acabó el tiempo. Devuelve `true` si la partida se
  /// acaba de perder por tiempo.
  bool checkTimeUp() {
    final limit = timeLimit;
    if (limit == null || status != GameStatus.playing) return false;
    if (elapsed >= limit) {
      _lose(LossReason.timeUp);
      return true;
    }
    return false;
  }

  void pause() {
    if (status != GameStatus.playing) return;
    _stopwatch.stop();
    status = GameStatus.paused;
  }

  void resume() {
    if (status != GameStatus.paused) return;
    _stopwatch.start();
    status = GameStatus.playing;
  }

  void giveUp() {
    if (isFinished) return;
    _lose(LossReason.gaveUp);
  }

  void _lose(LossReason reason) {
    _stopwatch.stop();
    status = GameStatus.lost;
    lossReason = reason;
  }

  /// Nueva partida con la misma dificultad.
  GameSession restart() => GameSession(
        difficulty: difficulty,
        timeLimitEnabled: timeLimitEnabled,
        random: _random,
      );
}
