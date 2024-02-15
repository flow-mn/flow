import 'package:flow/entity/transaction/extensions/base.dart';
import 'package:flow/entity/transaction/extensions/default/transfer.dart';

Map<String, dynamic> serialize<T>(String key, T value) {
  return switch (key) {
    Transfer.keyName => (value as Transfer).toJson(),
    _ => throw UnimplementedError(),
  };
}

T? deserialize<T extends TransactionExtension>(Map<String, dynamic> value) {
  return switch (value["key"]) {
    Transfer.keyName => Transfer.fromJson(value) as T,
    _ => null,
  };
}
