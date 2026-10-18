/// Estilos de visualización de las piezas del tablero.
enum TileStyle {
  classic('Numérico clásico', 'Números sobre fichas sobrias'),
  colorful('Colorido', 'Cada pieza con su propio color'),
  retro('Retro', 'Estética arcade de 8 bits'),
  minimal('Minimalista', 'Solo bordes y números finos'),
  image('Modo imagen', 'Forma un paisaje al ordenar las piezas');

  const TileStyle(this.label, this.description);

  final String label;
  final String description;

  static TileStyle fromName(String? name) {
    for (final style in TileStyle.values) {
      if (style.name == name) return style;
    }
    return TileStyle.classic;
  }
}
