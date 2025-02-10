import "dart:ui";

import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/flow_theme_group.dart";

final FlowColorScheme _catppuccinoMochaBase = FlowColorScheme(
  name: "catppuccinMochaBase",
  isDark: true,
  surface: const Color(0xff1e1e2e),
  onSurface: const Color(0xffcdd6f4),
  primary: const Color(0xfff2cdcd),
  onPrimary: const Color(0xff11111b),
  secondary: const Color(0xfff5e0dc),
  onSecondary: const Color(0xff11111b),
  customColors: FlowCustomColors(
    income: Color(0xffa6e3a1),
    expense: Color(0xfff38ba8),
    semi: Color(0xff9399b2),
  ),
);

final FlowThemeGroup catppuccinoMocha = FlowThemeGroup(
  name: "Catppuccino Mocha",
  schemes: [
    _catppuccinoMochaBase.copyWith(
      name: "catppuccinFlamingoMocha",
      primary: Color(0xfff2cdcd),
      secondary: Color(0xfff5e0dc),
    ),
    _catppuccinoMochaBase.copyWith(
      name: "catppuccinMauveMocha",
      primary: Color(0xffcba6f7),
      secondary: Color(0xfff5c2e7),
    ),
    _catppuccinoMochaBase.copyWith(
      name: "catppuccinRedMocha",
      primary: Color(0xfff38ba8),
      secondary: Color(0xffeba0ac),
    ),
    _catppuccinoMochaBase.copyWith(
      name: "catppuccinPeachMocha",
      primary: Color(0xfffab387),
      secondary: Color(0xfff9e2af),
    ),
    _catppuccinoMochaBase.copyWith(
      name: "catppuccinGreenMocha",
      primary: Color(0xffa6e3a1),
      secondary: Color(0xff94e2d5),
    ),
    _catppuccinoMochaBase.copyWith(
      name: "catppuccinSkyMocha",
      primary: Color(0xff89dceb),
      secondary: Color(0xff74c7ec),
    ),
    _catppuccinoMochaBase.copyWith(
      name: "catppuccinBlueMocha",
      primary: Color(0xff89b4fa),
      secondary: Color(0xffb4befe),
    ),
  ],
);
