import 'package:flutter/widgets.dart';

import '../services/score_repository.dart';

/// Da acceso al [ScoreRepository] desde cualquier pantalla.
class ScoresScope extends InheritedWidget {
  const ScoresScope({
    super.key,
    required this.repository,
    required super.child,
  });

  final ScoreRepository repository;

  static ScoreRepository of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<ScoresScope>();
    assert(scope != null, 'No hay un ScoresScope en el árbol de widgets.');
    return scope!.repository;
  }

  @override
  bool updateShouldNotify(ScoresScope oldWidget) =>
      repository != oldWidget.repository;
}
