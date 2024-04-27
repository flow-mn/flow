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
  overlayColor: _light.background.withAlpha(0xe0),
  pointerColor: kTransparent,
  angleOffset: 0.0,
  pointerSize: 2.0,
  tooltipTextStyle: lightTheme.textTheme.displaySmall,
  rightClickShowsMenu: true,
  menuAlignment: Alignment.center,
);
PieTheme pieThemeDark = pieThemeLight.copyWith(
  buttonTheme: PieButtonTheme(
    backgroundColor: _dark.secondary,
    iconColor: _dark.onSurface,
  ),
  buttonThemeHovered: PieButtonTheme(
    backgroundColor: _dark.secondary,
    iconColor: _dark.primary,
  ),
  overlayColor: _dark.background.withAlpha(0xe0),
  tooltipTextStyle: darkTheme.textTheme.displaySmall,
);
