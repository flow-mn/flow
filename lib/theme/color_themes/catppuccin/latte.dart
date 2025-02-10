import "dart:ui";

import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/flow_theme_group.dart";

final FlowColorScheme _catppuccinoLatteBase = FlowColorScheme(
  name: "Catppuccin Latte Base",
  isDark: false,
  surface: const Color(0xffeff1f5),
  onSurface: const Color(0xff4c4f69),
  primary: const Color(0xffdd7878),
  onPrimary: const Color(0xffeff1f5),
  secondary: const Color(0xffdc8a78),
  onSecondary: const Color(0xffeff1f5),
  customColors: FlowCustomColors(
    income: Color(0xff40a02b),
    expense: Color(0xffd20f39),
    semi: Color(0xff9ca0b0),
  ),
);

final FlowThemeGroup catppuccinoLatte = FlowThemeGroup(
  name: "Catppuccino Latte",
  schemes: [
    _catppuccinoLatteBase.copyWith(
      name: "catppuccinoFlamingoLatte",
      primary: Color(0xffdd7878),
      secondary: Color(0xffdc8a78),
    ),
    _catppuccinoLatteBase.copyWith(
      name: "catppuccinoMauveLatte",
      primary: Color(0xff8839ef),
      secondary: Color(0xffea76cb),
    ),
    _catppuccinoLatteBase.copyWith(
      name: "catppuccinoRedLatte",
      primary: Color(0xffd20f39),
      secondary: Color(0xffe64553),
    ),
    _catppuccinoLatteBase.copyWith(
      name: "catppuccinoPeachLatte",
      primary: Color(0xfffe640b),
      secondary: Color(0xffdf8e1d),
    ),
    _catppuccinoLatteBase.copyWith(
      name: "catppuccinoGreenLatte",
      primary: Color(0xff40a02b),
      secondary: Color(0xff179299),
    ),
    _catppuccinoLatteBase.copyWith(
      name: "catppuccinoSkyLatte",
      primary: Color(0xff04a5e5),
      secondary: Color(0xff209fb5),
    ),
    _catppuccinoLatteBase.copyWith(
      name: "catppuccinoBlueLatte",
      primary: Color(0xff1e66f5),
      secondary: Color(0xff7287fd),
    ),
  ],
);
