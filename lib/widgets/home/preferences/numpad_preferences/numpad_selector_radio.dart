import "package:flow/l10n/flow_localizations.dart";
import "package:flow/utils/extensions/directionality.dart";
import "package:flow/widgets/numpad.dart";
import "package:flutter/material.dart";

class NumpadSelectorRadio extends StatelessWidget {
  final VoidCallback onTap;

  final bool isPhoneLayout;
  final bool currentlyUsingPhoneLayout;

  const NumpadSelectorRadio.classic({
    super.key,
    required this.onTap,
    required this.currentlyUsingPhoneLayout,
  }) : isPhoneLayout = false;
  const NumpadSelectorRadio.phone({
    super.key,
    required this.onTap,
    required this.currentlyUsingPhoneLayout,
  }) : isPhoneLayout = true;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Numpad(
                  width: constraints.maxWidth,
                  mainAxisSpacing: 3.0,
                  crossAxisSpacing: 3.0,
                  children:
                      isPhoneLayout
                          ? buildPhoneNumpad(context)
                          : buildClassicNumpad(context),
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isPhoneLayout
                          ? "preferences.numpad.layout.modern".t(context)
                          : "preferences.numpad.layout.classic".t(context),
                    ),
                    const SizedBox(height: 8.0),
                    IgnorePointer(
                      child: Radio(
                        value: isPhoneLayout,
                        groupValue: currentlyUsingPhoneLayout,
                        onChanged: (_) {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Classic, used in calculators
  ///
  /// 7 8 9
  /// 4 5 6
  /// 1 2 3
  ///   0
  List<Widget> buildClassicNumpad(BuildContext context) {
    final String template =
        context.isLtr ? "789 456 123 0  " : "987 654 321  0 ";

    return template.characters
        .map(
          (char) => NumpadButton(
            crossAxisCellCount: char == "0" ? 2 : 1,
            borderRadiusSize: 6.0,
            child: Text(char),
          ),
        )
        .toList();
  }

  /// Modern, as in used in phones.
  ///
  /// 1 2 3
  /// 4 5 6
  /// 7 8 9
  ///   0
  List<Widget> buildPhoneNumpad(BuildContext context) {
    final String template =
        context.isLtr ? "123 456 789 0  " : "321 654 987  0 ";

    return template.characters
        .map(
          (char) => NumpadButton(
            crossAxisCellCount: char == "0" ? 2 : 1,
            borderRadiusSize: 6.0,
            child: Text(char),
          ),
        )
        .toList();
  }
}
