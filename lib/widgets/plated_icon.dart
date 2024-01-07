import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/surface.dart';
import 'package:flutter/widgets.dart';

class PlatedIcon extends StatelessWidget {
  final EdgeInsets padding;

  final double iconSize;
  final IconData icon;

  final double elevation;

  final bool selected;

  const PlatedIcon(
    this.icon, {
    super.key,
    this.padding = const EdgeInsets.all(8.0),
    this.iconSize = 24.0,
    this.elevation = 0,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Surface(
      elevation: elevation,
      color: selected ? context.colorScheme.primary : null,
      builder: (context) => Padding(
        padding: padding,
        child: Icon(
          icon,
          size: iconSize,
          color: selected ? context.colorScheme.secondary : null,
        ),
      ),
    );
  }
}
