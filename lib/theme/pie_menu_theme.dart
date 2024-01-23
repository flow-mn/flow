part of "theme.dart";

PieTheme pieThemeLight = PieTheme(
  buttonTheme: PieButtonTheme(
    backgroundColor: _light.secondary,
    iconColor: _light.onSurface,
  ),
  buttonThemeHovered: PieButtonTheme(
    backgroundColor: _light.secondary,
    iconColor: _light.primary,
  ),
  overlayColor: _light.secondary.withAlpha(0x80),
  pointerColor: kTransparent,
  angleOffset: 0.0,
  pointerSize: 2.0,
  tooltipTextStyle: lightTheme.textTheme.displaySmall,
  rightClickShowsMenu: true,
  leftClickShowsMenu: false,
);
PieTheme pieThemeDark = PieTheme(
  buttonTheme: PieButtonTheme(
    backgroundColor: _dark.secondary,
    iconColor: _dark.onSurface,
  ),
  buttonThemeHovered: PieButtonTheme(
    backgroundColor: _dark.secondary,
    iconColor: _dark.primary,
  ),
  overlayColor: _dark.secondary.withAlpha(0x80),
  pointerColor: kTransparent,
  angleOffset: 0.0,
  pointerSize: 2.0,
  tooltipTextStyle: lightTheme.textTheme.displaySmall,
  rightClickShowsMenu: true,
  leftClickShowsMenu: false,
);
