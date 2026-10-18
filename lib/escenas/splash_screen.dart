import 'dart:async';

import 'package:flutter/material.dart';

import '../state/settings_controller.dart';
import '../utils/app_route.dart';
import '../widgets/app_background.dart';
import '../widgets/game_logo.dart';
import 'menu_screen.dart';

/// Pantalla de carga: muestra el logo con una animación de entrada
/// (desvanecido + escalado) y pasa al menú tras unos segundos o al
/// pulsar "Saltar".
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _displayTime = Duration(milliseconds: 2600);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  late final Animation<double> _fade =
      CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  late final Animation<double> _scale = Tween<double>(begin: 0.6, end: 1)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

  Timer? _timer;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _timer = Timer(_displayTime, _goToMenu);
  }

  void _goToMenu() {
    if (_leaving || !mounted) return;
    _leaving = true;
    _timer?.cancel();
    final animate = SettingsScope.of(context).settings.animationsEnabled;
    Navigator.of(context).pushReplacement(
      appRoute<void>(const MenuScreen(), animate: animate),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: const GameLogo(size: 140),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 48,
                child: FadeTransition(
                  opacity: _fade,
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: TextButton.icon(
                  onPressed: _goToMenu,
                  icon: const Icon(Icons.skip_next_rounded),
                  label: const Text('Saltar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
