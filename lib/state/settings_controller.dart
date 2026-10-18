import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../models/difficulty.dart';
import '../models/tile_style.dart';
import '../services/settings_repository.dart';

/// Mantiene las preferencias en memoria, las guarda y avisa a la app
/// cuando cambian (por ejemplo, para cambiar el tema al instante).
class SettingsController extends ChangeNotifier {
  SettingsController(this._repository) : _settings = _repository.load();

  final SettingsRepository _repository;
  AppSettings _settings;

  AppSettings get settings => _settings;

  Future<void> _update(AppSettings next) async {
    _settings = next;
    notifyListeners();
    await _repository.save(next);
  }

  Future<void> setDifficulty(Difficulty value) =>
      _update(_settings.copyWith(difficulty: value));
  Future<void> setThemeMode(ThemeMode value) =>
      _update(_settings.copyWith(themeMode: value));
  Future<void> setTileStyle(TileStyle value) =>
      _update(_settings.copyWith(tileStyle: value));
  Future<void> setSoundEnabled(bool value) =>
      _update(_settings.copyWith(soundEnabled: value));
  Future<void> setAnimationsEnabled(bool value) =>
      _update(_settings.copyWith(animationsEnabled: value));
  Future<void> setTimeLimitEnabled(bool value) =>
      _update(_settings.copyWith(timeLimitEnabled: value));
}

/// Hace accesible el [SettingsController] a toda la app y reconstruye a
/// quienes lo leen con [SettingsScope.of] cuando cambia una preferencia.
class SettingsScope extends InheritedNotifier<SettingsController> {
  const SettingsScope({
    super.key,
    required SettingsController controller,
    required super.child,
  }) : super(notifier: controller);

  static SettingsController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SettingsScope>();
    assert(scope != null, 'No hay un SettingsScope en el árbol de widgets.');
    return scope!.notifier!;
  }
}
