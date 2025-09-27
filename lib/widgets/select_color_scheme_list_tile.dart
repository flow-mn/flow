import "package:flow/l10n/extensions.dart";
import "package:flow/main.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/color_themes/registry.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/flow_theme_group.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/optional.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flow/widgets/sheets/select_color_scheme_sheet.dart";
import "package:flutter/material.dart" hide Flow;
import "package:material_symbols_icons/symbols.dart";

class SelectColorSchemeListTile extends StatefulWidget {
  final bool inferLeading;

  final Widget? leading;
  final String? colorScheme;
  final ValueChanged<FlowColorScheme?> onChanged;

  const SelectColorSchemeListTile({
    super.key,
    this.colorScheme,
    required this.onChanged,
    this.leading,
    this.inferLeading = true,
  });

  @override
  State<SelectColorSchemeListTile> createState() =>
      _SelectColorSchemeListTileState();
}

class _SelectColorSchemeListTileState extends State<SelectColorSchemeListTile> {
  FlowColorScheme? get colorScheme =>
      widget.colorScheme == null ? null : getThemeStrict(widget.colorScheme!);

  @override
  Widget build(BuildContext context) {
    final Widget? leading =
        widget.leading ??
        (widget.inferLeading ? Icon(Symbols.color_lens_rounded) : null);

    return ListTile(
      leading: leading,
      onTap: _selectColor,
      title: Text("select.color".t(context)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8.0,
        children: [
          widget.colorScheme == null
              ? Text(
                  "select.color.none".t(context),
                  style: context.textTheme.labelLarge,
                )
              : AnimatedContainer(
                  width: 20.0,
                  height: 20.0,
                  decoration: BoxDecoration(
                    color: colorScheme!.primary,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  duration: const Duration(milliseconds: 200),
                ),
          DirectionalChevron(),
        ],
      ),
    );
  }

  void _selectColor() async {
    final String themeName = UserPreferencesService().themeName;

    final FlowColorScheme theme = getTheme(
      themeName,
      preferDark: Flow.of(context).useDarkTheme,
    );

    final FlowThemeGroup group = getGroupByTheme(theme.name);

    final Optional<FlowColorScheme>? result =
        await showModalBottomSheet<Optional<FlowColorScheme>>(
          context: context,
          isScrollControlled: true,
          builder: (context) => SelectColorSchemeSheet(
            group: group,
            initialScheme: widget.colorScheme,
          ),
        );

    if (result == null) return;

    widget.onChanged(result.value);
  }
}
