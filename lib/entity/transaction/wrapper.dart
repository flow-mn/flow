import "dart:convert";

import "package:flow/entity/transaction/extensions/base.dart";
import "package:flow/entity/transaction/extensions/default/geo.dart";
import "package:flow/entity/transaction/extensions/default/recurring.dart";
import "package:flow/entity/transaction/extensions/default/transfer.dart";
import "package:flow/utils/utils.dart";
import "package:logging/logging.dart";

final Logger _log = Logger("ExtensionsWrapper");

typedef TransactionExtensionReviver =
    TransactionExtension Function(Map<String, dynamic>);

class ExtensionsWrapper {
  static final Map<String, TransactionExtensionReviver> _registrar = {
    Transfer.keyName: (json) => Transfer.fromJson(json),
    Geo.keyName: (json) => Geo.fromJson(json),
    Recurring.keyName: (json) => Recurring.fromJson(json),
  };

  static void register<T extends TransactionExtension>(
    String key,
    TransactionExtensionReviver fromJson,
  ) {
    _registrar[key] = fromJson;
    _log.info("Registered extension $key => $T");
  }

  Transfer? get transfer =>
      data.firstWhereOrNull((element) => element is Transfer) as Transfer?;
  set transfer(Transfer? newTransfer) =>
      _overrideSingle(transfer, Transfer.keyName);

  Geo? get geo => data.firstWhereOrNull((element) => element is Geo) as Geo?;
  set geo(Geo? newGeo) => _overrideSingle(newGeo, Geo.keyName);

  Recurring? get recurring =>
      data.firstWhereOrNull((element) => element is Recurring) as Recurring?;
  set recurring(Recurring? newRecurring) =>
      _overrideSingle(newRecurring, Recurring.keyName);

  final List<TransactionExtension> data;

  const ExtensionsWrapper(this.data);
  const ExtensionsWrapper.empty() : data = const [];

  ExtensionsWrapper clone() => ExtensionsWrapper([...data]);

  /// Returns a new instance with merged
  ExtensionsWrapper getMerged(List<TransactionExtension> newData) {
    return ExtensionsWrapper([
      ...data.where(
        (currrent) => !newData.any((newExt) => currrent.key == newExt.key),
      ),
      ...newData,
    ]);
  }

  /// Returns a new instance with overridden
  ExtensionsWrapper getOverriden(TransactionExtension? newData, String key) {
    return clone().._overrideSingle(newData, key);
  }

  void _remove(String key) {
    data.removeWhere((element) => element.key == key);
  }

  void _overrideSingle(TransactionExtension? newSingle, String key) {
    _remove(key);
    if (newSingle != null) {
      data.add(newSingle);
    }
  }

  static ExtensionsWrapper parse(String? extra) {
    if (extra == null) return const ExtensionsWrapper.empty();

    try {
      return ExtensionsWrapper(
        (jsonDecode(extra) as List<dynamic>)
            .map((item) => _deserializeSingle(item as Map<String, dynamic>))
            .nonNulls
            .toList(),
      );
    } catch (e) {
      _log.warning("An error occured during deserializing: $e");
      return const ExtensionsWrapper.empty();
    }
  }

  List<Map<String, dynamic>> toJson() {
    return data.map((e) => e.toJson()).toList();
  }

  String? serialize() {
    if (data.isEmpty) return null;

    try {
      return jsonEncode(toJson());
    } catch (e) {
      return null;
    }
  }

  static T? _deserializeSingle<T extends TransactionExtension>(
    Map<String, dynamic> value,
  ) {
    return _registrar[value["key"]]?.call(value) as T?;
  }
}
