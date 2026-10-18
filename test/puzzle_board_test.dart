import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:microproyecto/logica/puzzle_board.dart';

void main() {
  group('Tablero resuelto', () {
    test('tiene las piezas en orden y el vacío al final', () {
      final board = PuzzleBoard.solved(4);
      expect(board.tiles, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0]);
      expect(board.isSolved, isTrue);
      expect(board.correctTiles, 15);
    });

    test('un tablero desordenado no está resuelto', () {
      final board = PuzzleBoard.fromTiles(3, [1, 2, 3, 4, 5, 6, 7, 0, 8]);
      expect(board.isSolved, isFalse);
    });
  });

  group('Paridad de inversiones', () {
    test('cuenta las inversiones ignorando el vacío', () {
      expect(PuzzleBoard.countInversions([1, 2, 3, 4, 5, 6, 7, 8, 0]), 0);
      expect(PuzzleBoard.countInversions([2, 1, 3, 4, 5, 6, 7, 8, 0]), 1);
      expect(PuzzleBoard.countInversions([0, 8, 7, 6, 5, 4, 3, 2, 1]), 28);
    });

    test('3x3: intercambiar dos piezas lo vuelve imposible', () {
      expect(PuzzleBoard.isSolvable([1, 2, 3, 4, 5, 6, 7, 8, 0], 3), isTrue);
      expect(PuzzleBoard.isSolvable([2, 1, 3, 4, 5, 6, 7, 8, 0], 3), isFalse);
    });

    test('4x4: el famoso 14-15 de Sam Loyd no tiene solución', () {
      final loyd = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 15, 14, 0];
      expect(PuzzleBoard.isSolvable(loyd, 4), isFalse);
      expect(PuzzleBoard.isSolvable(PuzzleBoard.solved(4).tiles, 4), isTrue);
    });

    test('4x4: mover el vacío una fila arriba sigue siendo resoluble', () {
      // Desde el tablero resuelto, subir el vacío una fila (un movimiento
      // válido) da un tablero con 3 inversiones y el vacío en la fila 2.
      final tiles = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 0, 13, 14, 15, 12];
      expect(PuzzleBoard.isSolvable(tiles, 4), isTrue);
    });

    for (final size in [3, 4, 5]) {
      test('${size}x$size: 500 mezclas al azar siempre tienen solución', () {
        final random = Random(42);
        for (var i = 0; i < 500; i++) {
          final board = PuzzleBoard.shuffled(size, random: random);
          expect(board.tiles.length, size * size);
          expect(board.tiles.toSet().length, size * size);
          expect(PuzzleBoard.isSolvable(board.tiles, size), isTrue);
          expect(board.isSolved, isFalse);
        }
      });
    }
  });

  group('Movimientos', () {
    // 1 2 3
    // 4 0 5
    // 7 8 6
    final board = PuzzleBoard.fromTiles(3, [1, 2, 3, 4, 0, 5, 7, 8, 6]);

    test('solo se mueven las piezas vecinas del vacío', () {
      expect(board.canMove(1), isTrue); // arriba
      expect(board.canMove(3), isTrue); // izquierda
      expect(board.canMove(5), isTrue); // derecha
      expect(board.canMove(7), isTrue); // abajo
      expect(board.canMove(0), isFalse); // diagonal
      expect(board.canMove(4), isFalse); // el propio vacío
      expect(board.canMove(9), isFalse); // fuera del tablero
    });

    test('no se "salta" de una fila a otra por los bordes', () {
      // 1 2 3
      // 0 4 5   -> el 3 (índice 2) es vecino en la lista pero no en el tablero
      // 7 8 6
      final edge = PuzzleBoard.fromTiles(3, [1, 2, 3, 0, 4, 5, 7, 8, 6]);
      expect(edge.canMove(2), isFalse);
    });

    test('mover intercambia la pieza con el vacío', () {
      final next = board.move(5)!;
      expect(next.tiles, [1, 2, 3, 4, 5, 0, 7, 8, 6]);
      expect(board.tiles, [1, 2, 3, 4, 0, 5, 7, 8, 6], reason: 'inmutable');
      expect(board.move(0), isNull);
    });

    test('deslizar en una dirección mueve la pieza correcta', () {
      expect(board.slide(SlideDirection.up)!.tiles[4], 8);
      expect(board.slide(SlideDirection.down)!.tiles[4], 2);
      expect(board.slide(SlideDirection.left)!.tiles[4], 5);
      expect(board.slide(SlideDirection.right)!.tiles[4], 4);
    });

    test('el último movimiento resuelve el tablero', () {
      final solved = board.move(5)!.move(8)!;
      expect(solved.isSolved, isTrue);
    });
  });
}
