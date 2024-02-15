import 'package:flow/entity/transaction/extensions/base.dart';
import 'package:flow/utils/jsonable.dart';
import 'package:json_annotation/json_annotation.dart';

part "transfer.g.dart";

@JsonSerializable()
class Transfer extends TransactionExtension implements Jasonable {
  static const String keyName = "@flow/default-transfer";

  final String fromAccountUuid;
  final String toAccountUuid;

  const Transfer({
    required this.fromAccountUuid,
    required this.toAccountUuid,
  }) : super(Transfer.keyName);

  factory Transfer.fromJson(Map<String, dynamic> json) =>
      _$TransferTxnFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TransferTxnToJson(this);
}
