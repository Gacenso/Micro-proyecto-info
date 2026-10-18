import 'package:flutter/foundation.dart';

/// Resultado de una partida ganada.
@immutable
class GameRecord {
  const GameRecord({
    required this.timeMs,
    required this.moves,
    required this.date,
  });

  final int timeMs;
  final int moves;
  final DateTime date;

  Duration get time => Duration(milliseconds: timeMs);

  Map<String, dynamic> toJson() => {
        'timeMs': timeMs,
        'moves': moves,
        'date': date.toIso8601String(),
      };

  static GameRecord? fromJson(Object? json) {
    if (json is! Map) return null;
    final timeMs = json['timeMs'];
    final moves = json['moves'];
    final date = DateTime.tryParse('${json['date']}');
    if (timeMs is! int || moves is! int || date == null) return null;
    return GameRecord(timeMs: timeMs, moves: moves, date: date);
  }
}

/// Mejores marcas de una dificultad: el mejor tiempo y el menor número
/// de movimientos se guardan por separado, porque pueden venir de
/// partidas distintas.
@immutable
class DifficultyScores {
  const DifficultyScores({this.bestTime, this.fewestMoves, this.gamesWon = 0});

  final GameRecord? bestTime;
  final GameRecord? fewestMoves;
  final int gamesWon;

  bool get isEmpty => bestTime == null && fewestMoves == null;

  Map<String, dynamic> toJson() => {
        'bestTime': bestTime?.toJson(),
        'fewestMoves': fewestMoves?.toJson(),
        'gamesWon': gamesWon,
      };

  static DifficultyScores fromJson(Object? json) {
    if (json is! Map) return const DifficultyScores();
    final gamesWon = json['gamesWon'];
    return DifficultyScores(
      bestTime: GameRecord.fromJson(json['bestTime']),
      fewestMoves: GameRecord.fromJson(json['fewestMoves']),
      gamesWon: gamesWon is int ? gamesWon : 0,
    );
  }

  /// Incorpora una partida ganada y devuelve las marcas actualizadas
  /// junto con qué récords se batieron.
  RecordUpdate register(GameRecord game) {
    final isBestTime = bestTime == null || game.timeMs < bestTime!.timeMs;
    final isFewestMoves =
        fewestMoves == null || game.moves < fewestMoves!.moves;
    return RecordUpdate(
      scores: DifficultyScores(
        bestTime: isBestTime ? game : bestTime,
        fewestMoves: isFewestMoves ? game : fewestMoves,
        gamesWon: gamesWon + 1,
      ),
      isBestTime: isBestTime,
      isFewestMoves: isFewestMoves,
    );
  }
}

/// Resultado de registrar una partida en los marcadores.
@immutable
class RecordUpdate {
  const RecordUpdate({
    required this.scores,
    required this.isBestTime,
    required this.isFewestMoves,
  });

  final DifficultyScores scores;
  final bool isBestTime;
  final bool isFewestMoves;

  bool get isNewRecord => isBestTime || isFewestMoves;
}
