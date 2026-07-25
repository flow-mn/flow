//
//  BudgetPayload.swift
//  Flow Widgets
//
//  Decoding for the `budgetsPayload` blob written by
//  `lib/services/budget_widget_sync.dart`. See budget-widget-contract.md.
//
//  Every user-visible string in here is already localized and formatted by the
//  app — the extension must never format money or dates itself. The one
//  exception is the hardcoded English fallbacks below, which exist because a
//  sync can fire before the app's translations have loaded and Dart then omits
//  the key entirely (contract rule 6). Decoding therefore has to survive any
//  label being absent: a non-optional `String` would throw and leave a healthy
//  install staring at placeholder content forever.
//

import Foundation

// MARK: - Model

struct BudgetPayload: Codable {
    let version: Int
    let updatedAt: String?
    let summary: BudgetSummary
    let budgets: [BudgetItem]
    let labels: BudgetLabels

    init(
        version: Int,
        updatedAt: String?,
        summary: BudgetSummary,
        budgets: [BudgetItem],
        labels: BudgetLabels
    ) {
        self.version = version
        self.updatedAt = updatedAt
        self.summary = summary
        self.budgets = budgets
        self.labels = labels
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(Int.self, forKey: .version)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        summary = try container.decode(BudgetSummary.self, forKey: .summary)
        budgets = try container.decodeIfPresent([BudgetItem].self, forKey: .budgets) ?? []
        // The whole `labels` object can be missing for the same reason a single
        // key can be.
        labels = try container.decodeIfPresent(BudgetLabels.self, forKey: .labels)
            ?? BudgetLabels.fallback
    }
}

struct BudgetSummary: Codable {
    let budgetCount: Int
    let overCount: Int
    let warningCount: Int
    let hasMissingData: Bool
    /// `nil` when there are no budgets at all.
    let worstId: Int?

    init(
        budgetCount: Int,
        overCount: Int,
        warningCount: Int,
        hasMissingData: Bool,
        worstId: Int?
    ) {
        self.budgetCount = budgetCount
        self.overCount = overCount
        self.warningCount = warningCount
        self.hasMissingData = hasMissingData
        self.worstId = worstId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        budgetCount = try container.decodeIfPresent(Int.self, forKey: .budgetCount) ?? 0
        overCount = try container.decodeIfPresent(Int.self, forKey: .overCount) ?? 0
        warningCount = try container.decodeIfPresent(Int.self, forKey: .warningCount) ?? 0
        hasMissingData = try container.decodeIfPresent(Bool.self, forKey: .hasMissingData) ?? false
        worstId = try container.decodeIfPresent(Int.self, forKey: .worstId)
    }
}

enum BudgetStatus: String, Codable {
    case healthy
    case warning
    case over

    /// Unknown values degrade to `healthy` rather than failing the whole decode;
    /// a future app version could add a status this extension has never heard of.
    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = BudgetStatus(rawValue: raw) ?? .healthy
    }
}

struct BudgetItem: Codable, Identifiable {
    /// `Budget.uuid` — the only handle that survives backup/restore, and so the
    /// only thing the pinned widget is allowed to *store*.
    ///
    /// The app's export omits ObjectBox ids, so a restore reinserts every
    /// budget and renumbers it: "Eating out" comes back as a different `id`,
    /// and that `id` may already belong to a different budget.
    let uuid: String
    /// `Budget.id` as of *this* payload. Safe to build a deep link from, since
    /// the link is made from the same snapshot being rendered. Never persist
    /// it — that is what `uuid` is for.
    let id: Int
    let name: String
    // Pre-formatted, compacted money. Never rendered when "Hide amounts" is on.
    // Optional so a truncated payload degrades to "no amount shown" instead of
    // failing the decode or printing a blank.
    let spent: String?
    let limit: String?
    let remaining: String?
    let overBy: String?
    /// Already rounded by the app. Geometry only — never rendered. Use
    /// `percentText`, which is pre-formatted in the *app* locale; this
    /// extension would otherwise format in the *device* locale and mix digit
    /// styles with every other string in the payload.
    let percent: Int
    /// Pre-formatted percentage, e.g. "84%". Optional purely for decode safety.
    let percentLabel: String?
    /// NOT clamped — an over-budget entry exceeds 1.0.
    let ratio: Double
    /// Drives colour and bar geometry. Never rendered — use `statusText`.
    let status: BudgetStatus
    /// May be absent (contract rule 6) — use `statusText`, never this directly.
    let statusLabel: String?
    let daysLeft: Int
    /// May be absent (contract rule 6) — use `daysLeftText`, never this directly.
    let daysLeftLabel: String?
    let periodLabel: String?
    let hasMissingData: Bool

    init(
        uuid: String,
        id: Int,
        name: String,
        spent: String?,
        limit: String?,
        remaining: String?,
        overBy: String?,
        percent: Int,
        percentLabel: String?,
        ratio: Double,
        status: BudgetStatus,
        statusLabel: String?,
        daysLeft: Int,
        daysLeftLabel: String?,
        periodLabel: String?,
        hasMissingData: Bool
    ) {
        self.uuid = uuid
        self.id = id
        self.name = name
        self.spent = spent
        self.limit = limit
        self.remaining = remaining
        self.overBy = overBy
        self.percent = percent
        self.percentLabel = percentLabel
        self.ratio = ratio
        self.status = status
        self.statusLabel = statusLabel
        self.daysLeft = daysLeft
        self.daysLeftLabel = daysLeftLabel
        self.periodLabel = periodLabel
        self.hasMissingData = hasMissingData
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Both are required: an entry with no uuid can't be pinned, and one
        // with no id can't be linked to. Failing the decode drops the whole
        // payload to the placeholder, which beats a half-usable budget list.
        uuid = try container.decode(String.self, forKey: .uuid)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        spent = try container.decodeIfPresent(String.self, forKey: .spent)
        limit = try container.decodeIfPresent(String.self, forKey: .limit)
        remaining = try container.decodeIfPresent(String.self, forKey: .remaining)
        overBy = try container.decodeIfPresent(String.self, forKey: .overBy)
        percent = try container.decodeIfPresent(Int.self, forKey: .percent) ?? 0
        percentLabel = try container.decodeIfPresent(String.self, forKey: .percentLabel)
        ratio = try container.decodeIfPresent(Double.self, forKey: .ratio) ?? 0
        status = try container.decodeIfPresent(BudgetStatus.self, forKey: .status) ?? .healthy
        statusLabel = try container.decodeIfPresent(String.self, forKey: .statusLabel)
        daysLeft = try container.decodeIfPresent(Int.self, forKey: .daysLeft) ?? 0
        daysLeftLabel = try container.decodeIfPresent(String.self, forKey: .daysLeftLabel)
        periodLabel = try container.decodeIfPresent(String.self, forKey: .periodLabel)
        hasMissingData = try container.decodeIfPresent(Bool.self, forKey: .hasMissingData) ?? false
    }

    /// Safe for a bar or ring fraction.
    var clampedRatio: Double {
        guard ratio.isFinite else { return 0 }
        return min(max(ratio, 0), 1)
    }

    /// Never blank. Falls back to English only when the app omitted the label
    /// because its translations were not ready yet.
    var daysLeftText: String {
        if let daysLeftLabel, !daysLeftLabel.isEmpty { return daysLeftLabel }
        if daysLeft <= 0 { return "Period ended" }
        return daysLeft == 1 ? "1 day left" : "\(daysLeft) days left"
    }

    /// The only percentage the widgets are allowed to render.
    ///
    /// The fallback formats in the *device* locale, which is exactly the
    /// mismatch `percentLabel` exists to avoid — so it only ever runs when the
    /// app failed to publish the label at all.
    var percentText: String {
        if let percentLabel, !percentLabel.isEmpty { return percentLabel }
        return (Double(percent) / 100).formatted(.percent.precision(.fractionLength(0)))
    }

    /// Status as a word. This is what makes status survive iOS 18 tinted
    /// rendering, where the hue is flattened away and a coloured glyph alone
    /// says nothing.
    var statusText: String {
        if let statusLabel, !statusLabel.isEmpty { return statusLabel }
        switch status {
        case .over: return "Over budget"
        case .warning: return "Nearing limit"
        case .healthy: return "On track"
        }
    }
}

struct BudgetLabels: Codable {
    let title: String
    let empty: String
    let onTrack: String
    let over: String
    let nearing: String
    let tracked: String
    let missingBudget: String

    /// Used when the app has never written a payload, or when a sync landed
    /// before Flow's translations finished loading and Dart omitted the key.
    /// The extension has no access to Flow's translations, so English is the
    /// only option — the same thing the existing Summary widget does with
    /// `?? "Income"`.
    static let fallback = BudgetLabels(
        title: "Budgets",
        empty: "Set a spending budget",
        onTrack: "All on track",
        over: "Over limit",
        nearing: "Nearing limit",
        tracked: "Budgets",
        missingBudget: "No budgets yet"
    )

    init(
        title: String,
        empty: String,
        onTrack: String,
        over: String,
        nearing: String,
        tracked: String,
        missingBudget: String
    ) {
        self.title = title
        self.empty = empty
        self.onTrack = onTrack
        self.over = over
        self.nearing = nearing
        self.tracked = tracked
        self.missingBudget = missingBudget
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let fallback = BudgetLabels.fallback
        // A published label is guaranteed non-empty, but an empty string is
        // treated as absent anyway — a blank is never an acceptable render.
        func value(_ key: CodingKeys, _ fallbackValue: String) throws -> String {
            let decoded = try container.decodeIfPresent(String.self, forKey: key)
            guard let decoded, !decoded.isEmpty else { return fallbackValue }
            return decoded
        }
        title = try value(.title, fallback.title)
        empty = try value(.empty, fallback.empty)
        onTrack = try value(.onTrack, fallback.onTrack)
        over = try value(.over, fallback.over)
        nearing = try value(.nearing, fallback.nearing)
        tracked = try value(.tracked, fallback.tracked)
        missingBudget = try value(.missingBudget, fallback.missingBudget)
    }
}

extension BudgetPayload {
    /// The lookup for anything that was *stored* — i.e. a pinned widget's
    /// choice, which has to survive a restore renumbering every budget.
    func budget(uuid: String?) -> BudgetItem? {
        guard let uuid, !uuid.isEmpty else { return nil }
        return budgets.first { $0.uuid == uuid }
    }

    /// Only valid within one payload: `summary.worstId` is an id from this same
    /// snapshot, so it can't have drifted out from under the list beside it.
    private func budget(id: Int?) -> BudgetItem? {
        guard let id else { return nil }
        return budgets.first { $0.id == id }
    }

    /// The single most urgent budget, per the app's own ordering.
    var worst: BudgetItem? {
        budget(id: summary.worstId) ?? budgets.first
    }

    var isEmpty: Bool {
        budgets.isEmpty
    }
}

// MARK: - Store

enum BudgetPayloadStore {
    static let appGroupId = "group.mn.flow.flow"
    static let payloadKey = "budgetsPayload"
    /// Bump only together with `BudgetWidgetSync.payloadVersion` on the Dart side.
    static let supportedVersion = 2

    /// One shared read for both widgets and for the budget picker's entity query.
    ///
    /// Returns `nil` when the app has never written a payload, when the blob is
    /// unreadable, or when it was written by a newer app than this extension
    /// understands — every one of those renders the empty/placeholder state.
    static func load() -> BudgetPayload? {
        guard
            let raw = UserDefaults(suiteName: appGroupId)?.string(forKey: payloadKey),
            let data = raw.data(using: .utf8)
        else { return nil }

        let decoder = JSONDecoder()

        // Version gate first: a v2 payload may not even decode into the v1
        // shape, so checking it after a full decode would be too late.
        guard
            let probe = try? decoder.decode(VersionProbe.self, from: data),
            probe.version == supportedVersion
        else { return nil }

        return try? decoder.decode(BudgetPayload.self, from: data)
    }

    private struct VersionProbe: Decodable {
        let version: Int
    }
}
