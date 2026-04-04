import AppIntents

enum TransactionType: String, Codable, AppEnum {
    case expense
    case income
    case transfer

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Transaction Type"

    static var caseDisplayRepresentations: [TransactionType: DisplayRepresentation] = [
        .expense: "Expense",
        .income: "Income",
        .transfer: "Transfer",
    ]

    var localizedName: LocalizedStringResource {
        switch self {
        case .expense: "Expense"
        case .income: "Income"
        case .transfer: "Transfer"
        }
    }
}