import "package:flow/l10n/named_enum.dart";

enum GroupSortMode with LocalizedEnum {
  amount,
  alphabetical;

  GroupSortMode get next =>
      GroupSortMode.values[(index + 1) % GroupSortMode.values.length];

  @override
  String get localizationEnumName => "GroupSortMode";

  @override
  String get localizationEnumValue => name;
}
