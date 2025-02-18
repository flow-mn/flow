import "dart:ui";

import "package:flutter/material.dart";

class NavbarTheme extends ThemeExtension<NavbarTheme> {
  final Color backgroundColor;
  final Color activeIconColor;
  final double inactiveIconOpacity;
  final Color transactionButtonBackgroundColor;
  final Color transactionButtonForegroundColor;

  NavbarTheme({
    required this.backgroundColor,
    required this.activeIconColor,
    required this.inactiveIconOpacity,
    required this.transactionButtonBackgroundColor,
    required this.transactionButtonForegroundColor,
  });

  @override
  ThemeExtension<NavbarTheme> copyWith({
    Color? backgroundColor,
    Color? activeIconColor,
    double? inactiveIconOpacity,
    Color? transactionButtonBackgroundColor,
    Color? transactionButtonForegroundColor,
  }) {
    return NavbarTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      activeIconColor: activeIconColor ?? this.activeIconColor,
      inactiveIconOpacity: inactiveIconOpacity ?? this.inactiveIconOpacity,
      transactionButtonBackgroundColor:
          transactionButtonBackgroundColor ??
          this.transactionButtonBackgroundColor,
      transactionButtonForegroundColor:
          transactionButtonForegroundColor ??
          this.transactionButtonForegroundColor,
    );
  }

  @override
  ThemeExtension<NavbarTheme> lerp(
    ThemeExtension<NavbarTheme>? other,
    double t,
  ) {
    if (other is! NavbarTheme) return this;

    return NavbarTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      activeIconColor: Color.lerp(activeIconColor, other.activeIconColor, t)!,
      inactiveIconOpacity:
          lerpDouble(inactiveIconOpacity, other.inactiveIconOpacity, t)!,
      transactionButtonBackgroundColor:
          Color.lerp(
            transactionButtonBackgroundColor,
            other.transactionButtonBackgroundColor,
            t,
          )!,
      transactionButtonForegroundColor:
          Color.lerp(
            transactionButtonForegroundColor,
            other.transactionButtonForegroundColor,
            t,
          )!,
    );
  }
}
