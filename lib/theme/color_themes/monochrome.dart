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
    // Match the deepened light-theme pair so income/expense stay legible on the
    // light grey `secondary` card and surface. See [flowLights].
    income: Color(0xFF15803D),
    expense: Color(0xFFC42525),
    semi: Color(0xFF6A666D),
  ),
);
