import 'package:flutter/material.dart';

import 'escenas/splash_screen.dart';
import 'services/score_repository.dart';
import 'state/scores_scope.dart';
import 'state/settings_controller.dart';
import 'theme/app_theme.dart';

/// Raíz de la aplicación. Escucha al [SettingsController] para que los
/// cambios de tema se vean al instante en todas las pantallas.
class PuzzleApp extends StatelessWidget {
  const PuzzleApp({super.key, required this.settings, required this.scores});

  final SettingsController settings;
  final ScoreRepository scores;

  @override
  Widget build(BuildContext context) {
    return SettingsScope(
      controller: settings,
      child: ScoresScope(
        repository: scores,
        child: ListenableBuilder(
          listenable: settings,
          builder: (context, _) => MaterialApp(
            title: '15-Puzzle Flutter',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.settings.themeMode,
            home: const SplashScreen(),
          ),
        ),
      ),
    );
  }
}
