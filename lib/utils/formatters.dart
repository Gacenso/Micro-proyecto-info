/// Da formato a un tiempo como mm:ss (o h:mm:ss si pasa de una hora).
String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
}

/// Tiempo con décimas, por ejemplo "01:23.4", para resultados y récords.
String formatDurationPrecise(Duration duration) {
  final tenths = (duration.inMilliseconds.remainder(1000) ~/ 100).toString();
  return '${formatDuration(duration)}.$tenths';
}

const _months = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun',
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

/// Fecha corta en español, por ejemplo "16 oct 2026".
String formatDate(DateTime date) {
  final local = date.toLocal();
  return '${local.day} ${_months[local.month - 1]} ${local.year}';
}

/// "1 movimiento" o "N movimientos".
String movesLabel(int moves) => moves == 1 ? '1 movimiento' : '$moves movimientos';
