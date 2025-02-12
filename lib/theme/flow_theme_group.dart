import "package:flow/data/flow_icon.dart";
import "package:flow/theme/flow_color_scheme.dart";

class FlowThemeGroup {
  final String name;
  final FlowIconData? icon;

  final List<FlowColorScheme> schemes;

  const FlowThemeGroup({
    required this.schemes,
    required this.name,
    this.icon,
  });

  Map<String, FlowColorScheme> get schemesMap {
    final Map<String, FlowColorScheme> map = {};

    for (final FlowColorScheme scheme in schemes) {
      map[scheme.name] = scheme;
    }

    return map;
  }
}
