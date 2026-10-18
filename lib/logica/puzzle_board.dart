import 'dart:math';

/// Dirección en la que se desliza una pieza hacia el espacio vacío.
enum SlideDirection { up, down, left, right }

/// Lógica pura del rompecabezas deslizante (sin nada de UI).
///
/// El tablero es una lista de `size * size` enteros leída de izquierda a
/// derecha y de arriba hacia abajo. El valor `0` es el espacio vacío y las
/// piezas van de `1` a `size * size - 1`.
class PuzzleBoard {
  PuzzleBoard._(this.size, List<int> tiles)
      : tiles = List.unmodifiable(tiles);

  /// Tablero resuelto: 1, 2, 3, ..., n y el espacio vacío al final.
  factory PuzzleBoard.solved(int size) {
    _checkSize(size);
    final total = size * size;
    return PuzzleBoard._(size, [for (var i = 1; i < total; i++) i, 0]);
  }

  /// Crea un tablero a partir de una lista existente (útil en pruebas).
  factory PuzzleBoard.fromTiles(int size, List<int> tiles) {
    _checkSize(size);
    final total = size * size;
    final sorted = [...tiles]..sort();
    if (tiles.length != total ||
        !List.generate(total, (i) => i).every((i) => sorted[i] == i)) {
      throw ArgumentError('Las piezas deben ser 0..${total - 1} sin repetir.');
    }
    return PuzzleBoard._(size, tiles);
  }

  /// Tablero desordenado al azar que SIEMPRE tiene solución.
  ///
  /// Se mezcla con Fisher-Yates (a través de [List.shuffle]). La mitad de
  /// las permutaciones no se pueden resolver; si sale una de esas, se
  /// intercambian dos piezas numeradas, lo que cambia la paridad de las
  /// inversiones y la vuelve resoluble. También se descarta el caso de que
  /// la mezcla deje el tablero ya ordenado.
  factory PuzzleBoard.shuffled(int size, {Random? random}) {
    _checkSize(size);
    final rng = random ?? Random();
    final total = size * size;
    while (true) {
      final tiles = List<int>.generate(total, (i) => i)..shuffle(rng);
      if (!isSolvable(tiles, size)) {
        final numbered = <int>[
          for (var i = 0; i < total; i++)
            if (tiles[i] != 0) i,
        ];
        final a = numbered[0];
        final b = numbered[1];
        final temp = tiles[a];
        tiles[a] = tiles[b];
        tiles[b] = temp;
      }
      final board = PuzzleBoard._(size, tiles);
      if (!board.isSolved) return board;
    }
  }

  final int size;
  final List<int> tiles;

  static void _checkSize(int size) {
    if (size < 2) throw ArgumentError('El tablero debe ser de 2x2 o más.');
  }

  /// Posición (índice) del espacio vacío.
  int get emptyIndex => tiles.indexOf(0);

  /// Cuenta las inversiones: pares de piezas numeradas (sin el vacío) que
  /// están en orden contrario al final.
  static int countInversions(List<int> tiles) {
    final numbers = tiles.where((t) => t != 0).toList();
    var inversions = 0;
    for (var i = 0; i < numbers.length; i++) {
      for (var j = i + 1; j < numbers.length; j++) {
        if (numbers[i] > numbers[j]) inversions++;
      }
    }
    return inversions;
  }

  /// Regla de paridad de inversiones:
  /// * Ancho impar (3x3, 5x5): tiene solución si las inversiones son pares.
  /// * Ancho par (4x4): contando la fila del vacío desde abajo (1 = última),
  ///   tiene solución si esa fila es impar y las inversiones son pares, o si
  ///   la fila es par y las inversiones son impares.
  static bool isSolvable(List<int> tiles, int size) {
    final inversions = countInversions(tiles);
    if (size.isOdd) return inversions.isEven;
    final emptyRowFromBottom = size - tiles.indexOf(0) ~/ size;
    return emptyRowFromBottom.isOdd ? inversions.isEven : inversions.isOdd;
  }

  /// Verdadero cuando todas las piezas están en orden y el vacío al final.
  bool get isSolved {
    final last = tiles.length - 1;
    for (var i = 0; i < last; i++) {
      if (tiles[i] != i + 1) return false;
    }
    return tiles[last] == 0;
  }

  /// Cantidad de piezas que ya están en su lugar correcto.
  int get correctTiles {
    var count = 0;
    for (var i = 0; i < tiles.length; i++) {
      if (tiles[i] != 0 && tiles[i] == i + 1) count++;
    }
    return count;
  }

  int rowOf(int index) => index ~/ size;
  int columnOf(int index) => index % size;

  /// Índice actual de una pieza a partir de su número.
  int indexOfTile(int value) => tiles.indexOf(value);

  /// Una pieza se puede mover si está al lado (no en diagonal) del vacío.
  bool canMove(int index) {
    if (index < 0 || index >= tiles.length || tiles[index] == 0) return false;
    final empty = emptyIndex;
    final sameRow = rowOf(index) == rowOf(empty);
    final sameColumn = columnOf(index) == columnOf(empty);
    final distance = (index - empty).abs();
    return (sameRow && distance == 1) || (sameColumn && distance == size);
  }

  /// Devuelve un tablero nuevo con la pieza movida al espacio vacío, o
  /// `null` si el movimiento no es válido.
  PuzzleBoard? move(int index) {
    if (!canMove(index)) return null;
    final updated = [...tiles];
    final empty = emptyIndex;
    updated[empty] = updated[index];
    updated[index] = 0;
    return PuzzleBoard._(size, updated);
  }

  /// Desliza en una dirección (teclado o deslizamiento del dedo): por
  /// ejemplo, [SlideDirection.up] sube la pieza que está debajo del vacío.
  PuzzleBoard? slide(SlideDirection direction) {
    final empty = emptyIndex;
    final row = rowOf(empty);
    final column = columnOf(empty);
    int? source;
    switch (direction) {
      case SlideDirection.up:
        if (row < size - 1) source = empty + size;
      case SlideDirection.down:
        if (row > 0) source = empty - size;
      case SlideDirection.left:
        if (column < size - 1) source = empty + 1;
      case SlideDirection.right:
        if (column > 0) source = empty - 1;
    }
    return source == null ? null : move(source);
  }
}
