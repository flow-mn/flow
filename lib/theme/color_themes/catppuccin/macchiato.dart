import "dart:ui";

import "package:flow/data/flow_icon.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/flow_theme_group.dart";

final FlowColorScheme _catppuccinMacchiatoBase = FlowColorScheme(
  name: "catppuccinMacchiatoBase",
  isDark: true,
  surface: const Color(0xff24273a),
  onSurface: const Color(0xffcad3f5),
  primary: const Color(0xfff0c6c6),
  onPrimary: const Color(0xff181926),
  secondary: const Color(0xff181926),
  onSecondary: const Color(0xffcad3f5),
  customColors: FlowCustomColors(
    income: Color(0xffa6da95),
    expense: Color(0xffed8796),
    semi: Color(0xff5b6078),
  ),
);

final FlowThemeGroup catppuccinMacchiato = FlowThemeGroup(
  name: "Catppuccin Macchiato",
  icon: FlowIconData.emoji("🌺"),
  schemes: [
    _catppuccinMacchiatoBase.copyWith(
      name: "catppuccinFlamingoMacchiato",
      primary: Color(0xfff0c6c6),
    ),
    _catppuccinMacchiatoBase.copyWith(
      name: "catppuccinRosewaterMacchiato",
      primary: Color(0xfff4dbd6),
    ),
    _catppuccinMacchiatoBase.copyWith(
      name: "catppuccinMauveMacchiato",
      primary: Color(0xffc6a0f6),
    ),
    _catppuccinMacchiatoBase.copyWith(
      name: "catppuccinPinkMacchiato",
      primary: Color(0xfff5bde6),
    ),
    _catppuccinMacchiatoBase.copyWith(
      name: "catppuccinRedMacchiato",
      primary: Color(0xffed8796),
    ),
    _catppuccinMacchiatoBase.copyWith(
      name: "catppuccinMaroonMacchiato",
      primary: Color(0xffee99a0),
    ),
    _catppuccinMacchiatoBase.copyWith(
      name: "catppuccinPeachMacchiato",
      primary: Color(0xfff5a97f),
    ),
    _catppuccinMacchiatoBase.copyWith(
      name: "catppuccinYellowMacchiato",
      primary: Color(0xffeed49f),
    ),
    _catppuccinMacchiatoBase.copyWith(
      name: "catppuccinGreenMacchiato",
      primary: Color(0xffa6da95),
    ),
    _catppuccinMacchiatoBase.copyWith(
      name: "catppuccinTealMacchiato",
      primary: Color(0xff8bd5ca),
    ),
    _catppuccinMacchiatoBase.copyWith(
      name: "catppuccinSkyMacchiato",
      primary: Color(0xff91d7e3),
    ),
    _catppuccinMacchiatoBase.copyWith(
      name: "catppuccinSapphireMacchiato",
      primary: Color(0xff7dc4e4),
    ),
    _catppuccinMacchiatoBase.copyWith(
      name: "catppuccinBlueMacchiato",
      primary: Color(0xff8aadf4),
    ),
    _catppuccinMacchiatoBase.copyWith(
      name: "catppuccinLavenderMacchiato",
      primary: Color(0xffb7bdf8),
    ),
  ],
);
