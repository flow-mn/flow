import "package:flow/theme/color_themes/registry.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/navbar_theme.dart";
import "package:flow/theme/pie_theme_extension.dart";
import "package:flow/theme/text_theme.dart";
import "package:flutter/material.dart";
import "package:pie_menu/pie_menu.dart";

export "helpers.dart";

const Color kTransparent = Color(0x00000000);

class ThemeFactory {
  static const fontFamily = "Poppins";

  static const fontFamilyFallback = [
    "SF Pro Display",
    "SF UI Text",
    "Helvetica",
    "Google Sans",
    "Roboto",
    "Arial",
  ];

  final FlowColorScheme flowColorScheme;

  bool get isDark => flowColorScheme.isDark;
  ColorScheme get colorScheme => flowColorScheme.colorScheme;

  late final PieTheme pieTheme;
  late final ThemeData materialTheme;

  ThemeFactory(this.flowColorScheme) {
    pieTheme = PieTheme(
      buttonTheme: PieButtonTheme(
        backgroundColor: colorScheme.secondary,
        iconColor: colorScheme.onSurface,
      ),
      buttonThemeHovered: PieButtonTheme(
        backgroundColor: colorScheme.secondary,
        iconColor: colorScheme.primary,
      ),
      overlayColor: colorScheme.surface.withAlpha(0xe0),
      pointerColor: kTransparent,
      angleOffset: 0.0,
      pointerSize: 2.0,
      tooltipTextStyle:
          flowTextTheme.displaySmall!.copyWith(color: colorScheme.onSurface),
      rightClickShowsMenu: true,
      menuAlignment: Alignment.center,
    );

    final Color bottomNavigationBarItemColor =
        isDark ? colorScheme.onSurface : colorScheme.primary;

    materialTheme = ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      cardTheme: CardTheme(
        color: colorScheme.secondary,
        surfaceTintColor: colorScheme.primary,
      ),
      extensions: [
        flowColorScheme.customColors,
        PieThemeExtension(pieTheme: pieTheme),
        NavbarTheme(
          backgroundColor: colorScheme.secondary,
          activeIconColor: colorScheme.primary,
          inactiveIconOpacity: 0.5,
          transactionButtonBackgroundColor: colorScheme.primary,
          transactionButtonForegroundColor: colorScheme.onPrimary,
        ),
      ],
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24.0,
        fill: 1.0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: bottomNavigationBarItemColor,
        unselectedItemColor: bottomNavigationBarItemColor.withAlpha(0x80),
        backgroundColor: colorScheme.secondary,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
      ),
      textTheme: flowTextTheme
          .apply(
            fontFamily: fontFamily,
            fontFamilyFallback: fontFamilyFallback,
            bodyColor: colorScheme.onSurface,
            displayColor: colorScheme.onSurface,
            decorationColor: colorScheme.onSurface,
          )
          .copyWith(),
      highlightColor: colorScheme.onSurface.withAlpha(0x16),
      splashColor: colorScheme.onSurface.withAlpha(0x12),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.primary,
        selectedTileColor: colorScheme.secondary,
        selectedColor: isDark ? colorScheme.primary : null,
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withAlpha(0x61);
            }
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primary;
            }
            if (states.contains(WidgetState.pressed)) {
              return colorScheme.onSurface;
            }
            if (states.contains(WidgetState.hovered)) {
              return colorScheme.onSurface;
            }
            if (states.contains(WidgetState.focused)) {
              return colorScheme.onSurface;
            }
            return colorScheme.onSurfaceVariant;
          },
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.onSurface.withAlpha(0x61);
            }
            return kTransparent;
          }
          if (states.contains(WidgetState.selected)) {
            if (states.contains(WidgetState.error)) {
              return colorScheme.error;
            }
            return colorScheme.primary;
          }
          return kTransparent;
        }),
      ),
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: isDark ? colorScheme.primary : colorScheme.secondary,
        cursorColor: colorScheme.primary,
        selectionHandleColor: colorScheme.primary,
      ),
      tabBarTheme: TabBarTheme(
        dividerColor: colorScheme.primary,
      ),
    );
  }

  /// Returns a [ThemeFactory] instance based on the provided [themeName].
  ///
  /// If [themeName] is `null`, the default theme is returned.
  ///
  /// Pass [preferDark] to influence the choice of default theme.
  factory ThemeFactory.fromThemeName(
    String? themeName, {
    bool preferDark = false,
    bool preferOled = false,
  }) {
    final resolved = getTheme(
      themeName,
      preferDark: preferDark,
      preferOled: preferOled,
    );

    return ThemeFactory(resolved);
  }
}
