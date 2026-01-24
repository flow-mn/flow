import "dart:async";

import "package:logging/logging.dart";
import "package:toastification/toastification.dart";

final Logger _log = Logger("ExternalToastsService");

class ExternalToastsService {
  static ExternalToastsService? _instance;

  late final StreamController<(String, ToastificationType)>
  _toastStreamController =
      StreamController<(String, ToastificationType)>.broadcast();

  factory ExternalToastsService() =>
      _instance ??= ExternalToastsService._internal();

  ExternalToastsService._internal();

  Stream<(String, ToastificationType)> get toastStream =>
      _toastStreamController.stream;

  void addToast(String message, ToastificationType type) {
    _log.fine("Adding external toast: $message, type: $type");
    _toastStreamController.add((message, type));
  }

  void dispose() {
    _toastStreamController.close();
  }
}
