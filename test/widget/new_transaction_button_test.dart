import "dart:async";

import "package:flow/data/flow_button_type.dart";
import "package:flow/entity/user_preferences.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/prefs/eny_preferences.dart";
import "package:flow/services/integrations/eny.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/color_themes/registry.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/home/navbar.dart";
import "package:flow/widgets/home/navbar/new_transaction_button.dart";
import "package:flutter/foundation.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter/semantics.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";
import "package:logging/logging.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:pie_menu/pie_menu.dart";
import "package:shared_preferences/shared_preferences.dart";

/// Guards for the central + button on the home navbar.
///
/// [PieMenu] renders the button but drops its radial menu under accessible
/// navigation, and treats `pointerSize / 2` as the movement allowed before a
/// release closes the menu. Both left the button looking fine while doing
/// nothing, so these tests drive real pointers and semantics actions.
///
/// [PieMenu] keeps action widgets mounted after the menu closes, so finding an
/// action icon doesn't prove the menu is open. Check `onMenuToggle` instead.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await FlowLocalizations(const Locale("en")).load();
    EnyLocalPreferences.initialize(_MemoryPreferences());
  });

  List<LogRecord> captureLogs() {
    final List<LogRecord> records = [];
    final Level previousLevel = Logger.root.level;

    Logger.root.level = Level.ALL;
    final StreamSubscription<LogRecord> subscription = Logger.root.onRecord
        .where((record) => record.loggerName == "NewTransactionButton")
        .listen(records.add);

    addTearDown(() async {
      await subscription.cancel();
      Logger.root.level = previousLevel;
    });

    return records;
  }

  testWidgets("accessible navigation can select a transaction type", (
    tester,
  ) async {
    final List<FlowButtonType> selected = [];
    await tester.pumpWidget(
      _testApp(accessibleNavigation: true, onActionTap: selected.add),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Symbols.add_rounded));
    await tester.pumpAndSettle();

    expect(find.text("Expense"), findsOneWidget);
    expect(find.text("Income"), findsOneWidget);
    expect(find.text("Transfer"), findsOneWidget);
    expect(find.text("Eny"), findsNothing);

    await tester.tap(find.text("Income"));
    await tester.pumpAndSettle();

    expect(selected, [FlowButtonType.income]);
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets("diagnostics detect touches excluded from the button hit test", (
    tester,
  ) async {
    final List<LogRecord> records = captureLogs();
    await tester.pumpWidget(
      _testApp(
        accessibleNavigation: false,
        onActionTap: (_) {},
        ignoreTransactionButton: true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tapAt(tester.getCenter(find.byType(NewTransactionButton)));
    await tester.pumpAndSettle();

    expect(
      records.any(
        (record) => record.message.contains("missed the button hit test"),
      ),
      isTrue,
    );
    expect(
      records.any((record) => record.message.contains("PointerDownEvent:")),
      isFalse,
    );
  });

  testWidgets("diagnostics do not report working taps as missed hits", (
    tester,
  ) async {
    final List<LogRecord> records = captureLogs();
    await tester.pumpWidget(
      _testApp(accessibleNavigation: false, onActionTap: (_) {}),
    );
    await tester.pumpAndSettle();

    await tester.tapAt(tester.getCenter(find.byType(NewTransactionButton)));
    await tester.pumpAndSettle();

    expect(
      records.any((record) => record.message.contains("PointerDownEvent:")),
      isTrue,
    );
    expect(records.any((record) => record.level >= Level.WARNING), isFalse);
  });

  testWidgets("screen-reader activation opens the transaction picker", (
    tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    final List<FlowButtonType> selected = [];
    await tester.pumpWidget(
      _testApp(accessibleNavigation: true, onActionTap: selected.add),
    );
    await tester.pumpAndSettle();

    final SemanticsNode node = tester.getSemantics(
      find.bySemanticsLabel("New transaction"),
    );
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);

    node.owner!.performAction(node.id, SemanticsAction.tap);
    await tester.pumpAndSettle();
    expect(find.text("Expense"), findsOneWidget);

    await tester.tap(find.text("Expense"));
    await tester.pumpAndSettle();
    expect(selected, [FlowButtonType.expense]);

    semantics.dispose();
  });

  testWidgets("cancel creates nothing and the picker can reopen", (
    tester,
  ) async {
    final List<FlowButtonType> selected = [];
    await tester.pumpWidget(
      _testApp(accessibleNavigation: true, onActionTap: selected.add),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Symbols.add_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Cancel"));
    await tester.pumpAndSettle();

    expect(selected, isEmpty);
    expect(find.byType(BottomSheet), findsNothing);

    await tester.tap(find.byIcon(Symbols.add_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Transfer"));
    await tester.pumpAndSettle();

    expect(selected, [FlowButtonType.transfer]);
  });

  testWidgets("accessible picker preserves custom order and connected Eny", (
    tester,
  ) async {
    final UserPreferences preferences = UserPreferencesService().value;
    final String? previousOrder = preferences.transactionButtonOrderJoined;
    addTearDown(() async {
      preferences.transactionButtonOrderJoined = previousOrder;
      await EnyService().setApiKey(apiKey: null);
    });

    preferences.transactionButtonOrder = [
      FlowButtonType.expense,
      FlowButtonType.eny,
      FlowButtonType.transfer,
      FlowButtonType.income,
    ];
    await EnyService().setApiKey(apiKey: "eny-test");

    final List<FlowButtonType> selected = [];
    await tester.pumpWidget(
      _testApp(accessibleNavigation: true, onActionTap: selected.add),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Symbols.add_rounded));
    await tester.pumpAndSettle();

    expect(
      tester
          .widgetList<ListTile>(find.byType(ListTile))
          .map((tile) => (tile.title! as Text).data),
      ["Expense", "Eny", "Transfer", "Income"],
    );

    await tester.tap(find.text("Eny"));
    await tester.pumpAndSettle();
    expect(selected, [FlowButtonType.eny]);
  });

  testWidgets("normal tap still opens radial actions and selects once", (
    tester,
  ) async {
    final List<FlowButtonType> selected = [];
    await tester.pumpWidget(
      _testApp(accessibleNavigation: false, onActionTap: selected.add),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Symbols.add_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byIcon(FlowButtonType.expense.icon), findsOneWidget);
    expect(selected, isEmpty);

    // PieCanvas handles raw pointer events over its painted action widgets.
    await tester.tapAt(
      tester.getCenter(find.byIcon(FlowButtonType.expense.icon)),
    );
    await tester.pumpAndSettle();
    expect(selected, [FlowButtonType.expense]);
  });

  for (final double drift in [2.0, 8.0, 16.0]) {
    testWidgets("a touch drifting $drift pixels keeps the menu open", (
      tester,
    ) async {
      final List<FlowButtonType> selected = [];
      final List<bool> menuStates = [];
      await tester.pumpWidget(
        _testApp(
          accessibleNavigation: false,
          onActionTap: selected.add,
          onMenuToggle: menuStates.add,
        ),
      );
      await tester.pumpAndSettle();

      final Offset start = tester.getCenter(find.byIcon(Symbols.add_rounded));
      final TestGesture gesture = await tester.startGesture(start);
      await tester.pumpAndSettle();
      expect(menuStates.last, isTrue);

      await gesture.moveTo(start + Offset(drift, 0.0));
      await tester.pump(const Duration(milliseconds: 16));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(selected, isEmpty);
      expect(menuStates.last, isTrue);
      expect(find.byIcon(FlowButtonType.expense.icon), findsOneWidget);
    });
  }

  testWidgets("menu release tolerance respects Android touch slop", (
    tester,
  ) async {
    final List<bool> menuStates = [];
    await tester.pumpWidget(
      _testApp(
        accessibleNavigation: false,
        onActionTap: (_) {},
        onMenuToggle: menuStates.add,
        gestureSettings: const DeviceGestureSettings(touchSlop: 32.0),
      ),
    );
    await tester.pumpAndSettle();

    final Offset start = tester.getCenter(find.byIcon(Symbols.add_rounded));
    final TestGesture gesture = await tester.startGesture(start);
    await tester.pumpAndSettle();
    await gesture.moveTo(start + const Offset(24.0, 0.0));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(menuStates.last, isTrue);
  });

  testWidgets("a cancelled touch can be dismissed and the button reused", (
    tester,
  ) async {
    final List<FlowButtonType> selected = [];
    final List<bool> menuStates = [];
    await tester.pumpWidget(
      _testApp(
        accessibleNavigation: false,
        onActionTap: selected.add,
        onMenuToggle: menuStates.add,
      ),
    );
    await tester.pumpAndSettle();

    final Offset start = tester.getCenter(find.byIcon(Symbols.add_rounded));
    final TestGesture gesture = await tester.startGesture(start);
    await tester.pumpAndSettle();
    await gesture.cancel();
    await tester.pumpAndSettle();

    // PieMenu keeps an open menu after cancellation; the next tap dismisses it.
    await tester.tapAt(start);
    await tester.pumpAndSettle();
    expect(selected, isEmpty);
    expect(menuStates.last, isFalse);

    await tester.tapAt(start);
    await tester.pumpAndSettle();
    expect(menuStates.last, isTrue);

    await tester.tapAt(
      tester.getCenter(find.byIcon(FlowButtonType.expense.icon)),
    );
    await tester.pumpAndSettle();
    expect(selected, [FlowButtonType.expense]);
  });

  for (final Size size in [
    const Size(320.0, 640.0),
    const Size(393.0, 873.0),
  ]) {
    testWidgets("the full button receives taps in a $size navbar", (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final List<bool> menuStates = [];
      await tester.pumpWidget(
        _testApp(
          accessibleNavigation: false,
          onActionTap: (_) {},
          onMenuToggle: menuStates.add,
          padding: const EdgeInsets.only(top: 24.0, bottom: 48.0),
        ),
      );
      await tester.pumpAndSettle();

      final Rect rect = tester.getRect(find.byType(NewTransactionButton));
      expect(rect.bottom, lessThanOrEqualTo(size.height - 48.0));

      for (final Offset offset in const [
        Offset.zero,
        Offset(-24.0, 0.0),
        Offset(24.0, 0.0),
        Offset(0.0, -24.0),
        Offset(0.0, 24.0),
      ]) {
        await tester.tapAt(rect.center + offset);
        await tester.pumpAndSettle();
        expect(menuStates.last, isTrue);

        await tester.tapAt(rect.center);
        await tester.pumpAndSettle();
        expect(menuStates.last, isFalse);
      }
    });
  }

  testWidgets("drag opens when early movement arrives before a frame", (
    tester,
  ) async {
    final List<FlowButtonType> selected = [];
    await tester.pumpWidget(
      _testApp(accessibleNavigation: false, onActionTap: selected.add),
    );
    await tester.pumpAndSettle();

    final Offset start = tester.getCenter(find.byIcon(Symbols.add_rounded));
    final TestGesture gesture = await tester.startGesture(start);
    await gesture.moveTo(start + const Offset(0.0, -8.0));
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pumpAndSettle();
    expect(find.byIcon(FlowButtonType.income.icon), findsOneWidget);

    await gesture.moveTo(
      tester.getCenter(find.byIcon(FlowButtonType.income.icon)),
    );
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(selected, [FlowButtonType.income]);
  });

  testWidgets("dragging from the button selects a radial action once", (
    tester,
  ) async {
    final List<FlowButtonType> selected = [];
    await tester.pumpWidget(
      _testApp(accessibleNavigation: false, onActionTap: selected.add),
    );
    await tester.pumpAndSettle();

    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.byIcon(Symbols.add_rounded)),
    );
    await tester.pumpAndSettle();
    await gesture.moveTo(
      tester.getCenter(find.byIcon(FlowButtonType.income.icon)),
    );
    await tester.pumpAndSettle();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(selected, [FlowButtonType.income]);
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets("accessible choices remain usable with large text", (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320.0, 640.0));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final List<FlowButtonType> selected = [];
    await tester.pumpWidget(
      _testApp(
        accessibleNavigation: true,
        textScaler: const TextScaler.linear(2.5),
        onActionTap: selected.add,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Symbols.add_rounded));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text("Expense"),
      100.0,
      scrollable: find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text("Expense"));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(selected, [FlowButtonType.expense]);
  });
}

Widget _testApp({
  required bool accessibleNavigation,
  required ValueChanged<FlowButtonType> onActionTap,
  TextScaler textScaler = .noScaling,
  ValueChanged<bool>? onMenuToggle,
  DeviceGestureSettings gestureSettings = const DeviceGestureSettings(),
  EdgeInsets padding = .zero,
  bool ignoreTransactionButton = false,
}) {
  final ThemeFactory theme = ThemeFactory(flowLights.schemes.first);

  // Mirrors HomePage: the navbar sits over a TabBarView, under the app-wide
  // unlock tap, and sheets are popped through GoRouter.
  final Widget home = GestureDetector(
    onTap: () {},
    child: PieCanvas(
      theme: theme.pieTheme,
      onMenuToggle: onMenuToggle,
      child: DefaultTabController(
        length: 4,
        child: Stack(
          children: [
            const Scaffold(
              body: TabBarView(
                children: [SizedBox(), SizedBox(), SizedBox(), SizedBox()],
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
                      Navbar(onTap: (_) {}),
                      IgnorePointer(
                        ignoring: ignoreTransactionButton,
                        child: NewTransactionButton(onActionTap: onActionTap),
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

  return MaterialApp.router(
    theme: theme.materialTheme,
    localizationsDelegates: const [_TestLocalizationsDelegate()],
    routerConfig: GoRouter(
      routes: [GoRoute(path: "/", builder: (context, state) => home)],
    ),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        accessibleNavigation: accessibleNavigation,
        textScaler: textScaler,
        gestureSettings: gestureSettings,
        padding: padding,
        viewPadding: padding,
      ),
      child: child!,
    ),
  );
}

/// [FlowLocalizations.delegate] also syncs home widgets over a platform
/// channel, which isn't there in widget tests.
class _TestLocalizationsDelegate
    extends LocalizationsDelegate<FlowLocalizations> {
  const _TestLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<FlowLocalizations> load(Locale locale) =>
      SynchronousFuture(FlowLocalizations(locale));

  @override
  bool shouldReload(_TestLocalizationsDelegate old) => false;
}

class _MemoryPreferences extends Fake implements SharedPreferencesWithCache {
  final Map<String, Object> _values = {};

  @override
  Object? get(String key) => _values[key];

  @override
  String? getString(String key) => _values[key] as String?;

  @override
  List<String>? getStringList(String key) => _values[key] as List<String>?;

  @override
  Future<void> setString(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _values.remove(key);
  }
}
