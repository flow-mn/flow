// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_entry_flow.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionEntryFlow _$TransactionEntryFlowFromJson(
  Map<String, dynamic> json,
) => TransactionEntryFlow(
  actions: (json['actions'] as List<dynamic>)
      .map((e) => $enumDecode(_$TransactionEntryActionEnumMap, e))
      .toList(),
  abandonUponActionCancelled:
      json['abandonUponActionCancelled'] as bool? ?? true,
  skipSelectedFields: json['skipSelectedFields'] as bool? ?? true,
);

Map<String, dynamic> _$TransactionEntryFlowToJson(
  TransactionEntryFlow instance,
) => <String, dynamic>{
  'actions': instance.actions
      .map((e) => _$TransactionEntryActionEnumMap[e]!)
      .toList(),
  'abandonUponActionCancelled': instance.abandonUponActionCancelled,
  'skipSelectedFields': instance.skipSelectedFields,
};

const _$TransactionEntryActionEnumMap = {
  TransactionEntryAction.selectAccount: 'selectAccount',
  TransactionEntryAction.selectPrimaryAccount: 'selectPrimaryAccount',
  TransactionEntryAction.selectCategoryOrTransferAccount:
      'selectCategoryOrTransferAccount',
  TransactionEntryAction.inputAmount: 'inputAmount',
  TransactionEntryAction.inputTitle: 'inputTitle',
  TransactionEntryAction.selectTags: 'selectTags',
  TransactionEntryAction.attachFiles: 'attachFiles',
};
