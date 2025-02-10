import "dart:ui";

import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/flow_theme_group.dart";

final FlowColorScheme _catppuccinoFrappeBase = FlowColorScheme(
  name: "catppuccinFrappeBase",
  isDark: true,
  surface: const Color(0xff303446),
  onSurface: const Color(0xffc6d0f5),
  primary: const Color(0xffeebebe),
  onPrimary: const Color(0xff232634),
  secondary: const Color(0xfff2d5cf),
  onSecondary: const Color(0xff232634),
  customColors: FlowCustomColors(
    income: Color(0xffa6d189),
    expense: Color(0xffe78284),
    semi: Color(0xff949cbb),
  ),
);

final FlowThemeGroup catppuccinoFrappe = FlowThemeGroup(
  name: "Catppuccino Frappé",
  schemes: [
    _catppuccinoFrappeBase.copyWith(
      name: "catppuccinoFlamingoFrappe",
      primary: Color(0xffeebebe),
      secondary: Color(0xfff2d5cf),
    ),
    _catppuccinoFrappeBase.copyWith(
      name: "catppuccinoMauveFrappe",
      primary: Color(0xffca9ee6),
      secondary: Color(0xfff4b8e4),
    ),
    _catppuccinoFrappeBase.copyWith(
      name: "catppuccinoRedFrappe",
      primary: Color(0xffe78284),
      secondary: Color(0xffea999c),
    ),
    _catppuccinoFrappeBase.copyWith(
      name: "catppuccinoPeachFrappe",
      primary: Color(0xffef9f76),
      secondary: Color(0xffe5c890),
    ),
    _catppuccinoFrappeBase.copyWith(
      name: "catppuccinoGreenFrappe",
      primary: Color(0xffa6d189),
      secondary: Color(0xff81c8be),
    ),
    _catppuccinoFrappeBase.copyWith(
      name: "catppuccinoSkyFrappe",
      primary: Color(0xff99d1db),
      secondary: Color(0xff85c1dc),
    ),
    _catppuccinoFrappeBase.copyWith(
      name: "catppuccinoBlueFrappe",
      primary: Color(0xff8caaee),
      secondary: Color(0xffbabbf1),
    ),
  ],
);
