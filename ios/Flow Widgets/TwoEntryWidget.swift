import SwiftUI
import WidgetKit

struct TwoEntryWidgetEntry: TimelineEntry {
    let date: Date
    let order: [String]
    let color: Color
}

struct TwoEntryProvider: TimelineProvider {
    typealias Entry = TwoEntryWidgetEntry

    func placeholder(in context: Context) -> TwoEntryWidgetEntry {
        TwoEntryWidgetEntry(date: Date(), order: ["transfer", "income", "expense"], color: .primary)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TwoEntryWidgetEntry) -> ()) {
        let prefs = UserDefaults(suiteName: "group.mn.flow.flow")
        let counter = prefs?.string(forKey: "buttonOrder")
        let order = counter?.components(separatedBy: ",") ?? ["transfer", "income", "expense"]
        let entry = TwoEntryWidgetEntry(date: Date(), order: order, color: .primary)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        getSnapshot(in: context) { (entry) in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }

    static let validOrderNames: [String] = ["income", "expense", "transfer", "eny"]
}

struct TwoEntryWidgetView: View {
    var entry: TwoEntryWidgetEntry

    static let spacing = 8.0
    
    static let images: [String: String] = [
        "transfer": "Transfer",
        "income": "Income",
        "expense": "Expense",
        "eny": "Camera"
    ]

    var body: some View {
        GeometryReader { geometry in
            let size = (geometry.size.height - 40) * 0.5

            if (entry.order.count == 2) {
                VStack(spacing: TwoEntryWidgetView.spacing) {
                    button(
                        type: entry.order[0],
                        size: size,
                        pill: true
                    )
                    button(
                        type: entry.order[1],
                        size: size,
                        pill: true
                    )
                }
            }

            if (entry.order.count == 3) {
                VStack(alignment: .center, spacing: TwoEntryWidgetView.spacing) {
                    button(
                        type: entry.order[0],
                        size: size,
                        pill: true
                    )
                    HStack(spacing: TwoEntryWidgetView.spacing) {
                        button(
                            type: entry.order[1],
                            size: size
                        )
                        button(
                            type: entry.order[2],
                            size: size
                        )
                    }
                }
            }

            if (entry.order.count == 4) {
                VStack(alignment: .center, spacing: TwoEntryWidgetView.spacing) {
                    HStack(spacing: TwoEntryWidgetView.spacing) {
                        button(
                            type: entry.order[0],
                            size: size
                        )
                        button(
                            type: entry.order[1],
                            size: size
                        )
                    }
                    HStack(spacing: TwoEntryWidgetView.spacing) {
                        button(
                            type: entry.order[2],
                            size: size
                        )
                        button(
                            type: entry.order[3],
                            size: size
                        )
                    }
                }
            }
        }
    }

    @ViewBuilder
    func button(type: String, size: Double, pill: Bool = false) -> some View {
        Link(destination: URL(string: "flow-mn:///transaction/new?type=\(type)")!) {
            if (pill) {
                Capsule()
                .fill(.tertiary)
                .overlay{
                    Image(TwoEntryWidgetView.images[entry.order[0]]!)
                        .resizable()
                        .foregroundStyle(.primary)
                        .frame(
                            width: size,
                            height: size)
                }
            } else {
                Circle()
                .fill(.tertiary)
                .overlay {
                    Image(TwoEntryWidgetView.images[type]!)
                        .resizable()
                        .foregroundStyle(.primary)
                        .frame(
                            width: size,
                            height: size)
                }
            }
        }
    }
}

struct FlowTwoEntryWidget: Widget {
    let kind: String = "FlowTwoEntryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind, provider: TwoEntryProvider()
        ) { entry in
            TwoEntryWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemSmall])

    }
}

#Preview(as: .systemSmall) {
    FlowTwoEntryWidget()
} timeline: {
    TwoEntryWidgetEntry(date: .now, order: ["income", "expense"], color: .primary)
}
