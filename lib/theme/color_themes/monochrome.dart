import "dart:ui";

import "package:flow/theme/flow_color_scheme.dart";

final FlowColorScheme monochrome = FlowColorScheme(
  name: "monochrome",
  isDark: false,
  surface: const Color(0xfff7f8fa),
  onSurface: const Color(0xff101828),
  primary: const Color(0xff444444),
  onPrimary: const Color(0xfff7f8fa),
  secondary: const Color(0xfff1f2f4),
  onSecondary: const Color(0xff101828),
  customColors: FlowCustomColors(
    income: Color(0xFF32CC70),
    expense: Color(0xFFFF4040),
    semi: Color(0xFF6A666D),
  ),
);
