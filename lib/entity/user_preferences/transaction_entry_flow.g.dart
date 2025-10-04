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
);

Map<String, dynamic> _$TransactionEntryFlowToJson(
  TransactionEntryFlow instance,
) => <String, dynamic>{
  'actions': instance.actions
      .map((e) => _$TransactionEntryActionEnumMap[e]!)
      .toList(),
  'abandonUponActionCancelled': instance.abandonUponActionCancelled,
};

const _$TransactionEntryActionEnumMap = {
  TransactionEntryAction.selectAccount: 'selectAccount',
  TransactionEntryAction.selectCategoryOrTransferAccount:
      'selectCategoryOrTransferAccount',
  TransactionEntryAction.inputAmount: 'inputAmount',
  TransactionEntryAction.inputTitle: 'inputTitle',
  TransactionEntryAction.inputNote: 'inputNote',
  TransactionEntryAction.selectTags: 'selectTags',
  TransactionEntryAction.attachFiles: 'attachFiles',
};
