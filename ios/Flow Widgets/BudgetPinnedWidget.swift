//
//  BudgetPinnedWidget.swift
//  Flow Widgets
//
//  One budget, chosen in the widget editor — either a specific one or
//  "Any budget that needs attention", which resolves to `summary.worstId`
//  every time the timeline is built.
//

import SwiftUI
import WidgetKit

struct BudgetPinnedEntry: TimelineEntry {
    let date: Date
    let payload: BudgetPayload?
    /// `BudgetChoice.automaticId` means "whichever budget needs attention".
    /// Otherwise a `Budget.uuid`, which is what makes the pin survive a
    /// backup/restore — see `BudgetChoice.id`.
    let selectedUuid: String
    let hideAmounts: Bool

    /// `nil` means nothing to show — either no budgets at all, or the pinned
    /// budget has since been deleted. `isMissingPin` tells those apart.
    var budget: BudgetItem? {
        guard let payload else { return nil }
        if selectedUuid == BudgetChoice.automaticId { return payload.worst }
        return payload.budget(uuid: selectedUuid)
    }

    var isMissingPin: Bool {
        guard let payload, !payload.isEmpty else { return false }
        return selectedUuid != BudgetChoice.automaticId && payload.budget(uuid: selectedUuid) == nil
    }

    var labels: BudgetLabels {
        payload?.labels ?? BudgetLabels.fallback
    }
}

struct BudgetPinnedProvider: AppIntentTimelineProvider {
    typealias Entry = BudgetPinnedEntry
    typealias Intent = BudgetPinnedConfigurationIntent

    func placeholder(in context: Context) -> BudgetPinnedEntry {
        BudgetPinnedEntry(
            date: Date(),
            payload: nil,
            selectedUuid: BudgetChoice.automaticId,
            hideAmounts: false
        )
    }

    func snapshot(
        for configuration: BudgetPinnedConfigurationIntent,
        in context: Context
    ) async -> BudgetPinnedEntry {
        BudgetPinnedEntry(
            date: Date(),
            payload: BudgetPayloadStore.load(),
            selectedUuid: configuration.selectedUuid,
            hideAmounts: configuration.hideAmounts
        )
    }

    func timeline(
        for configuration: BudgetPinnedConfigurationIntent,
        in context: Context
    ) async -> Timeline<BudgetPinnedEntry> {
        let entry = await snapshot(for: configuration, in: context)
        return Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
    }
}

struct BudgetPinnedView: View {
    var entry: BudgetPinnedEntry

    @Environment(\.widgetFamily) private var family
    @Environment(\.widgetRenderingMode) private var renderingMode
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// The ring is decoration; the four text lines are the content.
    ///
    /// Measured against the tightest case — a 148pt `.systemSmall` on an
    /// SE-class device, 116pt of usable height — the text block plus a ring big
    /// enough to hold a legible percentage fits at Large and xLarge and stops
    /// fitting at xxLarge. Past that the ring yields to a bar and the
    /// percentage moves up beside the name, so no information is dropped; it
    /// just re-flows.
    private var usesRing: Bool {
        dynamicTypeSize <= .xLarge
    }

    var body: some View {
        if let budget = entry.budget {
            switch family {
            case .systemMedium: medium(budget)
            default: small(budget)
            }
        } else if entry.isMissingPin {
            // Budget deleted since it was pinned — say so, don't go blank.
            BudgetEmptyView(title: entry.labels.title, message: entry.labels.missingBudget)
        } else {
            BudgetEmptyView(title: entry.labels.title, message: entry.labels.empty)
        }
    }

    // MARK: Small

    @ViewBuilder
    private func small(_ budget: BudgetItem) -> some View {
        let tint = budget.status.tint(for: renderingMode)

        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                nameRow(budget)
                if !usesRing {
                    Text(budget.percentText)
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(tint)
                        .lineLimit(1)
                }
            }

            if usesRing {
                BudgetProgressRing(
                    ratio: budget.clampedRatio,
                    percentText: budget.percentText,
                    color: tint
                )
                // The only flexible element, so it absorbs whatever the four
                // text lines leave behind. The floor is what `usesRing` is
                // measured against — below it the percentage inside stops
                // being legible, which is the point at which the bar is better.
                .frame(maxWidth: .infinity, minHeight: 36, maxHeight: .infinity)
            } else {
                BudgetProgressBar(ratio: budget.clampedRatio, color: tint)
            }

            VStack(alignment: .leading, spacing: 1) {
                BudgetStatusLabel(budget: budget)
                Text(budget.daysLeftText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                if let amounts = amountsText(budget) {
                    Text(amounts)
                        .font(.system(.caption2, design: .rounded, weight: .medium))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    // MARK: Medium

    @ViewBuilder
    private func medium(_ budget: BudgetItem) -> some View {
        let tint = budget.status.tint(for: renderingMode)

        HStack(spacing: 14) {
            if usesRing {
                BudgetProgressRing(
                    ratio: budget.clampedRatio,
                    percentText: budget.percentText,
                    color: tint,
                    lineWidth: 11,
                    fontSize: 24
                )
                .frame(width: 96, height: 96)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    nameRow(budget)
                    if !usesRing {
                        Text(budget.percentText)
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .foregroundStyle(tint)
                            .lineLimit(1)
                    }
                }
                if !usesRing {
                    BudgetProgressBar(ratio: budget.clampedRatio, color: tint)
                }
                BudgetStatusLabel(
                    budget: budget,
                    font: .system(.footnote, design: .rounded, weight: .semibold),
                    symbolSize: 12
                )
                // Purely contextual, and the first thing to go when the text is
                // large enough to need the room.
                if usesRing, let periodLabel = budget.periodLabel, !periodLabel.isEmpty {
                    Text(periodLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                Text(budget.daysLeftText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                if let amounts = amountsText(budget) {
                    Text(amounts)
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    // MARK: Pieces

    @ViewBuilder
    private func nameRow(_ budget: BudgetItem) -> some View {
        // No status glyph here — `BudgetStatusLabel` carries it, next to the
        // word that actually states the status.
        HStack(spacing: 4) {
            Text(budget.name)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            if budget.hasMissingData {
                Image(systemName: "questionmark.circle")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
    }

    /// The only place this widget is allowed to read money. Returns `nil` when
    /// "Hide amounts" is on, so there is no branch anywhere else that could
    /// leak `spent`, `limit`, `remaining` or `overBy`.
    private func amountsText(_ budget: BudgetItem) -> String? {
        guard !entry.hideAmounts else { return nil }
        guard let spent = budget.spent, let limit = budget.limit else { return nil }
        return "\(spent) / \(limit)"
    }
}

struct FlowBudgetPinnedWidget: Widget {
    let kind: String = "FlowBudgetPinnedWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: BudgetPinnedConfigurationIntent.self,
            provider: BudgetPinnedProvider()
        ) { entry in
            BudgetPinnedView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .widgetURL(destination(for: entry))
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName("Budget")
        .description("Track a single budget, or whichever one needs attention.")
    }

    /// Links by ObjectBox id even though the pin is stored by uuid: the id
    /// comes from the budget just resolved out of the payload being rendered,
    /// so it is current by construction, and the app routes budgets by id
    /// everywhere else.
    ///
    /// The gap that leaves: a restore renumbers ids *and* re-syncs the payload,
    /// but a tap in between carries an id from the stale one. If nothing owns
    /// that id any more, `/budgets/:id` falls back to the list; if a different
    /// budget has inherited it, the tap opens that one instead.
    private func destination(for entry: BudgetPinnedEntry) -> URL? {
        if let id = entry.budget?.id {
            return URL(string: "flow-mn:///budgets/\(id)")
        }
        return URL(string: "flow-mn:///budgets")
    }
}

private let previewPinnedPayload = BudgetPayload(
    version: 2,
    updatedAt: "2026-07-22T09:14:03.123Z",
    summary: BudgetSummary(
        budgetCount: 3,
        overCount: 0,
        warningCount: 1,
        hasMissingData: false,
        worstId: 7
    ),
    budgets: [
        BudgetItem(
            uuid: "5f2b1c74-0f1a-4c3e-9a7d-2b6e8c1d4a90",
            id: 7,
            name: "Хоол, ундаа",
            spent: "₮420мянга",
            limit: "₮500мянга",
            remaining: "₮80мянга",
            overBy: "₮0",
            percent: 84,
            percentLabel: "84%",
            ratio: 0.84,
            status: .warning,
            statusLabel: "Хязгаарт дөхсөн",
            daysLeft: 9,
            daysLeftLabel: "9 хоног үлдсэн",
            periodLabel: "7-р сар",
            hasMissingData: false
        )
    ],
    labels: BudgetLabels(
        title: "Төсөв",
        empty: "Зарлагын төсөв тогтоох",
        onTrack: "Бүгд хэвийн",
        over: "0 хэтэрсэн",
        nearing: "1 дөхсөн",
        tracked: "3 төсөв",
        missingBudget: "Төсөв алга"
    )
)

#Preview(as: .systemSmall) {
    FlowBudgetPinnedWidget()
} timeline: {
    BudgetPinnedEntry(
        date: .now,
        payload: previewPinnedPayload,
        selectedUuid: BudgetChoice.automaticId,
        hideAmounts: false
    )
    BudgetPinnedEntry(
        date: .now,
        payload: previewPinnedPayload,
        selectedUuid: "5f2b1c74-0f1a-4c3e-9a7d-2b6e8c1d4a90",
        hideAmounts: true
    )
}

#Preview(as: .systemMedium) {
    FlowBudgetPinnedWidget()
} timeline: {
    BudgetPinnedEntry(
        date: .now,
        payload: previewPinnedPayload,
        selectedUuid: "5f2b1c74-0f1a-4c3e-9a7d-2b6e8c1d4a90",
        hideAmounts: false
    )
}
