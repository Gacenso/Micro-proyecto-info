import 'package:flutter/material.dart';

/// Botón grande del menú: se encoge y cambia de color al presionarlo.
///
/// Es un StatefulWidget porque guarda si está presionado o con el
/// cursor encima (estado visual que solo le importa a este botón).
/// Usa [InkWell], así que también funciona con teclado (Tab + Enter).
class PressableButton extends StatefulWidget {
  const PressableButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.subtitle,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onPressed;

  /// El botón principal ("Jugar") se pinta con el color principal.
  final bool primary;

  @override
  State<PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<PressableButton> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background =
        widget.primary ? scheme.primary : scheme.surfaceContainerHigh;
    final foreground = widget.primary ? scheme.onPrimary : scheme.onSurface;
    final pressedColor = widget.primary
        ? Color.lerp(scheme.primary, Colors.black, 0.18)!
        : scheme.surfaceContainerHighest;
    final radius = BorderRadius.circular(20);

    return AnimatedScale(
      scale: _pressed ? 0.95 : (_hovered ? 1.02 : 1.0),
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _pressed ? pressedColor : background,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: _pressed ? 0.05 : 0.12),
              blurRadius: _pressed ? 4 : 14,
              offset: Offset(0, _pressed ? 2 : 6),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: widget.onPressed,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            onHover: (value) => setState(() => _hovered = value),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: foreground.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(widget.icon, color: foreground),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label,
                          style: TextStyle(
                            color: foreground,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (widget.subtitle != null)
                          Text(
                            widget.subtitle!,
                            style: TextStyle(
                              color: foreground.withValues(alpha: 0.75),
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: foreground),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
