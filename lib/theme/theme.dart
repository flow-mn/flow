import 'package:flow/theme/flow_colors.dart';
import 'package:flow/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:pie_menu/pie_menu.dart';

export "helpers.dart";

part "pie_menu_theme.dart";
part "text_theme.dart";
part "color_scheme.dart";

// const _fontFamily = "Shantell Sans";

final _fontFamily = isAprilFools ? "Shantell Sans" : "Poppins";

const _fontFamilyFallback = [
  "Roboto",
  "SF Pro Display",
  "Arial",
];

final lightTheme = ThemeData(
  useMaterial3: true,
  fontFamily: _fontFamily,
  fontFamilyFallback: _fontFamilyFallback,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  brightness: Brightness.light,
  colorScheme: _colorSchemeLight,
  cardTheme: CardTheme(
    color: _colorSchemeLight.surface,
  ),
  extensions: [
    FlowColors(
      income: const Color(0xFF32CC70),
      expense: _colorSchemeLight.error,
      semi: const Color(0xFF6A666D),
    ),
  ],
  iconTheme: IconThemeData(
    color: _colorSchemeLight.onBackground,
    size: 24.0,
    fill: 1.0,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: _colorSchemeLight.onSurface,
    unselectedItemColor: _colorSchemeLight.onSurface.withAlpha(0x80),
    backgroundColor: _colorSchemeLight.secondary,
  ),
  textTheme: _textTheme
      .apply(
        fontFamily: _fontFamily,
        fontFamilyFallback: _fontFamilyFallback,
        bodyColor: _colorSchemeLight.onBackground,
        displayColor: _colorSchemeLight.onSurface,
        decorationColor: _colorSchemeLight.onBackground,
      )
      .copyWith(),
  highlightColor: _colorSchemeLight.onBackground.withAlpha(0x16),
  splashColor: _colorSchemeLight.onBackground.withAlpha(0x12),
  listTileTheme: ListTileThemeData(
    iconColor: _colorSchemeLight.primary,
    selectedTileColor: _colorSchemeLight.secondary,
  ),
  textSelectionTheme: TextSelectionThemeData(
    selectionColor: _colorSchemeLight.secondary,
    cursorColor: _colorSchemeLight.primary,
    selectionHandleColor: _colorSchemeLight.primary,
  ),
);
