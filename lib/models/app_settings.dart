import 'package:flutter/material.dart';

import 'difficulty.dart';
import 'tile_style.dart';

/// Preferencias del usuario. Es inmutable: cada cambio crea una copia
/// con [copyWith], lo que facilita guardar y notificar los cambios.
@immutable
class AppSettings {
  const AppSettings({
    this.difficulty,
    this.themeMode = ThemeMode.system,
    this.tileStyle = TileStyle.classic,
    this.soundEnabled = true,
    this.animationsEnabled = true,
    this.timeLimitEnabled = false,
  });

  /// Dificultad por defecto. Es `null` mientras el usuario no haya
  /// elegido una; en ese caso se le pregunta al pulsar "Jugar".
  final Difficulty? difficulty;
  final ThemeMode themeMode;
  final TileStyle tileStyle;
  final bool soundEnabled;
  final bool animationsEnabled;

  /// Modo contrarreloj: si se acaba el tiempo, la partida se pierde.
  final bool timeLimitEnabled;

  AppSettings copyWith({
    Difficulty? difficulty,
    ThemeMode? themeMode,
    TileStyle? tileStyle,
    bool? soundEnabled,
    bool? animationsEnabled,
    bool? timeLimitEnabled,
  }) {
    return AppSettings(
      difficulty: difficulty ?? this.difficulty,
      themeMode: themeMode ?? this.themeMode,
      tileStyle: tileStyle ?? this.tileStyle,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      timeLimitEnabled: timeLimitEnabled ?? this.timeLimitEnabled,
    );
  }
}
