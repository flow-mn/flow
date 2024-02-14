import 'package:flow/theme/flow_colors.dart';
import 'package:flow/theme/navbar_theme.dart';
import 'package:flutter/material.dart';
import 'package:pie_menu/pie_menu.dart';

export "helpers.dart";

part "pie_menu_theme.dart";
part "text_theme.dart";
part "color_scheme.dart";

const _fontFamily = "Poppins";

const kTransparent = Color(0x00000000);

const _fontFamilyFallback = [
  "SF Pro Display",
  "SF UI Text",
  "Helvetica",
  "Roboto",
  "Arial",
];

final lightTheme = ThemeData(
  useMaterial3: true,
  fontFamily: _fontFamily,
  fontFamilyFallback: _fontFamilyFallback,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  brightness: Brightness.light,
  colorScheme: _light,
  cardTheme: CardTheme(
    color: _light.surface,
    surfaceTintColor: _light.primary,
  ),
  extensions: [
    FlowColors(
      income: const Color(0xFF32CC70),
      expense: _light.error,
      semi: const Color(0xFF6A666D),
    ),
    NavbarTheme(
      backgroundColor: _light.secondary,
      activeIconColor: _light.primary,
      inactiveIconOpacity: 0.5,
      transactionButtonBackgroundColor: _light.primary,
      transactionButtonForegroundColor: _light.onPrimary,
    ),
  ],
  iconTheme: IconThemeData(
    color: _light.onBackground,
    size: 24.0,
    fill: 1.0,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: _light.primary,
    unselectedItemColor: _light.primary.withAlpha(0x80),
    backgroundColor: _light.secondary,
  ),
  textTheme: _textTheme
      .apply(
        fontFamily: _fontFamily,
        fontFamilyFallback: _fontFamilyFallback,
        bodyColor: _light.onBackground,
        displayColor: _light.onSurface,
        decorationColor: _light.onBackground,
      )
      .copyWith(),
  highlightColor: _light.onBackground.withAlpha(0x16),
  splashColor: _light.onBackground.withAlpha(0x12),
  listTileTheme: ListTileThemeData(
    iconColor: _light.primary,
    selectedTileColor: _light.secondary,
  ),
  textSelectionTheme: TextSelectionThemeData(
    selectionColor: _light.secondary,
    cursorColor: _light.primary,
    selectionHandleColor: _light.primary,
  ),
);
final darkTheme = ThemeData(
  useMaterial3: true,
  fontFamily: _fontFamily,
  fontFamilyFallback: _fontFamilyFallback,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  brightness: Brightness.dark,
  colorScheme: _dark,
  cardTheme: CardTheme(
    color: _dark.surface,
    surfaceTintColor: _dark.primary,
  ),
  extensions: [
    FlowColors(
      income: const Color(0xFF32CC70),
      expense: _dark.error,
      semi: const Color(0xFF97919B),
    ),
    NavbarTheme(
      backgroundColor: _dark.secondary,
      activeIconColor: _dark.primary,
      inactiveIconOpacity: 0.5,
      transactionButtonBackgroundColor: _dark.primary,
      transactionButtonForegroundColor: _dark.onPrimary,
    ),
  ],
  iconTheme: IconThemeData(
    color: _dark.onBackground,
    size: 24.0,
    fill: 1.0,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: _dark.onSurface,
    unselectedItemColor: _dark.onSurface.withAlpha(0x80),
    backgroundColor: _dark.secondary,
  ),
  textTheme: _textTheme
      .apply(
        fontFamily: _fontFamily,
        fontFamilyFallback: _fontFamilyFallback,
        bodyColor: _dark.onBackground,
        displayColor: _dark.onSurface,
        decorationColor: _dark.onBackground,
      )
      .copyWith(),
  highlightColor: _dark.onBackground.withAlpha(0x16),
  splashColor: _dark.onBackground.withAlpha(0x12),
  listTileTheme: ListTileThemeData(
    iconColor: _dark.primary,
    selectedTileColor: _dark.secondary,
  ),
  textSelectionTheme: TextSelectionThemeData(
    selectionColor: _dark.primary,
    cursorColor: _dark.primary,
    selectionHandleColor: _dark.primary,
  ),
);
