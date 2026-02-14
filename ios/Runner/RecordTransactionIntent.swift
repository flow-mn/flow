import AppIntents

struct RecordTransactionIntent: AppIntent {
    static var title: LocalizedStringResource = "Record an Expense"
    static var description: IntentDescription = "Log expenses"

    @Parameter(title: "Account", description: "Exact name, or UUID of the target account")
    var account: String

    @Parameter(title: "Amount", description: "Expense amount. Sign doesn't matter.")
    var amount: Double

    @Parameter(title: "Category", description: "Exact name, or UUID of the target account")
    var category: String

    static var openAppWhenRun = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let tx = RecordedTransaction(type: .expense, amount: amount, fromAccount: account, category: category)
        try RecordedTransactionService.append(tx)
        return .result(dialog: "Recorded transaction for \(account): $\(amount) in category \(category).")
    }
}
