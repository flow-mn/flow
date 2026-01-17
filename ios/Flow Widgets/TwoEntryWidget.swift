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
        TwoEntryWidgetEntry(date: Date(), order: ["income", "expense"], color: .primary)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TwoEntryWidgetEntry) -> ()) {
        let prefs = UserDefaults(suiteName: "group.mn.flow.flow")
        let counter = prefs?.string(forKey: "buttonOrder")
        let order = counter?.components(separatedBy: ",") ?? ["income", "expense"]
        let entry = TwoEntryWidgetEntry(date: Date(), order: order, color: .primary)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        getSnapshot(in: context) { (entry) in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }

//    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async
//        -> TwoEntryWidgetEntry
//    {
//        TwoEntryWidgetEntry(date: Date(), order: ["income", "expense"], color: .primary)
//    }

    static let validOrderNames: [String] = ["income", "expense", "transfer"]

//    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<
//        TwoEntryWidgetEntry
//    > {
//        let order: [String] = UserDefaults.standard.string(forKey: "flutter.flow.widgets.buttonOrder")?.components(separatedBy: ",") ?? ["income", "expense"]
//        let colorHex: String? = UserDefaults.standard.string(forKey: "flow.widgets.color")
//        let validOrder: [String] =
//            (order.allSatisfy({ TwoEntryProvider.validOrderNames.contains($0) })
//                && order.count >= 2)
//            ? order : ["income", "expense"]
//
//        let entry = TwoEntryWidgetEntry(date: Date(), order: validOrder, color: .primary)
//
//        return Timeline(entries: [entry], policy: .atEnd)
//    }
}

struct TwoEntryWidgetView: View {
    var entry: TwoEntryWidgetEntry

    static let spacing = 8.0

    var body: some View {
        GeometryReader { geometry in
            let size = (geometry.size.height - 40) * 0.5

            VStack(alignment: .center, spacing: TwoEntryWidgetView.spacing) {
                Link(destination: URL(string: "flow-mn:///transaction/new?type=transfer")!) {
                    Capsule()
                    .fill(.tertiary)
                    .overlay{
                        Image("Transfer")
                            .resizable()
                            .foregroundStyle(.primary)
                            .frame(
                                width: size,
                                height: size)
                    }
                }
                HStack(spacing: TwoEntryWidgetView.spacing) {
                    ForEach(entry.order.filter({ $0 != "transfer" }), id: \.self) { item in
                        Link(destination: URL(string: "flow-mn:///transaction/new?type=\(item)")!) {
                            Circle()
                                .fill(.tertiary)
                                .overlay {
                                    Image(item.capitalized)
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
