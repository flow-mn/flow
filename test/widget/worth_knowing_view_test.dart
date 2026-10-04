import "package:flow/data/flow_icon.dart";
import "package:flow/data/insights/insight_engine.dart";
import "package:flow/entity/category.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/providers/categories_provider.dart";
import "package:flow/theme/flow_custom_colors.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flow/widgets/insights/insight_formatter.dart";
import "package:flow/widgets/insights/worth_knowing_view.dart";
import "package:flutter/foundation.dart" hide Category;
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:material_symbols_icons_flow/symbols.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await FlowLocalizations(const Locale("en")).load();
  });

  const Color expense = Color(0xFFC42525);
  const Color income = Color(0xFF32CC70);

  const InsightFormatter usd = InsightFormatter(currency: "USD");

  final Category dining = Category.preset(
    name: "Dining out",
    iconCode: FlowIconData.icon(Symbols.restaurant_rounded).toString(),
    uuid: "dining",
  );

  final DateTime september = DateTime(2026, 9);

  InsightReport report(
    List<Insight> insights, {
    InsightReportStatus status = .ready,
    int? throughDay = 25,
  }) => InsightReport(
    month: september,
    status: status,
    insights: insights,
    usualMonthTotal: 1000.0,
    throughDay: throughDay,
  );

  MonthPaceInsight pace({
    InsightDirection direction = .above,
    double current = 1270.0,
    InsightAttribution? attribution,
    List<InsightCategoryDelta> drivers = const [],
    int? throughDay = 25,
  }) => MonthPaceInsight(
    score: 0.27,
    direction: direction,
    current: current,
    usual: 1000.0,
    throughDay: throughDay,
    history: [
      for (int month = 3; month <= 8; month++)
        InsightMonthValue(
          month: DateTime(2026, month),
          amount: 1000.0,
          counted: true,
        ),
    ],
    attribution: attribution,
    drivers: drivers,
    transactionUuids: const ["a"],
  );

  final RecurringChargeInsight spotify = RecurringChargeInsight(
    score: 0.2,
    series: RecurringSeries(
      key: "title:spotify",
      title: "Spotify",
      cadence: .monthly,
      anchorDay: 3,
      occurrences: [
        for (int month = 6; month <= 9; month++)
          RecurringOccurrence(
            transactionUuid: "s$month",
            date: DateTime(2026, month, 3),
            amount: 11.99,
          ),
      ],
      isFixedPrice: true,
      priceChangeIndex: null,
      categoryUuid: null,
      accountUuid: null,
      isTracked: false,
    ),
  );

  Future<void> pump(
    WidgetTester tester,
    InsightReport? report, {
    InsightFormatter format = usd,
    int hiddenTypeCount = 0,
    bool stale = false,
    ValueChanged<Insight>? onOpen,
    ValueChanged<RecurringChargeInsight>? onTrack,
    VoidCallback? onManageHidden,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [_TestLocalizationsDelegate()],
        theme: ThemeData(
          extensions: const [
            FlowCustomColors(
              income: income,
              expense: expense,
              semi: Color(0xFF888888),
            ),
          ],
        ),
        home: CategoriesProvider(
          [dining],
          child: Scaffold(
            body: SingleChildScrollView(
              child: WorthKnowingView(
                report: report,
                format: format,
                hiddenTypeCount: hiddenTypeCount,
                stale: stale,
                onOpen: onOpen ?? (_) {},
                onTrack: onTrack ?? (_) {},
                onManageHidden: onManageHidden ?? () {},
              ),
            ),
          ),
        ),
      ),
    );
  }

  Finder text(String value) => find.text(value, findRichText: true);

  group("visibility", () {
    for (final InsightReportStatus status in [
      InsightReportStatus.notEnoughHistory,
      InsightReportStatus.futureMonth,
    ]) {
      testWidgets("${status.name} renders nothing", (tester) async {
        await pump(tester, report(const [], status: status));

        expect(find.byType(Surface), findsNothing);
      });
    }

    testWidgets("loading keeps the header, without rows", (tester) async {
      await pump(tester, null);

      expect(find.text("WORTH KNOWING"), findsOneWidget);
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets("hidden kinds can be managed from the header", (tester) async {
      int taps = 0;
      await pump(
        tester,
        report(const []),
        hiddenTypeCount: 2,
        onManageHidden: () => taps++,
      );

      await tester.tap(find.byIcon(Symbols.visibility_off_rounded));
      expect(taps, 1);
    });

    testWidgets("the restore button only shows when something is hidden", (
      tester,
    ) async {
      await pump(tester, report(const []));

      expect(find.byIcon(Symbols.visibility_off_rounded), findsNothing);
    });
  });

  group("empty state", () {
    testWidgets("an in-progress month says so far", (tester) async {
      await pump(tester, report(const []));

      expect(text("Nothing unusual in September so far."), findsOneWidget);
    });

    testWidgets("a past month doesn't", (tester) async {
      await pump(tester, report(const [], throughDay: null));

      expect(text("Nothing unusual in September."), findsOneWidget);
    });

    testWidgets("too early still shows the calm line", (tester) async {
      await pump(tester, report(const [], status: .tooEarly));

      expect(text("Nothing unusual in September so far."), findsOneWidget);
    });
  });

  group("sentences", () {
    testWidgets("a month above names the purchase behind it", (tester) async {
      await pump(
        tester,
        report([
          pace(
            attribution: InsightAttribution(
              transactionUuid: "a",
              title: "Flight to Tokyo",
              categoryUuid: null,
              date: DateTime(2026, 9, 12),
              amount: 330.0,
            ),
          ),
        ]),
      );

      expect(
        text("September is 27% above your usual by the 25th."),
        findsOneWidget,
      );
      expect(
        text("Mostly Flight to Tokyo (\$330). Without it, 6% under."),
        findsOneWidget,
      );
    });

    testWidgets("a closed month below falls back to a category", (
      tester,
    ) async {
      await pump(
        tester,
        report([
          pace(
            direction: .below,
            current: 700.0,
            throughDay: null,
            drivers: const [
              InsightCategoryDelta(
                categoryUuid: "dining",
                current: 50.0,
                usual: 300.0,
              ),
            ],
          ),
        ], throughDay: null),
      );

      expect(text("September was 30% below your usual."), findsOneWidget);
      expect(text("Mostly Dining out, \$250 less than usual."), findsOneWidget);
    });

    testWidgets("a category spike counts its entries", (tester) async {
      await pump(
        tester,
        report([
          CategorySpikeInsight(
            score: 0.2,
            categoryUuid: "dining",
            current: 486.0,
            usual: 260.0,
            entryCount: 11,
            history: const [],
            attribution: null,
            transactionUuids: const [],
          ),
          const NewCategoryInsight(
            score: 0.1,
            categoryUuid: "gone",
            current: 140.0,
            entryCount: 1,
            transactionUuids: [],
          ),
        ]),
      );

      expect(text("Dining out is 1.9× your usual."), findsOneWidget);
      expect(text("\$486 vs \$260 typical · 11 entries"), findsOneWidget);
      expect(text("First Uncategorized spending in 6 months."), findsOneWidget);
      expect(text("\$140 · 1 entry"), findsOneWidget);
    });

    testWidgets("subscriptions keep their cents", (tester) async {
      await pump(tester, report([spotify]));

      expect(text("Spotify looks like a monthly charge."), findsOneWidget);
      expect(text("\$11.99 around the 3rd · 4 times so far"), findsOneWidget);
    });

    testWidgets("privacy mode obscures amounts", (tester) async {
      await pump(
        tester,
        report([spotify]),
        format: const InsightFormatter(currency: "USD", obscure: true),
      );

      expect(text("\$**.** around the 3rd · 4 times so far"), findsOneWidget);
    });
  });

  group("interaction", () {
    testWidgets("tapping a row opens it", (tester) async {
      final List<Insight> opened = [];
      final MonthPaceInsight insight = pace();
      await pump(tester, report([insight]), onOpen: opened.add);

      await tester.tap(text("September is 27% above your usual by the 25th."));
      expect(opened, [insight]);
    });

    testWidgets("track as recurring doesn't open the row", (tester) async {
      final List<Insight> opened = [];
      final List<RecurringChargeInsight> tracked = [];
      await pump(
        tester,
        report([spotify]),
        onOpen: opened.add,
        onTrack: tracked.add,
      );

      await tester.tap(find.text("Track as recurring"));
      expect(tracked, [spotify]);
      expect(opened, isEmpty);
    });

    testWidgets("a previous month's rows can't be opened while loading", (
      tester,
    ) async {
      final List<Insight> opened = [];
      final List<RecurringChargeInsight> tracked = [];
      await pump(
        tester,
        report([spotify]),
        stale: true,
        onOpen: opened.add,
        onTrack: tracked.add,
      );

      await tester.tap(
        text("Spotify looks like a monthly charge."),
        warnIfMissed: false,
      );
      await tester.tap(find.text("Track as recurring"), warnIfMissed: false);
      expect(opened, isEmpty);
      expect(tracked, isEmpty);
    });

    testWidgets("rows are capped by the engine, not the view", (tester) async {
      await pump(tester, report([pace(), spotify]));

      expect(find.byType(Divider), findsOneWidget);
    });
  });

  group("change colors", () {
    Color? valueColor(WidgetTester tester, String value) {
      final RichText rich = tester
          .widgetList<RichText>(find.byType(RichText))
          .firstWhere((widget) => widget.text.toPlainText().contains(value));
      TextStyle? found;
      rich.text.visitChildren((span) {
        if (span is TextSpan && span.text == value) found = span.style;
        return found == null;
      });
      return found?.color;
    }

    testWidgets("spending more uses the expense color by default", (
      tester,
    ) async {
      await pump(tester, report([pace()]));

      expect(valueColor(tester, "27%"), expense);
    });

    testWidgets("spending less uses the income color by default", (
      tester,
    ) async {
      await pump(tester, report([pace(direction: .below, current: 700.0)]));

      expect(valueColor(tester, "30%"), income);
    });
  });
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
