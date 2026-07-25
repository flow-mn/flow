//
//  BudgetRollupWidget.swift
//  Flow Widgets
//
//  How many budgets need attention, plus the single worst one.
//
//  Deliberately never sums spent/limit across budgets: Flow's budgets overlap
//  and span different periods, so a combined total would double-count.
//

import SwiftUI
import WidgetKit

struct BudgetRollupEntry: TimelineEntry {
    let date: Date
    let payload: BudgetPayload?
    let hideAmounts: Bool
}

struct BudgetRollupProvider: AppIntentTimelineProvider {
    typealias Entry = BudgetRollupEntry
    typealias Intent = BudgetRollupConfigurationIntent

    func placeholder(in context: Context) -> BudgetRollupEntry {
        BudgetRollupEntry(date: Date(), payload: nil, hideAmounts: false)
    }

    func snapshot(
        for configuration: BudgetRollupConfigurationIntent,
        in context: Context
    ) async -> BudgetRollupEntry {
        BudgetRollupEntry(
            date: Date(),
            payload: BudgetPayloadStore.load(),
            hideAmounts: configuration.hideAmounts
        )
    }

    func timeline(
        for configuration: BudgetRollupConfigurationIntent,
        in context: Context
    ) async -> Timeline<BudgetRollupEntry> {
        let entry = await snapshot(for: configuration, in: context)
        // The app pushes a reload after every write; this hourly re-read is only
        // a safety net for pushes that never arrived.
        return Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
    }
}

struct BudgetRollupView: View {
    var entry: BudgetRollupEntry

    @Environment(\.widgetRenderingMode) private var renderingMode

    var body: some View {
        if let payload = entry.payload, !payload.isEmpty {
            content(payload)
        } else {
            let labels = entry.payload?.labels ?? BudgetLabels.fallback
            BudgetEmptyView(title: labels.title, message: labels.empty)
        }
    }

    @ViewBuilder
    private func content(_ payload: BudgetPayload) -> some View {
        let labels = payload.labels
        let summary = payload.summary

        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(labels.title)
                    .font(.system(.footnote, design: .rounded, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer(minLength: 4)
                Text(labels.tracked)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            HStack(spacing: 6) {
                Image(systemName: headlineStatus(summary).symbolName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(headlineStatus(summary).tint(for: renderingMode))
                Text(headlineText(labels, summary))
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }

            // Only when both buckets are non-empty does the headline leave
            // something unsaid.
            if summary.overCount > 0, summary.warningCount > 0 {
                Text(labels.nearing)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            if let worst = payload.worst {
                worstCard(worst)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func worstCard(_ budget: BudgetItem) -> some View {
        let tint = budget.status.tint(for: renderingMode)

        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Text(budget.name)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                if budget.hasMissingData {
                    Image(systemName: "questionmark.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 4)
                Text(budget.percentText)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(tint)
                    .lineLimit(1)
            }

            BudgetProgressBar(ratio: budget.clampedRatio, color: tint)

            HStack(spacing: 5) {
                // The word, not just the bar's colour — tinted rendering keeps
                // neither the hue nor the meaning otherwise.
                BudgetStatusLabel(budget: budget)
                Text("·")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Text(budget.daysLeftText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer(minLength: 4)
                if let amounts = amountsText(budget) {
                    Text(amounts)
                        .font(.system(.caption2, design: .rounded, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(12)
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
    }

    /// The only place the roll-up is allowed to touch money, and it checks the
    /// toggle itself — no caller can forget. Nothing else in this view reads
    /// `spent`/`limit`/`remaining`/`overBy`.
    private func amountsText(_ budget: BudgetItem) -> String? {
        guard !entry.hideAmounts else { return nil }
        guard let spent = budget.spent, let limit = budget.limit else { return nil }
        return "\(spent) / \(limit)"
    }

    private func headlineStatus(_ summary: BudgetSummary) -> BudgetStatus {
        if summary.overCount > 0 { return .over }
        if summary.warningCount > 0 { return .warning }
        return .healthy
    }

    private func headlineText(_ labels: BudgetLabels, _ summary: BudgetSummary) -> String {
        if summary.overCount > 0 { return labels.over }
        if summary.warningCount > 0 { return labels.nearing }
        return labels.onTrack
    }
}

struct FlowBudgetRollupWidget: Widget {
    let kind: String = "FlowBudgetRollupWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: BudgetRollupConfigurationIntent.self,
            provider: BudgetRollupProvider()
        ) { entry in
            BudgetRollupView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .widgetURL(URL(string: "flow-mn:///budgets"))
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("Budgets")
        .description("How many budgets need attention, and the one that needs it most.")
    }
}

#Preview(as: .systemMedium) {
    FlowBudgetRollupWidget()
} timeline: {
    BudgetRollupEntry(
        date: .now,
        payload: BudgetPayload(
            version: 1,
            updatedAt: "2026-07-22T09:14:03.123Z",
            summary: BudgetSummary(
                budgetCount: 3,
                overCount: 1,
                warningCount: 1,
                hasMissingData: false,
                worstId: 4
            ),
            budgets: [
                BudgetItem(
                    id: 4,
                    name: "Хүнс",
                    spent: "₮1.24сая",
                    limit: "₮1сая",
                    remaining: "₮0",
                    overBy: "₮240мянга",
                    percent: 124,
                    percentLabel: "124%",
                    ratio: 1.24,
                    status: .over,
                    statusLabel: "Хязгаар хэтэрсэн",
                    daysLeft: 9,
                    daysLeftLabel: "9 хоног үлдсэн",
                    periodLabel: "7-р сар",
                    hasMissingData: false
                ),
                BudgetItem(
                    id: 7,
                    name: "Түлш",
                    spent: "₮380мянга",
                    limit: "₮450мянга",
                    remaining: "₮70мянга",
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
                ),
            ],
            labels: BudgetLabels(
                title: "Төсөв",
                empty: "Зарлагын төсөв тогтоох",
                onTrack: "Бүгд хэвийн",
                over: "1 хэтэрсэн",
                nearing: "1 дөхсөн",
                tracked: "3 төсөв",
                missingBudget: "Төсөв алга"
            )
        ),
        hideAmounts: false
    )
}
