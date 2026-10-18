import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../models/difficulty.dart';
import '../state/settings_controller.dart';
import '../utils/app_route.dart';
import '../widgets/app_background.dart';
import '../widgets/difficulty_selector.dart';
import '../widgets/game_logo.dart';
import '../widgets/pressable_button.dart';
import 'game_screen.dart';
import 'instructions_screen.dart';
import 'scores_screen.dart';
import 'settings_screen.dart';

/// Menú principal. No guarda estado propio: lee las preferencias del
/// [SettingsScope], así que se actualiza solo al volver de Configuración.
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  Future<void> _play(BuildContext context) async {
    final controller = SettingsScope.of(context);
    var difficulty = controller.settings.difficulty;
    // Primera vez: se pide la dificultad y se guarda como predeterminada.
    if (difficulty == null) {
      difficulty = await showDifficultyDialog(context);
      if (difficulty == null) return;
      await controller.setDifficulty(difficulty);
    }
    if (!context.mounted) return;
    _open(context, GameScreen(difficulty: difficulty));
  }

  void _open(BuildContext context, Widget page) {
    final animate = SettingsScope.of(context).settings.animationsEnabled;
    Navigator.of(context).push(appRoute<void>(page, animate: animate));
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context).settings;
    final animate = settings.animationsEnabled;
    final Difficulty? difficulty = settings.difficulty;

    final buttons = <Widget>[
      PressableButton(
        primary: true,
        icon: Icons.play_arrow_rounded,
        label: 'Jugar',
        subtitle: difficulty == null
            ? 'Elige tu dificultad'
            : '${difficulty.label} · ${difficulty.gridLabel}',
        onPressed: () => _play(context),
      ),
      PressableButton(
        icon: Icons.emoji_events_rounded,
        label: 'Marcadores',
        subtitle: 'Tus mejores tiempos y movimientos',
        onPressed: () => _open(context, const ScoresScreen()),
      ),
      PressableButton(
        icon: Icons.tune_rounded,
        label: 'Configuración',
        subtitle: 'Dificultad, tema y estilo',
        onPressed: () => _open(context, const SettingsScreen()),
      ),
      PressableButton(
        icon: Icons.help_outline_rounded,
        label: 'Cómo jugar',
        subtitle: 'Reglas e instrucciones',
        onPressed: () => _open(context, const InstructionsScreen()),
      ),
    ];

    Widget animated(Widget child, int order) {
      if (!animate) return child;
      return FadeInUp(
        duration: const Duration(milliseconds: 500),
        delay: Duration(milliseconds: 120 * order),
        child: child,
      );
    }

    final logo = animate
        ? ZoomIn(
            duration: const Duration(milliseconds: 600),
            child: const GameLogo(size: 110),
          )
        : const GameLogo(size: 110);

    final buttonColumn = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < buttons.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: animated(buttons[i], i + 1),
          ),
      ],
    );

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 840;
              final content = wide
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: Center(child: logo)),
                        const SizedBox(width: 32),
                        SizedBox(width: 420, child: buttonColumn),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        logo,
                        const SizedBox(height: 36),
                        buttonColumn,
                      ],
                    );
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: wide ? 1000 : 460),
                    child: content,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
