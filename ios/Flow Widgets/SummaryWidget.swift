import SwiftUI
import WidgetKit

struct SummaryWidgetEntry: TimelineEntry {
    let date: Date
    let income: String
    let expense: String
    let incomeLabel: String
    let expenseLabel: String
    let rangeLabel: String
}

struct SummaryProvider: TimelineProvider {
    typealias Entry = SummaryWidgetEntry

    func placeholder(in context: Context) -> SummaryWidgetEntry {
        SummaryWidgetEntry(date: Date(), income: "---", expense: "---", incomeLabel: "Income", expenseLabel: "Expense", rangeLabel: "This month")
    }

    func getSnapshot(in context: Context, completion: @escaping (SummaryWidgetEntry) -> ()) {
        let prefs = UserDefaults(suiteName: "group.mn.flow.flow")
        let income = prefs?.string(forKey: "summaryIncome") ?? "---"
        let expense = prefs?.string(forKey: "summaryExpense") ?? "---"
        let incomeLabel = prefs?.string(forKey: "summaryIncomeLabel") ?? "Income"
        let expenseLabel = prefs?.string(forKey: "summaryExpenseLabel") ?? "Expense"
        let rangeLabel = prefs?.string(forKey: "summaryRangeLabel") ?? "This month"
        let entry = SummaryWidgetEntry(date: Date(), income: income, expense: expense, incomeLabel: incomeLabel, expenseLabel: expenseLabel, rangeLabel: rangeLabel)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        getSnapshot(in: context) { (entry) in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

struct SummaryWidgetView: View {
    var entry: SummaryWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(entry.rangeLabel)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            HStack(spacing: 10) {
                summaryCard(
                    label: entry.incomeLabel,
                    amount: entry.income,
                    icon: "Income",
                    color: .green
                )
                summaryCard(
                    label: entry.expenseLabel,
                    amount: entry.expense,
                    icon: "Expense",
                    color: .red
                )
            }
        }
    }

    @ViewBuilder
    func summaryCard(label: String, amount: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Text(label)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Image(icon)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(color)
                    .frame(width: 14, height: 14)
            }
            Spacer(minLength: 0)
            Text(amount)
                .font(.system(.largeTitle, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(14)
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct FlowSummaryWidget: Widget {
    let kind: String = "FlowSummaryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind, provider: SummaryProvider()
        ) { entry in
            SummaryWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("Flow Summary")
        .description("View your monthly income and expenses at a glance.")
    }
}

#Preview(as: .systemMedium) {
    FlowSummaryWidget()
} timeline: {
    SummaryWidgetEntry(date: .now, income: "$3.82K", expense: "$1.24K", incomeLabel: "Income", expenseLabel: "Expense", rangeLabel: "This month")
}
