import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/difficulty.dart';
import '../models/high_score.dart';

/// Guarda los High Scores por dificultad con shared_preferences.
/// Cada dificultad se guarda como un JSON en su propia clave.
class ScoreRepository {
  ScoreRepository(this._prefs);

  final SharedPreferences _prefs;

  static String _key(Difficulty difficulty) => 'scores.${difficulty.name}';

  DifficultyScores load(Difficulty difficulty) {
    final raw = _prefs.getString(_key(difficulty));
    if (raw == null) return const DifficultyScores();
    try {
      return DifficultyScores.fromJson(jsonDecode(raw));
    } on FormatException {
      // Datos dañados: se ignoran en lugar de cerrar la app.
      return const DifficultyScores();
    }
  }

  Map<Difficulty, DifficultyScores> loadAll() => {
        for (final difficulty in Difficulty.values)
          difficulty: load(difficulty),
      };

  /// Registra una partida ganada y dice si batió algún récord.
  Future<RecordUpdate> registerWin(Difficulty difficulty, GameRecord game) async {
    final update = load(difficulty).register(game);
    await _prefs.setString(
      _key(difficulty),
      jsonEncode(update.scores.toJson()),
    );
    return update;
  }

  Future<void> clearAll() async {
    for (final difficulty in Difficulty.values) {
      await _prefs.remove(_key(difficulty));
    }
  }
}
