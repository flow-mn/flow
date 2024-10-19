import "package:flow/theme/flow_color_scheme.dart";
import "package:flutter/material.dart";

final darkDefault = FlowColorScheme(
  isDark: true,
  primary: Color(0xFFF2C0FF),
  onPrimary: Color(0xFF222222),
  secondary: Color(0xFF111111),
  onSecondary: Color(0xFFf5f6fa),
  customColors: FlowCustomColors(
    income: Color(0xFF32CC70),
    expense: Color(0xFFFF4040),
    semi: Color(0xFF97919B),
  ),
);
