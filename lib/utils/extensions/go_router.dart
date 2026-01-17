// Ongoing issue about lack of `popUntil`
// https://github.com/flutter/flutter/issues/131625
import "package:flutter/widgets.dart";
import "package:go_router/go_router.dart";
import "package:logging/logging.dart";

final Logger _log = Logger("GoRouterExt");

extension GoRouterExt on GoRouter {
  void popUntil(bool Function(GoRoute) predicate) {
    List routeStacks = [...routerDelegate.currentConfiguration.routes];

    for (int i = routeStacks.length - 1; i >= 0; i--) {
      RouteBase route = routeStacks[i];
      if (route is GoRoute) {
        if (predicate(route)) break;
        if (i != 0 && routeStacks[i - 1] is ShellRoute) {
          RouteMatchList matchList = routerDelegate.currentConfiguration;
          restore(matchList.remove(matchList.matches.last));
        } else {
          pop();
        }
      }
    }
  }
}

extension GoRouterContextExt on BuildContext {
  String get location {
    final GoRouter router = GoRouter.of(this);

    final RouteMatch lastMatch =
        router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : router.routerDelegate.currentConfiguration;
    final String location = matchList.uri.toString();
    return location;
  }

  void safePush(String path) {
    try {
      if (location != path) {
        push(path);
      } else {
        _log.fine("Not navigating to the same path: $path");
      }
    } catch (e) {
      push(path);
    }
  }
}
