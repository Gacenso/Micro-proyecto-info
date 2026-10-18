import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/difficulty.dart';
import '../models/tile_style.dart';

/// Guarda y lee las preferencias con shared_preferences.
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _kDifficulty = 'settings.difficulty';
  static const _kThemeMode = 'settings.themeMode';
  static const _kTileStyle = 'settings.tileStyle';
  static const _kSound = 'settings.sound';
  static const _kAnimations = 'settings.animations';
  static const _kTimeLimit = 'settings.timeLimit';

  AppSettings load() {
    return AppSettings(
      difficulty: Difficulty.fromName(_prefs.getString(_kDifficulty)),
      themeMode: _themeModeFromName(_prefs.getString(_kThemeMode)),
      tileStyle: TileStyle.fromName(_prefs.getString(_kTileStyle)),
      soundEnabled: _prefs.getBool(_kSound) ?? true,
      animationsEnabled: _prefs.getBool(_kAnimations) ?? true,
      timeLimitEnabled: _prefs.getBool(_kTimeLimit) ?? false,
    );
  }

  Future<void> save(AppSettings settings) async {
    final difficulty = settings.difficulty;
    if (difficulty == null) {
      await _prefs.remove(_kDifficulty);
    } else {
      await _prefs.setString(_kDifficulty, difficulty.name);
    }
    await _prefs.setString(_kThemeMode, settings.themeMode.name);
    await _prefs.setString(_kTileStyle, settings.tileStyle.name);
    await _prefs.setBool(_kSound, settings.soundEnabled);
    await _prefs.setBool(_kAnimations, settings.animationsEnabled);
    await _prefs.setBool(_kTimeLimit, settings.timeLimitEnabled);
  }

  static ThemeMode _themeModeFromName(String? name) {
    for (final mode in ThemeMode.values) {
      if (mode.name == name) return mode;
    }
    return ThemeMode.system;
  }
}
