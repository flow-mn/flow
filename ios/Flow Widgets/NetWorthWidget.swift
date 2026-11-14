import Charts
import SwiftUI
import WidgetKit

// iOS counterpart of the Android "Flow Net Worth" widget. Reads the same keys
// NetWorthWidgetSync (lib/services/net_worth_widget_sync.dart) writes to the
// app group: today's total, the 30-day change and a sample per day.

struct NetWorthWidgetEntry: TimelineEntry {
    let date: Date
    let label: String
    let amount: String
    let delta: String?
    let deltaPositive: Bool
    let rangeLabel: String
    let samples: [Double]
}

struct NetWorthProvider: TimelineProvider {
    typealias Entry = NetWorthWidgetEntry

    func placeholder(in context: Context) -> NetWorthWidgetEntry {
        NetWorthWidgetEntry(
            date: Date(), label: "Net worth", amount: "---", delta: nil,
            deltaPositive: true, rangeLabel: "Last 30 days", samples: []
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (NetWorthWidgetEntry) -> ()) {
        let prefs = UserDefaults(suiteName: "group.mn.flow.flow")
        let samples = (prefs?.string(forKey: "netWorthSamples") ?? "")
            .split(separator: ",")
            .compactMap { Double($0) }
        let entry = NetWorthWidgetEntry(
            date: Date(),
            label: prefs?.string(forKey: "netWorthLabel") ?? "Net worth",
            amount: prefs?.string(forKey: "netWorthAmount") ?? "---",
            delta: prefs?.string(forKey: "netWorthDelta"),
            // Absent means "no data yet"; treat as positive like Android does.
            deltaPositive: prefs?.object(forKey: "netWorthDeltaPositive") as? Bool ?? true,
            rangeLabel: prefs?.string(forKey: "netWorthRangeLabel") ?? "",
            samples: samples
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        getSnapshot(in: context) { entry in
            completion(Timeline(entries: [entry], policy: .atEnd))
        }
    }
}

struct NetWorthWidgetView: View {
    var entry: NetWorthWidgetEntry
    @Environment(\.widgetFamily) var family

    private var trendColor: Color { entry.deltaPositive ? .green : .red }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(entry.label)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            Text(entry.amount)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .privacySensitive()
            if let delta = entry.delta {
                HStack(spacing: 4) {
                    Image(systemName: entry.deltaPositive
                        ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis")
                    Text(entry.rangeLabel.isEmpty ? delta : "\(delta) · \(entry.rangeLabel)")
                        .lineLimit(1)
                        .privacySensitive()
                }
                .font(.caption)
                .foregroundStyle(trendColor)
            }
            if entry.samples.count >= 2 {
                Spacer(minLength: 6)
                sparkline
            } else {
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // No axes: the chart shows the trend, never the amounts, so it stays
    // visible in privacy mode just like on Android.
    private var sparkline: some View {
        // Same rule as Android (NetWorth.kt): the axis never zooms in further
        // than 2% of the balance, so small movements stay small.
        let rawLo = entry.samples.min() ?? 0
        let rawHi = entry.samples.max() ?? 1
        let floorSpan = 0.02 * max(abs(rawLo), abs(rawHi))
        let widen = max(0, floorSpan - (rawHi - rawLo)) / 2
        let lo = rawLo - widen
        let hi = rawHi + widen
        let pad = max((hi - lo) * 0.12, 0.01)
        return Chart {
            ForEach(Array(entry.samples.enumerated()), id: \.offset) { index, value in
                AreaMark(
                    x: .value("Day", index),
                    yStart: .value("Base", lo - pad),
                    yEnd: .value("Balance", value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.accentColor.opacity(0.35), Color.accentColor.opacity(0)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .interpolationMethod(.linear)
                LineMark(x: .value("Day", index), y: .value("Balance", value))
                    .foregroundStyle(Color.accentColor)
                    .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                    .interpolationMethod(.linear)
            }
            if let last = entry.samples.last {
                PointMark(x: .value("Day", entry.samples.count - 1), y: .value("Balance", last))
                    .foregroundStyle(Color.accentColor)
                    .symbolSize(40)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartLegend(.hidden)
        .chartXScale(domain: 0...(entry.samples.count - 1))
        .chartYScale(domain: (lo - pad)...(hi + pad))
    }
}

struct FlowNetWorthWidget: Widget {
    // Must match iOSName in NetWorthWidgetSync.
    let kind: String = "FlowNetWorthWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NetWorthProvider()) { entry in
            NetWorthWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemMedium, .systemLarge])
        .configurationDisplayName("Flow Net Worth")
        .description("Your total balance and its 30-day trend.")
    }
}

#Preview(as: .systemMedium) {
    FlowNetWorthWidget()
} timeline: {
    NetWorthWidgetEntry(
        date: .now, label: "Net worth", amount: "$43.6K", delta: "+$6.12K",
        deltaPositive: true, rangeLabel: "Last 30 days",
        samples: [37467, 37610, 37580, 37890, 38020, 38310, 38640, 38900, 39250, 39420,
                  39860, 40110, 40400, 40920, 41150, 41520, 41880, 42210, 42530, 42950,
                  43300, 43587]
    )
}
