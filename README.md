# 15-Puzzle Flutter

Micro proyecto de Sistemas de Informacion de la UNIMET

Hecho por:
Giancarlo Paolino CI: 31.464.995
Gabriel Cedeño CI: 29.724.329

## Funciones

| Pantalla | Qué hace |
| --- | --- |
| Splash | Logo "15-Puzzle Flutter" con animación de entrada (desvanecido + escala). Pasa al menú a los 2,6 s o al pulsar **Saltar**. |
| Menú principal | Botones grandes con animación: Jugar, Marcadores, Configuración y Cómo jugar. |
| Configuración | Dificultad (3x3, 4x4, 5x5), estilo de piezas (clásico, colorido, retro, minimalista, modo imagen), contrarreloj, animaciones y sonido. Todo se guarda al instante. |
| Marcadores | Por dificultad: mejor tiempo, menor número de movimientos, fecha y victorias. Mensaje si no hay récords y botón para borrarlos con confirmación. |
| Cómo jugar | Objetivo, cómo mover, cómo se gana, cuándo se pierde y consejos. |
| Juego | Tablero aleatorio siempre resoluble, tocar / deslizar el dedo / flechas del teclado, contador de movimientos, cronómetro desde el primer movimiento, pausa, reiniciar, rendirse. |
| Fin de partida | Ganaste o Perdist, tiempo, movimientos, dificultad, Nuevo récord y botones Reiniciar, Ver tablero y Menú. |

### Cómo se pierde

Con el **modo contrarreloj** activado (Configuración), la partida se pierde si se
acaba el tiempo Fácil 2 min, Medio 6 min, Difícil 15 min. También se pierde al
rendirse. Sin contrarreloj, se puede jugar sin límite.

### Detalles de experiencia de usuario

- La partida se pausa sola si la app pasa a segundo plano, y en pausa el tablero
  se oculta para que no se pueda pensar con el reloj detenido.
- Se pide confirmación antes de salir, reiniciar o rendirse con una partida en curso.
- Las piezas que ya están en su lugar se resaltan, y un indicador muestra cuántas van.
- La primera vez que se pulsa **Jugar** se pide la dificultad; luego se recuerda.
- Diseño adaptable con `LayoutBuilder`: en teléfonos el tablero va debajo de los
  indicadores; en tablet horizontal y escritorio, a la izquierda con un panel lateral.

## Ejecutar

```bash
flutter pub get
flutter run -d chrome
```
