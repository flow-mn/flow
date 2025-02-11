import "dart:developer";
import "dart:io";

import "package:flow/theme/color_themes/catppuccin/frappe.dart";
import "package:flow/theme/color_themes/catppuccin/latte.dart";
import "package:flow/theme/color_themes/catppuccin/macchiato.dart";
import "package:flow/theme/color_themes/catppuccin/mocha.dart";
import "package:flow/theme/color_themes/flow/flow_darks.dart";
import "package:flow/theme/color_themes/flow/flow_lights.dart";
import "package:flow/theme/color_themes/flow/flow_oleds.dart";
import "package:flow/theme/color_themes/palenight.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/flow_theme_group.dart";
import "package:flutter_dynamic_icon_plus/flutter_dynamic_icon_plus.dart";

export "catppuccin/frappe.dart";
export "catppuccin/latte.dart";
export "catppuccin/macchiato.dart";
export "catppuccin/mocha.dart";
export "flow/flow_darks.dart";
export "flow/flow_lights.dart";
export "flow/flow_oleds.dart";
export "palenight.dart";

final Map<String, FlowColorScheme> standaloneThemes = {
  "palenight": palenight,
};

final Map<String, List<FlowThemeGroup>> groups = {
  "Flow": [
    flowLights,
    flowDarks,
    flowOleds,
  ],
  "Catppuccin": [
    catppuccinLatte,
    catppuccinFrappe,
    catppuccinMacchiato,
    catppuccinMocha,
  ],
};

final Map<String, FlowColorScheme> allThemes = {
  ...groups.values.fold(<String, FlowColorScheme>{}, (
    Map<String, FlowColorScheme> acc,
    List<FlowThemeGroup> groups,
  ) {
    for (final FlowThemeGroup group in groups) {
      acc.addAll(group.schemesMap);
    }

    return acc;
  }),
  ...standaloneThemes,
};

bool validateThemeName(String? themeName) {
  if (themeName == null) return false;

  return allThemes.containsKey(themeName);
}

FlowColorScheme getTheme(
  String? themeName, {
  bool preferDark = false,
}) {
  final FlowColorScheme? scheme = allThemes[themeName ?? ""];

  if (scheme == null) {
    log("Unknown theme: $themeName");
    return preferDark ? flowDarks.schemes.first : flowDarks.schemes.first;
  }

  return scheme;
}

/// Exclusive to iOS
void trySetAppIcon(String? iconName) async {
  if (!Platform.isIOS) return;

  iconName ??= "shadeOfViolet";

  final String? currentIcon = await FlutterDynamicIconPlus.alternateIconName;

  if (currentIcon != null && currentIcon == iconName) {
    log("Cancelling changing app icon into $iconName since it's the current one already");
    return;
  }

  try {
    await FlutterDynamicIconPlus.setAlternateIconName(iconName: iconName);
  } catch (e) {
    log("Failed to set app icon: $e");
  }
}
