import "dart:async";
import "dart:developer";

import "package:flow/data/flow_button_type.dart";
import "package:flow/data/flow_notification_payload.dart";
import "package:flow/entity/account.dart";
import "package:flow/objectbox.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/routes.dart";
import "package:flow/routes/home/accounts_tab.dart";
import "package:flow/routes/home/home_tab.dart";
import "package:flow/routes/home/profile_tab.dart";
import "package:flow/routes/home/stats_tab.dart";
import "package:flow/services/navigation.dart";
import "package:flow/services/notifications.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/shortcut.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/home/navbar.dart";
import "package:flow/widgets/home/navbar/new_transaction_button.dart";
import "package:flutter/material.dart" hide Flow;
import "package:flutter/scheduler.dart";
import "package:flutter/services.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:go_router/go_router.dart";
import "package:pie_menu/pie_menu.dart";

class HomePage extends StatefulWidget {
  static bool initialized = false;

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final ScrollController _homeTabScrollController = ScrollController();

  late int _currentIndex;

  bool _navigationListenerRegistered = false;

  @override
  void initState() {
    super.initState();

    _currentIndex = 0;
    _tabController = TabController(
      vsync: this,
      length: 4,
      initialIndex: _currentIndex,
    );

    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });

    Future.delayed(const Duration(milliseconds: 250)).then((_) {
      if (!mounted) return;

      NavigationService().pendingStack.addListener(
        _consumeNextPendingNavigation,
      );
      _navigationListenerRegistered = true;

      if (LocalPreferences().completedInitialSetup.get()) return;

      context.pushReplacement("/setup");

      unawaited(
        LocalPreferences().completedInitialSetup.set(true).catchError((error) {
          log(
            "Failed to set LocalPreferences().completedInitialSetup -> true",
            error: error,
          );
          return false;
        }),
      );
    });

    if (!HomePage.initialized) {
      HomePage.initialized = true;

      try {
        if (NotificationsService().ready &&
            NotificationsService().notificationAppLaunchDetails != null) {
          _pushNotificationPath(
            NotificationsService()
                .notificationAppLaunchDetails!
                .notificationResponse!,
          );
        }
      } catch (e) {
        log(
          "[Flow Startup] Failed to get notificationAppLaunchDetails",
          error: e,
        );
      }
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      NotificationsService().addCallback(_pushNotificationPath);
      _consumeNextPendingNavigation();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    if (_navigationListenerRegistered) {
      NavigationService().pendingStack.removeListener(
        _consumeNextPendingNavigation,
      );
    }
    NotificationsService().removeCallback(_pushNotificationPath);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        osSingleActivator(LogicalKeyboardKey.keyN): () =>
            _newTransactionPage(null),
        osSingleActivator(LogicalKeyboardKey.digit1): () => _navigateTo(0),
        osSingleActivator(LogicalKeyboardKey.digit2): () => _navigateTo(1),
        osSingleActivator(LogicalKeyboardKey.digit3): () => _navigateTo(2),
        osSingleActivator(LogicalKeyboardKey.digit4): () => _navigateTo(3),
      },
      child: Focus(
        autofocus: true,
        child: PieCanvas(
          theme: context.pieTheme,
          child: Stack(
            children: [
              Scaffold(
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    HomeTab(scrollController: _homeTabScrollController),
                    const StatsTab(),
                    const SafeArea(child: AccountsTab()),
                    const SafeArea(child: ProfileTab()),
                  ],
                ),
              ),
              Positioned(
                bottom: 16.0,
                left: 0.0,
                right: 0.0,
                child: SafeArea(
                  child: Frame(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Navbar(
                          onTap: (i) => _navigateTo(i),
                          activeIndex: _currentIndex,
                        ),
                        NewTransactionButton(
                          onActionTap: (type) => _newTransactionPage(type),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(int index) {
    if (index == _tabController.index) {
      if (index == 0 && _homeTabScrollController.hasClients) {
        _homeTabScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
      return;
    }

    _tabController.animateTo(index);
  }

  void _newTransactionPage(FlowButtonType? type) {
    // Generally, this wouldn't happen in production environment
    if (ObjectBox().box<Account>().count(limit: 1) == 0) {
      context.push("/account/new");
      return;
    }

    type ??= FlowButtonType.expense;

    context.push("/transaction/new?type=${type.value}");
  }

  void _pushNotificationPath(NotificationResponse response) {
    try {
      if (response.payload == null || response.payload == "") {
        NavigationService().add("/accounts");
        return;
        // throw "Payload is null";
      }

      final FlowNotificationPayload parsed = FlowNotificationPayload.parse(
        response.payload!,
      );

      switch (parsed.itemType) {
        case FlowNotificationPayloadItemType.transaction:
          NavigationService().add("/transaction/${parsed.id}");
          return;
        case FlowNotificationPayloadItemType.reminder:
          return;
      }
    } catch (e) {
      log("Failed to push notification path", error: e);
    }
  }

  void _consumeNextPendingNavigation() async {
    await NavigationService().consume(_consumePendingNavigation);
  }

  Future<bool> _consumePendingNavigation(String path) async {
    try {
      final BuildContext? globalNavigatorContext =
          globalNavigatorKey.currentState?.context;
      if (globalNavigatorContext == null) {
        throw "Global navigator context is null";
      }

      final goRouter = GoRouter.maybeOf(globalNavigatorContext);
      if (goRouter == null) {
        throw "GoRouter is null";
      }

      await goRouter.push(path);

      return true;
    } catch (e) {
      return false;
    }
  }
}
