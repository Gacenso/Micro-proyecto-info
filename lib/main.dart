import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'services/score_repository.dart';
import 'services/settings_repository.dart';
import 'state/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Se cargan las preferencias antes de dibujar la app para que el tema
  // guardado se aplique desde el primer cuadro (sin parpadeos).
  final prefs = await SharedPreferences.getInstance();
  final settings = SettingsController(SettingsRepository(prefs));
  final scores = ScoreRepository(prefs);
  runApp(PuzzleApp(settings: settings, scores: scores));
}
