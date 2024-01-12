import 'package:flow/theme/theme.dart';
import 'package:flutter/material.dart';

class NavbarButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;

  final int index;
  final int activeIndex;

  final Function(int) onTap;

  bool get isActive => index == activeIndex;

  const NavbarButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.index,
    required this.activeIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconTheme.merge(
      data: IconThemeData(
        fill: (isActive && index != 0) ? 1 : 0,
        color: context.colorScheme.onSecondary,
      ),
      child: Tooltip(
        message: tooltip,
        child: Expanded(
          child: Material(
            type: MaterialType.transparency,
            color: context.colorScheme.onSecondary,
            shape: const StadiumBorder(),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: () => onTap(index),
              // splashColor: Colors.red,
              // splashColor: Theme.of(context).splashColor,
              // focusColor: Colors.blue,
              focusColor: Theme.of(context).focusColor,
              hoverColor: Theme.of(context).hoverColor,
              // highlightColor: Colors.blue,
              // highlightColor: Theme.of(context).highlightColor,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: AnimatedOpacity(
                  opacity: isActive ? 1 : 0.5,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: Icon(icon),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
