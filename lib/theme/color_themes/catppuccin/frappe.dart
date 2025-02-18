import "dart:ui";

import "package:flow/data/flow_icon.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/flow_theme_group.dart";

final FlowColorScheme _catppuccinFrappeBase = FlowColorScheme(
  name: "catppuccinFrappeBase",
  isDark: true,
  surface: const Color(0xff303446),
  onSurface: const Color(0xffc6d0f5),
  primary: const Color(0xffeebebe),
  onPrimary: const Color(0xff232634),
  secondary: const Color(0xff232634),
  onSecondary: const Color(0xffc6d0f5),
  customColors: FlowCustomColors(
    income: Color(0xffa6d189),
    expense: Color(0xffe78284),
    semi: Color(0xff949cbb),
  ),
);

final FlowThemeGroup catppuccinFrappe = FlowThemeGroup(
  name: "Catppuccin Frappé",
  icon: FlowIconData.emoji("🪴"),
  schemes: [
    _catppuccinFrappeBase.copyWith(
      name: "catppuccinFlamingoFrappe",
      primary: Color(0xffeebebe),
    ),
    _catppuccinFrappeBase.copyWith(
      name: "catppuccinRosewaterFrappe",
      primary: Color(0xfff2d5cf),
    ),
    _catppuccinFrappeBase.copyWith(
      name: "catppuccinMauveFrappe",
      primary: Color(0xffca9ee6),
    ),
    _catppuccinFrappeBase.copyWith(
      name: "catppuccinPinkFrappe",
      primary: Color(0xfff4b8e4),
    ),
    _catppuccinFrappeBase.copyWith(
      name: "catppuccinRedFrappe",
      primary: Color(0xffe78284),
    ),
    _catppuccinFrappeBase.copyWith(
      name: "catppuccinMaroonFrappe",
      primary: Color(0xffea999c),
    ),
    _catppuccinFrappeBase.copyWith(
      name: "catppuccinPeachFrappe",
      primary: Color(0xffef9f76),
    ),
    _catppuccinFrappeBase.copyWith(
      name: "catppuccinYellowFrappe",
      primary: Color(0xffe5c890),
    ),
    _catppuccinFrappeBase.copyWith(
      name: "catppuccinGreenFrappe",
      primary: Color(0xffa6d189),
    ),
    _catppuccinFrappeBase.copyWith(
      name: "catppuccinTealFrappe",
      primary: Color(0xff81c8be),
    ),
    _catppuccinFrappeBase.copyWith(
      name: "catppuccinSkyFrappe",
      primary: Color(0xff99d1db),
    ),
    _catppuccinFrappeBase.copyWith(
      name: "catppuccinSapphireFrappe",
      primary: Color(0xff85c1dc),
    ),
    _catppuccinFrappeBase.copyWith(
      name: "catppuccinBlueFrappe",
      primary: Color(0xff8caaee),
    ),
    _catppuccinFrappeBase.copyWith(
      name: "catppuccinLavenderFrappe",
      primary: Color(0xffbabbf1),
    ),
  ],
);
