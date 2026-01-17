import "package:flow/l10n/named_enum.dart";
import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";
import "package:json_annotation/json_annotation.dart";
import "package:material_symbols_icons/symbols.dart";

@JsonEnum(valueField: "value")
enum FlowButtonType with LocalizedEnum {
  transfer("transfer"),
  income("income"),
  expense("expense"),
  eny("eny");

  final String value;

  const FlowButtonType(this.value);

  @override
  String get localizationEnumValue => name;
  @override
  String get localizationEnumName => "FlowButtonType";

  static const List<FlowButtonType> defaultOrder = [
    FlowButtonType.transfer,
    FlowButtonType.income,
    FlowButtonType.expense,
  ];

  IconData get icon {
    return switch (this) {
      .income => Symbols.stat_minus_2_rounded,
      .expense => Symbols.stat_2_rounded,
      .transfer => Symbols.compare_arrows_rounded,
      .eny => Symbols.camera_alt_rounded,
    };
  }

  Color actionColor(BuildContext context) => switch (this) {
    .income => context.colorScheme.onError,
    .expense => context.colorScheme.onError,
    .transfer || .eny => context.colorScheme.onSecondary,
  };

  Color actionBackgroundColor(BuildContext context) => switch (this) {
    .income => context.flowColors.income,
    .expense => context.flowColors.expense,
    .transfer || .eny => context.colorScheme.secondary,
  };
}
