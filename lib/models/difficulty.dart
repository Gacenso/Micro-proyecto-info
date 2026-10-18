/// Niveles de dificultad del juego: cada uno define el tamaño de la
/// cuadrícula y el límite de tiempo del modo contrarreloj.
enum Difficulty {
  easy(size: 3, label: 'Fácil', timeLimit: Duration(minutes: 2)),
  medium(size: 4, label: 'Medio', timeLimit: Duration(minutes: 6)),
  hard(size: 5, label: 'Difícil', timeLimit: Duration(minutes: 15));

  const Difficulty({
    required this.size,
    required this.label,
    required this.timeLimit,
  });

  /// Número de filas y columnas del tablero.
  final int size;

  /// Nombre que se muestra al usuario.
  final String label;

  /// Tiempo máximo cuando el modo contrarreloj está activo.
  final Duration timeLimit;

  /// Cantidad de piezas numeradas (sin contar el espacio vacío).
  int get pieceCount => size * size - 1;

  /// Texto corto del tamaño, por ejemplo "4x4".
  String get gridLabel => '${size}x$size';

  /// Convierte el nombre guardado en persistencia a un valor del enum.
  static Difficulty? fromName(String? name) {
    for (final difficulty in Difficulty.values) {
      if (difficulty.name == name) return difficulty;
    }
    return null;
  }
}
