import "package:flow/l10n/named_enum.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:json_annotation/json_annotation.dart";

@JsonEnum(valueField: "value")
enum RecurringUpdateMode implements LocalizedEnum {
  /// Update the transaction
  current("current"),

  /// Update the transaction and all future transactions
  all("all"),

  /// Update the transaction and all future transactions, but not the past ones
  thisAndFuture("thisAndFuture");

  final String value;
  const RecurringUpdateMode(this.value);

  @override
  String get localizationEnumName => "RecurringUpdateMode";

  @override
  String get localizationEnumValue => value;
}

class SelectRecurringUpdateModeSheet extends StatelessWidget {
  final Widget? title;
  final RecurringUpdateMode? current;
  final bool showTrailing;

  const SelectRecurringUpdateModeSheet({
    super.key,
    this.title,
    this.current,
    this.showTrailing = true,
  });

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: title,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...RecurringUpdateMode.values.map(
              (mode) => ListTile(
                key: ValueKey(mode),
                title: Text(mode.localizedNameContext(context)),
                onTap: () => context.pop(mode),
                trailing: showTrailing ? DirectionalChevron() : null,
                selected: current == mode,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
