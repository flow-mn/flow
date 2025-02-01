import "dart:developer";
import "dart:io";

import "package:flow/theme/color_themes/default_darks.dart";
import "package:flow/theme/color_themes/default_lights.dart";
import "package:flow/theme/color_themes/default_oleds.dart";
import "package:flow/theme/color_themes/palenight.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flutter_dynamic_icon_plus/flutter_dynamic_icon_plus.dart";

export "default_darks.dart";
export "default_lights.dart";
export "default_oleds.dart";
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
};

final Map<String, FlowColorScheme> oledThemes = {
  "electricLavenderOled": electricLavenderOled,
  "pinkQuartzOled": pinkQuartzOled,
  "cottonCandyOled": cottonCandyOled,
  "pigletOled": pigletOled,
  "simplyDeliciousOled": simplyDeliciousOled,
  "creamyApricotOled": creamyApricotOled,
  "yellYellowOled": yellYellowOled,
  "fallGreenOled": fallGreenOled,
  "frostedMintHillsOled": frostedMintHillsOled,
  "coastalTrimOled": coastalTrimOled,
  "seafairGreenOled": seafairGreenOled,
  "crushedIceOled": crushedIceOled,
  "iceEffectOled": iceEffectOled,
  "arcLightOled": arcLightOled,
  "driedLilacOled": driedLilacOled,
  "neonBoneyardOled": neonBoneyardOled,
};

final Map<String, FlowColorScheme> otherThemes = {
  "palenight": palenight,
};

typedef ThemePetal = ({String light, String dark, String oled});

final List<ThemePetal> themePetalMapping = [
  (
    light: "shadeOfViolet",
    dark: "electricLavender",
    oled: "electricLavenderOled",
  ),
  (
    light: "blissfulBerry",
    dark: "pinkQuartz",
    oled: "pinkQuartzOled",
  ),
  (
    light: "cherryPlum",
    dark: "cottonCandy",
    oled: "cottonCandyOled",
  ),
  (
    light: "crispChristmasCranberries",
    dark: "piglet",
    oled: "pigletOled",
  ),
  (
    light: "burntSienna",
    dark: "simplyDelicious",
    oled: "simplyDeliciousOled",
  ),
  (
    light: "soilOfAvagddu",
    dark: "creamyApricot",
    oled: "creamyApricotOled",
  ),
  (
    light: "flagGreen",
    dark: "yellYellow",
    oled: "yellYellowOled",
  ),
  (
    light: "tropicana",
    dark: "fallGreen",
    oled: "fallGreenOled",
  ),
  (
    light: "toyCamouflage",
    dark: "frostedMintHills",
    oled: "frostedMintHillsOled",
  ),
  (
    light: "spreadsheetGreen",
    dark: "coastalTrim",
    oled: "coastalTrimOled",
  ),
  (
    light: "tokiwaGreen",
    dark: "seafairGreen",
    oled: "seafairGreenOled",
  ),
  (
    light: "hydraTurquoise",
    dark: "crushedIce",
    oled: "crushedIceOled",
  ),
  (
    light: "peacockBlue",
    dark: "iceEffect",
    oled: "iceEffectOled",
  ),
  (
    light: "egyptianBlue",
    dark: "arcLight",
    oled: "arcLightOled",
  ),
  (
    light: "bohemianBlue",
    dark: "driedLilac",
    oled: "driedLilacOled",
  ),
  (
    light: "spaceBattleBlue",
    dark: "neonBoneyard",
    oled: "neonBoneyardOled",
  ),
];

(ThemePetal?, int?) getThemePetal(String? themeName) {
  if (themeName == null) return (null, null);

  try {
    final int index = themePetalMapping.indexWhere(
      (petal) =>
          petal.light == themeName ||
          petal.dark == themeName ||
          petal.oled == themeName,
    );

    if (index < 0) throw StateError("Theme not found");

    return (themePetalMapping[index], index);
  } catch (e) {
    return (null, null);
  }
}

final Map<String, FlowColorScheme> allThemes = {
  ...lightThemes,
  ...darkThemes,
  ...oledThemes,
  ...otherThemes,
};

bool validateThemeName(String? themeName) {
  if (themeName == null) return false;

  return allThemes.containsKey(themeName);
}

FlowColorScheme getTheme(
  String? themeName, {
  bool preferDark = false,
  bool preferOled = false,
}) {
  if (themeName == null) return preferDark ? electricLavender : shadeOfViolet;

  final FlowColorScheme? scheme = allThemes[themeName];

  if (scheme == null) {
    log("Unknown theme: $themeName");
    return preferDark ? electricLavender : shadeOfViolet;
  }

  return scheme;
}

void trySetThemeIcon(String? name) async {
  name ??= "shadeOfViolet";

  if (!Platform.isIOS) return;

  final String? currentIcon = await FlutterDynamicIconPlus.alternateIconName;

  final (ThemePetal? petal, _) = getThemePetal(name);
  final String icon = petal?.light ?? "shadeOfViolet";

  if (currentIcon != null && currentIcon == icon) {
    log("Cancelling changing app icon into $icon since it's the current one already");
    return;
  }

  try {
    await FlutterDynamicIconPlus.setAlternateIconName(iconName: icon);
  } catch (e) {
    log("Failed to set app icon: $e");
  }
}
