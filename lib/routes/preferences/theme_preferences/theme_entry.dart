import "package:flow/theme/flow_color_scheme.dart";
import "package:flutter/material.dart";

class ThemeEntry extends StatelessWidget {
  final MapEntry<String, FlowColorScheme> entry;
  final String currentTheme;
  final void Function(String?) handleChange;

  const ThemeEntry({
    super.key,
    required this.entry,
    required this.currentTheme,
    required this.handleChange,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile.adaptive(
      title: Text(entry.value.name),
      value: entry.key,
      groupValue: currentTheme,
      onChanged: handleChange,
      secondary: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          margin: EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: entry.value.colorScheme.secondary,
            borderRadius: BorderRadius.circular(8.0),
          ),
          alignment: Alignment.center,
          child: Text(
            "Aa",
            style: TextStyle(
              color: entry.value.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
