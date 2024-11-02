import "dart:developer";

import "package:flow/theme/color_themes/default_darks.dart";
import "package:flow/theme/color_themes/default_lights.dart";
import "package:flow/theme/color_themes/palenight.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flutter/material.dart";

export "default_darks.dart";
export "default_lights.dart";
export "palenight.dart";

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
  "electricLavender": electricLavender,
  "pinkQuartz": pinkQuartz,
  "cottonCandy": cottonCandy,
  "piglet": piglet,
  "simplyDelicious": simplyDelicious,
  "creamyApricot": creamyApricot,
  "yellYellow": yellYellow,
  "fallGreen": fallGreen,
  "frostedMintHills": frostedMintHills,
  "coastalTrim": coastalTrim,
  "seafairGreen": seafairGreen,
  "crushedIce": crushedIce,
  "iceEffect": iceEffect,
  "arcLight": arcLight,
  "driedLilac": driedLilac,
  "neonBoneyard": neonBoneyard,
  "palenight": palenight,
};

final Map<String, String> lightDarkThemeMapping = {
  "shadeOfViolet": "electricLavender",
  "blissfulBerry": "pinkQuartz",
  "cherryPlum": "cottonCandy",
  "crispChristmasCranberries": "piglet",
  "burntSienna": "simplyDelicious",
  "soilOfAvagddu": "creamyApricot",
  "flagGreen": "yellYellow",
  "tropicana": "fallGreen",
  "toyCamouflage": "frostedMintHills",
  "spreadsheetGreen": "coastalTrim",
  "tokiwaGreen": "seafairGreen",
  "hydraTurquoise": "crushedIce",
  "peacockBlue": "iceEffect",
  "egyptianBlue": "arcLight",
  "bohemianBlue": "driedLilac",
  "spaceBattleBlue": "neonBoneyard",
};

String? reverseThemeMode(String themeName) {
  if (lightThemes.containsKey(themeName)) {
    return lightDarkThemeMapping[themeName];
  } else if (darkThemes.containsKey(themeName)) {
    return lightDarkThemeMapping.entries
        .where((entry) => entry.value == themeName)
        .firstOrNull
        ?.key;
  }

  return null;
}

final Map<String, FlowColorScheme> allThemes = {
  ...lightThemes,
  ...darkThemes,
};

bool validateThemeName(String? themeName) {
  if (themeName == null) return false;

  return allThemes.containsKey(themeName);
}

bool isThemeDark(String? themeName) {
  if (themeName == null) return false;

  return darkThemes.containsKey(themeName);
}

({FlowColorScheme scheme, ThemeMode mode})? getTheme(String? themeName) {
  if (themeName == null) return null;

  final light = lightThemes[themeName];
  if (light != null) return (scheme: light, mode: ThemeMode.light);

  final dark = darkThemes[themeName];
  if (dark != null) return (scheme: dark, mode: ThemeMode.dark);

  log("Unknown theme: $themeName");
  return null;
}
