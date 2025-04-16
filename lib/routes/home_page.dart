import "dart:async";
import "dart:developer";

import "package:flow/data/flow_notification_payload.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/routes/home/accounts_tab.dart";
import "package:flow/routes/home/home_tab.dart";
import "package:flow/routes/home/profile_tab.dart";
import "package:flow/routes/home/stats_tab.dart";
import "package:flow/services/notifications.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/shortcut.dart";
import "package:flow/widgets/home/navbar.dart";
import "package:flow/widgets/home/navbar/new_transaction_button.dart";
import "package:flutter/material.dart" hide Flow;
import "package:flutter/scheduler.dart";
import "package:flutter/services.dart";
import "package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart";
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

    Future.delayed(const Duration(milliseconds: 200)).then((_) {
      if (!mounted) return;

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
          final NotificationResponse? response =
              NotificationsService()
                  .notificationAppLaunchDetails!
                  .notificationResponse;

          if (response == null || response.payload == null) {
            throw "No notification payload";
          }

          final FlowNotificationPayload parsed = FlowNotificationPayload.parse(
            response.payload!,
          );

          switch (parsed.itemType) {
            case FlowNotificationPayloadItemType.transaction:
              SchedulerBinding.instance.addPostFrameCallback((_) {
                context.push("/transaction/${parsed.id}");
              });
              return;
            case FlowNotificationPayloadItemType.reminder:
              return;
          }
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
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    NotificationsService().removeCallback(_pushNotificationPath);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        osSingleActivator(LogicalKeyboardKey.keyN):
            () => _newTransactionPage(null),
        osSingleActivator(LogicalKeyboardKey.digit1): () => _navigateTo(0),
        osSingleActivator(LogicalKeyboardKey.digit2): () => _navigateTo(1),
        osSingleActivator(LogicalKeyboardKey.digit3): () => _navigateTo(2),
        osSingleActivator(LogicalKeyboardKey.digit4): () => _navigateTo(3),
      },
      child: Focus(
        autofocus: true,
        child: PieCanvas(
          theme: context.pieTheme,
          child: BottomBar(
            width: double.infinity,
            offset: 16.0,
            barColor: const Color.fromARGB(0, 86, 75, 75),
            borderRadius: BorderRadius.circular(32.0),
            body:
                (context, scrollControler) => Scaffold(
                  body: SafeArea(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        HomeTab(scrollController: _homeTabScrollController),
                        const StatsTab(),
                        const AccountsTab(),
                        const ProfileTab(),
                      ],
                    ),
                  ),
                ),
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

  void _newTransactionPage(TransactionType? type) {
    // Generally, this wouldn't happen in production environment
    if (ObjectBox().box<Account>().count(limit: 1) == 0) {
      context.push("/account/new");
      return;
    }

    type ??= TransactionType.expense;

    context.push("/transaction/new?type=${type.value}");
  }

  void _pushNotificationPath(NotificationResponse response) {
    try {
      if (response.payload == null) throw "Payload is null";

      final FlowNotificationPayload parsed = FlowNotificationPayload.parse(
        response.payload!,
      );

      switch (parsed.itemType) {
        case FlowNotificationPayloadItemType.transaction:
          context.push("/transaction/${parsed.id}");
          return;
        case FlowNotificationPayloadItemType.reminder:
          return;
      }
    } catch (e) {
      log("Failed to push notification path", error: e);
    }
  }
}
