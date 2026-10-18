import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../models/difficulty.dart';
import '../models/tile_style.dart';
import '../state/settings_controller.dart';
import '../utils/formatters.dart';
import '../widgets/app_background.dart';
import '../widgets/difficulty_selector.dart';
import '../widgets/puzzle_tile.dart';

/// Pantalla de ajustes. Es un StatefulWidget: guarda una copia local de
/// las preferencias y usa `setState` para que cada opción se vea marcada
/// al instante; a la vez, el [SettingsController] las guarda en
/// shared_preferences y actualiza el resto de la app (por ejemplo, el tema).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsController _controller;
  late AppSettings _settings;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = SettingsScope.of(context);
    _settings = _controller.settings;
  }

  void _change(AppSettings next, Future<void> Function() save) {
    setState(() => _settings = next);
    save();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Configuración')),
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  const _Header('Dificultad predeterminada'),
                  DifficultySelector(
                    selected: _settings.difficulty,
                    onSelected: (Difficulty value) => _change(
                      _settings.copyWith(difficulty: value),
                      () => _controller.setDifficulty(value),
                    ),
                  ),
                  const _Header('Tema'),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_rounded),
                        label: Text('Claro'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_rounded),
                        label: Text('Oscuro'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto_rounded),
                        label: Text('Automático'),
                      ),
                    ],
                    selected: {_settings.themeMode},
                    onSelectionChanged: (selection) {
                      final mode = selection.first;
                      _change(
                        _settings.copyWith(themeMode: mode),
                        () => _controller.setThemeMode(mode),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Text(
                      'Automático usa el tema claro u oscuro de tu dispositivo.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const _Header('Estilo de las piezas'),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final style in TileStyle.values)
                        _StyleOption(
                          style: style,
                          selected: style == _settings.tileStyle,
                          onTap: () => _change(
                            _settings.copyWith(tileStyle: style),
                            () => _controller.setTileStyle(style),
                          ),
                        ),
                    ],
                  ),
                  const _Header('Partida'),
                  Card(
                    child: Column(
                      children: [
                        SwitchListTile(
                          secondary: const Icon(Icons.hourglass_bottom_rounded),
                          title: const Text('Modo contrarreloj'),
                          subtitle: Text(
                            'Pierdes si se acaba el tiempo '
                            '(${Difficulty.values.map((d) => formatDuration(d.timeLimit)).join(' / ')})',
                          ),
                          value: _settings.timeLimitEnabled,
                          onChanged: (value) => _change(
                            _settings.copyWith(timeLimitEnabled: value),
                            () => _controller.setTimeLimitEnabled(value),
                          ),
                        ),
                        SwitchListTile(
                          secondary: const Icon(Icons.animation_rounded),
                          title: const Text('Animaciones'),
                          subtitle: const Text('Transiciones y piezas que se deslizan'),
                          value: _settings.animationsEnabled,
                          onChanged: (value) => _change(
                            _settings.copyWith(animationsEnabled: value),
                            () => _controller.setAnimationsEnabled(value),
                          ),
                        ),
                        SwitchListTile(
                          secondary: const Icon(Icons.volume_up_rounded),
                          title: const Text('Efectos de sonido'),
                          subtitle: const Text('Clic al mover y vibración en móviles'),
                          value: _settings.soundEnabled,
                          onChanged: (value) => _change(
                            _settings.copyWith(soundEnabled: value),
                            () => _controller.setSoundEnabled(value),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Los cambios se guardan automáticamente en este dispositivo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10, left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// Tarjeta con una pieza de muestra para cada estilo visual.
class _StyleOption extends StatelessWidget {
  const _StyleOption({
    required this.style,
    required this.selected,
    required this.onTap,
  });

  final TileStyle style;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      button: true,
      label: style.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 112,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? scheme.primaryContainer : scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? scheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: ExcludeSemantics(
                  child: PuzzleTile(
                    value: 5,
                    gridSize: 3,
                    extent: 56,
                    boardExtent: 168,
                    style: style,
                    inPlace: false,
                    onTap: onTap,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                style.label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
