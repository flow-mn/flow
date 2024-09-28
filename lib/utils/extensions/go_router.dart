// Ongoing issue about lack of `popUntil`
// https://github.com/flutter/flutter/issues/131625
import "package:go_router/go_router.dart";

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
