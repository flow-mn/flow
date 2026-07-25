//
//  BudgetWidgetStyle.swift
//  Flow Widgets
//
//  Shared visual language for the two budget widgets. Matches SummaryWidget:
//  rounded system fonts, 16pt inner cards filled with `.fill.tertiary`.
//

import SwiftUI
import WidgetKit

extension BudgetStatus {
    /// Flow has no dedicated warning hue anywhere, so "nearing" is the expense
    /// red softened to ~69% — the same trick the app itself uses.
    func tint(for renderingMode: WidgetRenderingMode) -> Color {
        // iOS 18 tinted/accented rendering flattens colour entirely. Emitting a
        // hue there would just look muddy, and status is carried by text and
        // glyph anyway.
        guard renderingMode == .fullColor else { return .primary }
        switch self {
        case .over: return .red
        case .warning: return .red.opacity(0.69)
        case .healthy: return .green
        }
    }

    /// Reinforcement only. `BudgetItem.statusText` is what actually states the
    /// status; this just makes it scannable.
    var symbolName: String {
        switch self {
        case .over: return "exclamationmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .healthy: return "checkmark.circle.fill"
        }
    }
}

/// Roll-up progress indicator.
struct BudgetProgressBar: View {
    let ratio: Double
    let color: Color
    var height: CGFloat = 8

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.fill.tertiary)
                Capsule()
                    .fill(color)
                    .frame(width: max(height, geometry.size.width * ratio))
            }
        }
        .frame(height: height)
    }
}

/// Pinned progress indicator. `.systemSmall` has the room and a ring reads
/// better than a hairline bar at that size.
struct BudgetProgressRing: View {
    let ratio: Double
    let percentText: String
    let color: Color
    var lineWidth: CGFloat = 8
    /// Fixed rather than a text style: the label lives inside a ring whose
    /// diameter is decided by the layout, so Dynamic Type must not be allowed
    /// to grow it past the hole in the middle.
    var fontSize: CGFloat = 19

    var body: some View {
        ZStack {
            Circle()
                .stroke(.fill.tertiary, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0.005, ratio))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text(percentText)
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .padding(lineWidth + 3)
        }
    }
}

/// Status as a word, with the glyph as reinforcement.
///
/// Contract rule 0: the word is the signal. Colour is gone under iOS 18 tinted
/// rendering, and a glyph alone is a guess.
struct BudgetStatusLabel: View {
    let budget: BudgetItem
    var font: Font = .system(.caption2, design: .rounded, weight: .semibold)
    var symbolSize: CGFloat = 10

    @Environment(\.widgetRenderingMode) private var renderingMode

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: budget.status.symbolName)
                .font(.system(size: symbolSize, weight: .semibold))
            Text(budget.statusText)
                .font(font)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .foregroundStyle(budget.status.tint(for: renderingMode))
    }
}

/// Shown when there is no payload, an unsupported payload version, or no
/// budgets at all.
struct BudgetEmptyView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(.footnote, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
            Text(message)
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
