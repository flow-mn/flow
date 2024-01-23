import 'package:flow/theme/navbar_theme.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

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
    final NavbarTheme navbarTheme = Theme.of(context).extension<NavbarTheme>()!;

    return Expanded(
      child: Tooltip(
        message: tooltip,
        child: Material(
          type: MaterialType.transparency,
          color: navbarTheme.backgroundColor,
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () => onTap(index),
            focusColor: Theme.of(context).focusColor,
            hoverColor: Theme.of(context).hoverColor,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: AnimatedOpacity(
                opacity: isActive ? 1 : navbarTheme.inactiveIconOpacity,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: Icon(
                  icon,
                  color: navbarTheme.activeIconColor,
                  fill:
                      (isActive && icon != Symbols.circle_rounded) ? 1.0 : 0.0,
                  weight: isActive ? 600.0 : 400.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
