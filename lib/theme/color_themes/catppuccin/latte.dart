import "dart:ui";

import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/flow_theme_group.dart";

final FlowColorScheme _catppuccinLatteBase = FlowColorScheme(
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

final FlowThemeGroup catppuccinLatte = FlowThemeGroup(
  name: "Catppuccin Latte",
  schemes: [
    _catppuccinLatteBase.copyWith(
      name: "catppuccinFlamingoLatte",
      primary: Color(0xffdd7878),
      secondary: Color(0xffdc8a78),
    ),
    _catppuccinLatteBase.copyWith(
      name: "catppuccinMauveLatte",
      primary: Color(0xff8839ef),
      secondary: Color(0xffea76cb),
    ),
    _catppuccinLatteBase.copyWith(
      name: "catppuccinRedLatte",
      primary: Color(0xffd20f39),
      secondary: Color(0xffe64553),
    ),
    _catppuccinLatteBase.copyWith(
      name: "catppuccinPeachLatte",
      primary: Color(0xfffe640b),
      secondary: Color(0xffdf8e1d),
    ),
    _catppuccinLatteBase.copyWith(
      name: "catppuccinGreenLatte",
      primary: Color(0xff40a02b),
      secondary: Color(0xff179299),
    ),
    _catppuccinLatteBase.copyWith(
      name: "catppuccinSkyLatte",
      primary: Color(0xff04a5e5),
      secondary: Color(0xff209fb5),
    ),
    _catppuccinLatteBase.copyWith(
      name: "catppuccinBlueLatte",
      primary: Color(0xff1e66f5),
      secondary: Color(0xff7287fd),
    ),
  ],
);
