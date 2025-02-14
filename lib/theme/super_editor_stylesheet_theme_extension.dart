import "dart:developer";

import "package:flutter/material.dart";
import "package:super_editor/super_editor.dart" as super_editor;

class SuperEditorThemeExtension
    extends ThemeExtension<SuperEditorThemeExtension> {
  final super_editor.Stylesheet stylesheet;
  final super_editor.SelectionStyles selectionStyles;

  const SuperEditorThemeExtension({
    required this.stylesheet,
    required this.selectionStyles,
  });

  @override
  ThemeExtension<SuperEditorThemeExtension> copyWith({
    super_editor.Stylesheet? pieTheme,
    super_editor.SelectionStyles? selectionStyles,
  }) {
    return SuperEditorThemeExtension(
      stylesheet: pieTheme ?? stylesheet,
      selectionStyles: selectionStyles ?? this.selectionStyles,
    );
  }

  @override
  ThemeExtension<SuperEditorThemeExtension> lerp(
    ThemeExtension<SuperEditorThemeExtension>? other,
    double t,
  ) {
    log("SuperEditorStylesheetExtension: lerp is not available for SuperEditorStylesheet");

    return (t < 0.5 ? this : other) as SuperEditorThemeExtension;
  }
}
