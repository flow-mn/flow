part of "theme.dart";

PieTheme pieTheme = PieTheme(
  buttonTheme: PieButtonTheme(
    backgroundColor: _colorSchemeLight.secondary,
    iconColor: _colorSchemeLight.onSurface,
  ),
  buttonThemeHovered: PieButtonTheme(
    backgroundColor: _colorSchemeLight.secondary,
    iconColor: _colorSchemeLight.primary,
  ),
  overlayColor: _colorSchemeLight.secondary.withAlpha(0x80),
  pointerColor: _colorSchemeLight.primary,
  pointerSize: 16.0,
);
