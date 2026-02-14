import AppIntents

struct RecordTransactionIntent: AppIntent {
    static var title: LocalizedStringResource = "Record an Expense"
    static var description: IntentDescription = "Log expenses"

    @Parameter(title: "Account", description: "Exact name, or UUID of the target account.")
    var account: String

    @Parameter(title: "Amount", description: "Expense amount. Sign doesn't matter.")
    var amount: Double

    @Parameter(title: "Category", description: "Exact name, or UUID of the target account.")
    var category: String
    
    @Parameter(title: "Notes", description: "Transaction notes. Markdown supported.")
    var notes: String
    
    @Parameter(title: "Title", description: "Transaction title.")
    var title: String

    static var openAppWhenRun = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let tx = RecordedTransaction(type: .expense, amount: amount, title: title, fromAccount: account, category: category, notes: notes)
        try RecordedTransactionService.append(tx)
        return .result(dialog: "Expense recorded ✅")
    }
}
