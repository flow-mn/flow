import Foundation

struct RecordedTransaction: Codable {
    let id: UUID
    let transactionDate: Date
    let type: TransactionType
    let amount: Double
    let title: String?
    let notes: String?
    let fromAccount: String?
    let toAccount: String?
    let category: String?

    init(
        id: UUID = UUID(),
        transactionDate: Date = Date(),
        type: TransactionType = .expense,
        amount: Double,
        title: String? = nil,
        fromAccount: String? = nil,
        toAccount: String? = nil,
        category: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.transactionDate = transactionDate
        self.type = type
        self.amount = amount
        self.title = title
        self.notes = notes
        self.fromAccount = fromAccount
        self.toAccount = toAccount
        self.category = category
    }
}
