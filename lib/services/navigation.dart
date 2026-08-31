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

    final String path = uri.pathSegments.join("/");

    if (path == "transaction/new") {
      NavigationService().add("/transaction/new?${uri.query}");
      return;
    }

    if (path == "integrate/eny") {
      if (uri.queryParameters["apiKey"] case String candidate
          when candidate.startsWith("eny")) {
        NavigationService().add("/integrate/eny?${uri.query}");
      } else {
        _log.info("Ignoring Eny link with no API key in query: $uri");
      }
      return;
    }

    // Budget home-screen widgets: the rollup opens the overview it mirrors,
    // the pinned one opens the budget it is showing.
    if (path == "budgets" || path == "stats/budgets") {
      NavigationService().add("/$path");
      return;
    }

    final List<String> segments = uri.pathSegments;
    if (segments.length == 2 &&
        segments.first == "budgets" &&
        int.tryParse(segments[1]) != null) {
      // An id that no longer resolves — restored backup, deleted budget — is
      // sent to the list by the router's `_budgetExistsOrList` redirect rather
      // than landing on a dead page.
      NavigationService().add("/budgets/${segments[1]}");
      return;
    }

    // Deliberately an allowlist, not a catch-all forward: a custom URL scheme
    // is claimable by anything on the device, so an arbitrary path from one
    // would be an open redirect into any route in the app.
    _log.warning("No route matches app link URI: $uri");
  }
}
