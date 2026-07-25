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
    let id: Int
    let name: String

    /// Sentinel id for "Any budget that needs attention". Real `Budget.id`s are
    /// ObjectBox ids and always positive.
    static let automaticId: Int = -1

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
            choices.append(contentsOf: payload.budgets.map { BudgetChoice(id: $0.id, name: $0.name) })
        }
        return choices
    }

    func entities(for identifiers: [Int]) async throws -> [BudgetChoice] {
        let payload = BudgetPayloadStore.load()
        return identifiers.map { identifier in
            if identifier == BudgetChoice.automaticId { return .automatic }
            if let match = payload?.budgets.first(where: { $0.id == identifier }) {
                return BudgetChoice(id: match.id, name: match.name)
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
    var selectedId: Int {
        budget?.id ?? BudgetChoice.automaticId
    }
}
