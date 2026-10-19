import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:microproyecto/app.dart';
import 'package:microproyecto/services/score_repository.dart';
import 'package:microproyecto/services/settings_repository.dart';
import 'package:microproyecto/state/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Prueba de humo del flujo principal: Splash → Menú → Juego.
/// Se desactivan las animaciones para que la prueba sea determinista.
Future<void> _pumpApp(WidgetTester tester, Map<String, Object> prefs) async {
  SharedPreferences.setMockInitialValues(prefs);
  final instance = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    PuzzleApp(
      settings: SettingsController(SettingsRepository(instance)),
      scores: ScoreRepository(instance),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _skipSplash(WidgetTester tester) async {
  await tester.tap(find.text('Saltar'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  testWidgets('El splash lleva al menú principal', (tester) async {
    await _pumpApp(tester, {'settings.animations': false});
    expect(find.text('15-Puzzle'), findsOneWidget);
    await _skipSplash(tester);
    expect(find.text('Jugar'), findsOneWidget);
    expect(find.text('Marcadores'), findsOneWidget);
    expect(find.text('Configuración'), findsOneWidget);
    expect(find.text('Cómo jugar'), findsOneWidget);
  });

  testWidgets('Jugar abre el tablero con la dificultad guardada', (tester) async {
    await _pumpApp(tester, {
      'settings.animations': false,
      'settings.difficulty': 'easy',
    });
    await _skipSplash(tester);
    await tester.tap(find.text('Jugar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Fácil · 3x3'), findsOneWidget);
    expect(find.text('Movimientos'), findsOneWidget);
  });

  testWidgets('Sin dificultad guardada, Jugar pide elegirla', (tester) async {
    await _pumpApp(tester, {'settings.animations': false});
    await _skipSplash(tester);
    await tester.tap(find.text('Jugar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Elige la dificultad'), findsOneWidget);
    await tester.tap(find.text('Medio'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Medio · 4x4'), findsOneWidget);
    expect(find.byType(Scaffold), findsWidgets);
  });
}
