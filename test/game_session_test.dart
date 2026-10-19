import 'package:flutter_test/flutter_test.dart';
import 'package:microproyecto/logica/game_session.dart';
import 'package:microproyecto/logica/puzzle_board.dart';
import 'package:microproyecto/models/difficulty.dart';
import 'package:microproyecto/models/high_score.dart';

void main() {
  GameSession almostSolved() => GameSession(
        difficulty: Difficulty.easy,
        initialBoard: PuzzleBoard.fromTiles(3, [1, 2, 3, 4, 5, 6, 7, 0, 8]),
      );

  test('la partida empieza lista y arranca con el primer movimiento', () {
    final session = almostSolved();
    expect(session.status, GameStatus.ready);
    expect(session.moves, 0);
    expect(session.tapTile(0), isFalse, reason: 'pieza no adyacente');
    expect(session.status, GameStatus.ready);
  });

  test('ganar detiene la partida y cuenta los movimientos', () {
    final session = almostSolved();
    expect(session.tapTile(8), isTrue);
    expect(session.status, GameStatus.won);
    expect(session.moves, 1);
    expect(session.tapTile(7), isFalse, reason: 'no se mueve tras ganar');
  });

  test('pausar impide mover y reanudar lo permite', () {
    final session = GameSession(
      difficulty: Difficulty.easy,
      initialBoard: PuzzleBoard.fromTiles(3, [1, 2, 3, 4, 0, 5, 7, 8, 6]),
    );
    session.tapTile(5);
    session.pause();
    expect(session.status, GameStatus.paused);
    expect(session.tapTile(4), isFalse);
    session.resume();
    expect(session.status, GameStatus.playing);
  });

  test('rendirse pierde la partida', () {
    final session = almostSolved();
    session.giveUp();
    expect(session.status, GameStatus.lost);
    expect(session.lossReason, LossReason.gaveUp);
  });

  test('sin contrarreloj no hay tiempo restante', () {
    expect(almostSolved().remaining, isNull);
    final timed = GameSession(difficulty: Difficulty.hard, timeLimitEnabled: true);
    expect(timed.remaining, Difficulty.hard.timeLimit);
  });

  group('Marcadores', () {
    final date = DateTime(2026, 10, 16);

    test('la primera victoria es récord en tiempo y movimientos', () {
      final update = const DifficultyScores()
          .register(GameRecord(timeMs: 60000, moves: 80, date: date));
      expect(update.isBestTime, isTrue);
      expect(update.isFewestMoves, isTrue);
      expect(update.scores.gamesWon, 1);
    });

    test('cada récord se guarda por separado', () {
      final first = const DifficultyScores()
          .register(GameRecord(timeMs: 60000, moves: 80, date: date))
          .scores;
      final faster = first.register(GameRecord(timeMs: 50000, moves: 90, date: date));
      expect(faster.isBestTime, isTrue);
      expect(faster.isFewestMoves, isFalse);
      expect(faster.scores.bestTime!.timeMs, 50000);
      expect(faster.scores.fewestMoves!.moves, 80);
    });

    test('se puede guardar y leer como JSON', () {
      final scores = const DifficultyScores()
          .register(GameRecord(timeMs: 1234, moves: 12, date: date))
          .scores;
      final copy = DifficultyScores.fromJson(scores.toJson());
      expect(copy.bestTime!.timeMs, 1234);
      expect(copy.fewestMoves!.moves, 12);
      expect(copy.gamesWon, 1);
      expect(DifficultyScores.fromJson('basura').isEmpty, isTrue);
    });
  });
}
