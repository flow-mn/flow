import "dart:developer";

import "package:flow/theme/color_themes/dark_default.dart";
import "package:flow/theme/color_themes/light.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flutter/material.dart";

export "dark_default.dart";
export "light.dart";

final Map<String, FlowColorScheme> lightThemes = {
  "shadeOfViolet": shadeOfViolet, // default
  "blissfulBerry": blissfulBerry,
  "cherryPlum": cherryPlum,
  "crispChristmasCranberries": crispChristmasCranberries,
  "burntSienna": burntSienna,
  "soilOfAvagddu": soilOfAvagddu,
  "flagGreen": flagGreen,
  "tropicana": tropicana,
  "toyCamouflage": toyCamouflage,
  "spreadsheetGreen": spreadsheetGreen,
  "tokiwaGreen": tokiwaGreen,
  "hydraTurquoise": hydraTurquoise,
  "peacockBlue": peacockBlue,
  "egyptianBlue": egyptianBlue,
  "bohemianBlue": bohemianBlue,
  "spaceBattleBlue": spaceBattleBlue,
};

final Map<String, FlowColorScheme> darkThemes = {
  "dark": darkDefault, // default
};

({FlowColorScheme scheme, ThemeMode mode})? getTheme(String? themeName) {
  if (themeName == null) return null;

  final light = lightThemes[themeName];
  if (light != null) return (scheme: light, mode: ThemeMode.light);

  final dark = darkThemes[themeName];
  if (dark != null) return (scheme: dark, mode: ThemeMode.dark);

  log("Unknown theme: $themeName");
  return null;
}
