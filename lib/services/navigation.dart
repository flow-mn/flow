import "dart:async";

import "package:app_links/app_links.dart";
import "package:flutter/foundation.dart";
import "package:logging/logging.dart";

final Logger _log = Logger("NavigationService");

class NavigationService {
  static NavigationService? _instance;

  final ValueNotifier<List<String>> _pendingStack = ValueNotifier([]);
  ValueListenable<List<String>> get pendingStack => _pendingStack;

  factory NavigationService() => _instance ??= NavigationService._internal();

  StreamSubscription? _appLinksSubscription;

  NavigationService._internal() {
    if (_appLinksSubscription == null) {
      _appLinksSubscription = AppLinks().uriLinkStream.listen(
        _addRawUriWithDelay,
      );
      _log.info("Listening to app link stream");
    }
  }

  void add(String path) {
    if (_pendingStack.value.contains(path)) {
      _pendingStack.value = [..._pendingStack.value];
      _log.finer("Path already in pending stack, ignoring: $path");
      return;
    }

    _pendingStack.value = [..._pendingStack.value, path];
  }

  void clearPaths() {
    _pendingStack.value = [];
  }

  Future<void> consume(Future<bool> Function(String path) onConsume) async {
    if (_pendingStack.value.isEmpty) {
      _log.finer("No pending navigation paths to consume");
      return;
    }

    final String first = _pendingStack.value.first;
    _pendingStack.value = _pendingStack.value.sublist(1);

    final bool consumed = await onConsume(first).catchError((_) => false);

    if (!consumed) {
      _log.warning("Failed to consume navigation path: $first");
    } else {
      _log.info("Successfully consumed navigation path: $first");
    }
  }

  void _addRawUriWithDelay(Uri? uri) {
    if (uri == null) return;

    _log.info("Received app link URI: $uri");

    if (uri.scheme != "flow-mn") {
      _log.warning("Ignoring non-flow scheme URI: $uri");
      return;
    }

    if (uri.pathSegments.join("/") == "transaction/new") {
      NavigationService().add("/transaction/new?${uri.query}");
      return;
    }

    if (uri.pathSegments.join("/") == "integrate/eny") {
      if (uri.queryParameters["apiKey"] case String candidate
          when candidate.startsWith("eny")) {
        NavigationService().add("/integrate/eny?${uri.query}");
      } else {
        _log.info("Ignoring Eny link with no API key in query: $uri");
      }
      return;
    }
  }
}
