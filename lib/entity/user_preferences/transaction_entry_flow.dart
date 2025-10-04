import "dart:convert";

import "package:flow/l10n/named_enum.dart";
import "package:json_annotation/json_annotation.dart";

part "transaction_entry_flow.g.dart";

@JsonValue("value")
enum TransactionEntryAction with LocalizedEnum {
  selectAccount("selectAccount"),
  selectCategoryOrTransferAccount("selectCategoryOrTransferAccount"),
  inputAmount("inputAmount"),
  inputTitle("inputTitle"),
  inputNote("inputNote"),
  selectTags("selectTags"),
  attachFiles("attachFiles");

  final String value;
  const TransactionEntryAction(this.value);

  @override
  String get localizationEnumName => "TransactionEntryAction";

  @override
  String get localizationEnumValue => value;
}

@JsonSerializable()
class TransactionEntryFlow {
  final List<TransactionEntryAction> actions;
  final bool abandonUponActionCancelled;

  const TransactionEntryFlow({
    required this.actions,
    this.abandonUponActionCancelled = true,
  });

  const TransactionEntryFlow.defaults()
    : actions = const [
        TransactionEntryAction.selectAccount,
        TransactionEntryAction.selectCategoryOrTransferAccount,
        TransactionEntryAction.inputAmount,
        TransactionEntryAction.inputTitle,
      ],
      abandonUponActionCancelled = true;

  factory TransactionEntryFlow.fromJson(Map<String, dynamic> json) =>
      _$TransactionEntryFlowFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionEntryFlowToJson(this);

  /// Will return the defaults if deserialization fails
  static TransactionEntryFlow deserialize(String? jsonString) {
    try {
      if (jsonString == null) {
        throw StateError("jsonString is null");
      }

      return TransactionEntryFlow.fromJson(jsonDecode(jsonString));
    } catch (_) {
      return const TransactionEntryFlow.defaults();
    }
  }

  String serialize() => jsonEncode(toJson());
}
