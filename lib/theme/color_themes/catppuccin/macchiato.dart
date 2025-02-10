import "dart:ui";

import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/flow_theme_group.dart";

final FlowColorScheme _catppuccinoMacchiatoBase = FlowColorScheme(
  name: "catppuccinMacchiatoBase",
  isDark: true,
  surface: const Color(0xff24273a),
  onSurface: const Color(0xffcad3f5),
  primary: const Color(0xfff0c6c6),
  onPrimary: const Color(0xff181926),
  secondary: const Color(0xfff4dbd6),
  onSecondary: const Color(0xff181926),
  customColors: FlowCustomColors(
    income: Color(0xffa6da95),
    expense: Color(0xffed8796),
    semi: Color(0xff5b6078),
  ),
);

final FlowThemeGroup catppuccinoMacchiato = FlowThemeGroup(
  name: "Catppuccino Macchiato",
  schemes: [
    _catppuccinoMacchiatoBase.copyWith(
      name: "catppuccinFlamingoMacchiato",
      primary: Color(0xfff0c6c6),
      secondary: Color(0xfff4dbd6),
    ),
    _catppuccinoMacchiatoBase.copyWith(
      name: "catppuccinMauveMacchiato",
      primary: Color(0xffc6a0f6),
      secondary: Color(0xfff5bde6),
    ),
    _catppuccinoMacchiatoBase.copyWith(
      name: "catppuccinRedMacchiato",
      primary: Color(0xffed8796),
      secondary: Color(0xffee99a0),
    ),
    _catppuccinoMacchiatoBase.copyWith(
      name: "catppuccinPeachMacchiato",
      primary: Color(0xfff5a97f),
      secondary: Color(0xffeed49f),
    ),
    _catppuccinoMacchiatoBase.copyWith(
      name: "catppuccinGreenMacchiato",
      primary: Color(0xffa6da95),
      secondary: Color(0xff8bd5ca),
    ),
    _catppuccinoMacchiatoBase.copyWith(
      name: "catppuccinSkyMacchiato",
      primary: Color(0xff91d7e3),
      secondary: Color(0xff7dc4e4),
    ),
    _catppuccinoMacchiatoBase.copyWith(
      name: "catppuccinBlueMacchiato",
      primary: Color(0xff8aadf4),
      secondary: Color(0xffb7bdf8),
    ),
  ],
);
