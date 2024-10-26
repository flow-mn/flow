import "dart:ui";

import "package:flow/theme/flow_color_scheme.dart";

final FlowColorScheme palenight = FlowColorScheme(
  isDark: true,
  surface: const Color(0xff292D3E),
  onSurface: const Color(0xfff5f6fa),
  primary: const Color(0xfff5f6fa),
  onPrimary: const Color(0xff444267),
  secondary: const Color(0xff202331),
  onSecondary: const Color(0xfff5f6fa),
  customColors: FlowCustomColors(
    income: Color(0xFFc3e88d),
    expense: Color(0xFFf07178),
    semi: Color(0xFF676E95),
  ),
);
