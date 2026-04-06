import AppIntents

enum TransactionType: String, Codable {
    case expense
    case income
    case transfer
}

enum SelectableTransactionType: String, AppEnum {
    case expense
    case income

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(stringLiteral: "Transaction Type")
    }

    static var caseDisplayRepresentations: [SelectableTransactionType: DisplayRepresentation] {
        [
            .expense: DisplayRepresentation(title: "Expense"),
            .income: DisplayRepresentation(title: "Income"),
        ]
    }

    var transactionType: TransactionType {
        switch self {
        case .expense: return .expense
        case .income: return .income
        }
    }
}