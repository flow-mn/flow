//
//  BudgetWidgetIntents.swift
//  Flow Widgets
//
//  Configuration for the two budget widgets, plus the entity/query pair that
//  lets the pinned widget's editor list the user's real budgets.
//
//  These strings are the extension's own UI (widget editor), not payload data,
//  so they live here rather than coming from Dart.
//

import AppIntents
import WidgetKit

// MARK: - Budget picker entity

/// A pickable budget, plus one synthetic "whatever needs attention" option.
///
/// Modelling auto-worst as an ordinary selectable entry — rather than a
/// separate toggle — means a user who picked "Groceries" keeps seeing
/// Groceries. The widget never silently changes subject on them.
struct BudgetChoice: AppEntity {
    /// `Budget.uuid`, never the ObjectBox id.
    ///
    /// AppIntents persists this with the widget configuration, so it outlives
    /// the payload it came from — including across a backup/restore, which
    /// renumbers every ObjectBox id. Keyed by id, a widget pinned to "Eating
    /// out" would come back pointing at whichever budget inherited that number.
    let id: String
    let name: String

    /// Sentinel for "Any budget that needs attention". Real ids are v4 uuids,
    /// so this can never collide with one.
    static let automaticId: String = "automatic"

    static var automatic: BudgetChoice {
        BudgetChoice(id: automaticId, name: String(localized: "Any budget that needs attention"))
    }

    var isAutomatic: Bool { id == BudgetChoice.automaticId }

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Budget")
    }

    static var defaultQuery = BudgetChoiceQuery()

    var displayRepresentation: DisplayRepresentation {
        if isAutomatic {
            return DisplayRepresentation(
                title: "\(name)",
                subtitle: "Always shows whichever budget is closest to its limit."
            )
        }
        return DisplayRepresentation(title: "\(name)")
    }
}

struct BudgetChoiceQuery: EntityQuery {
    /// Everything the widget editor offers, automatic first.
    func suggestedEntities() async throws -> [BudgetChoice] {
        var choices: [BudgetChoice] = [.automatic]
        if let payload = BudgetPayloadStore.load() {
            choices.append(contentsOf: payload.budgets.map { BudgetChoice(id: $0.uuid, name: $0.name) })
        }
        return choices
    }

    func entities(for identifiers: [String]) async throws -> [BudgetChoice] {
        let payload = BudgetPayloadStore.load()
        return identifiers.map { identifier in
            if identifier == BudgetChoice.automaticId { return .automatic }
            if let match = payload?.budget(uuid: identifier) {
                return BudgetChoice(id: match.uuid, name: match.name)
            }
            // The budget was deleted. Resolving to nil here would make the
            // configuration look unset; keeping the id alive lets the widget
            // render the "budget is gone" state the contract asks for.
            return BudgetChoice(
                id: identifier,
                name: payload?.labels.missingBudget ?? BudgetLabels.fallback.missingBudget
            )
        }
    }

    func defaultResult() async -> BudgetChoice? {
        .automatic
    }
}

// MARK: - Roll-up configuration

struct BudgetRollupConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Budgets" }
    static var description: IntentDescription {
        IntentDescription("How many budgets need attention, and the one that needs it most.")
    }

    @Parameter(title: "Hide amounts", default: false)
    var hideAmounts: Bool
}

// MARK: - Pinned configuration

struct BudgetPinnedConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Budget" }
    static var description: IntentDescription {
        IntentDescription("Track a single budget.")
    }

    @Parameter(title: "Budget")
    var budget: BudgetChoice?

    @Parameter(title: "Hide amounts", default: false)
    var hideAmounts: Bool

    /// `nil` (never configured) behaves as automatic, so a freshly dropped
    /// widget shows something useful immediately.
    ///
    /// There is deliberately no migration for a configuration written while
    /// budgets were keyed by ObjectBox id: that keying never shipped, so the
    /// only devices holding one are ours. Where such a configuration lands is
    /// unverified — AppIntents may fail to decode the old `Int` identifier and
    /// arrive `nil`, or surface it as `"7"` / `"-1"`, which `entities(for:)`
    /// keeps alive as the "budget is gone" state. Re-pick the budget on any
    /// test device that shows it.
    var selectedUuid: String {
        budget?.id ?? BudgetChoice.automaticId
    }
}
