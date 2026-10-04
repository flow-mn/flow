import "package:fl_chart/fl_chart.dart";
import "package:flow/theme/flow_custom_colors.dart";
import "package:flow/widgets/insights/insight_history_chart.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  Future<void> pump(WidgetTester tester, List<InsightChartBar> bars) =>
      tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const [
              FlowCustomColors(
                income: Color(0xFF32CC70),
                expense: Color(0xFFC42525),
                semi: Color(0xFF888888),
              ),
            ],
          ),
          home: Scaffold(
            body: SizedBox(
              width: 320.0,
              child: InsightHistoryChart(
                bars: bars,
                reference: 100.0,
                referenceLabel: "usual \$100",
                formatAmount: (amount) => "\$${amount.round()}",
              ),
            ),
          ),
        ),
      );

  testWidgets("labels every bar and highlights the last one", (tester) async {
    await pump(tester, [
      (label: "Jul", amount: 90.0, muted: false),
      (label: "Aug", amount: 10.0, muted: true),
      (label: "Sep", amount: 180.0, muted: false),
    ]);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text("Jul"), findsOneWidget);
    expect(find.text("Sep"), findsOneWidget);

    final BarChart chart = tester.widget(find.byType(BarChart));
    final List<Color> colors = chart.data.barGroups
        .map((group) => group.barRods.single.color!)
        .toList();

    expect(colors.last, isNot(colors.first));
    expect(colors[1], isNot(colors.first));
    expect(chart.data.maxY, greaterThan(180.0));
  });

  testWidgets("a single empty bar still renders", (tester) async {
    await pump(tester, [(label: "Sep", amount: 0.0, muted: false)]);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
