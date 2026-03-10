import AppIntents

struct RecordTransactionIntent: AppIntent {
    static var title: LocalizedStringResource = "Record an Expense"
    static var description: IntentDescription = "Log expenses"

    @Parameter(title: "Account", description: "Exact name, or UUID of the target account.")
    var account: String?

    @Parameter(title: "Amount", description: "Expense amount. Sign doesn't matter.")
    var amount: String

    @Parameter(title: "Category", description: "Exact name, or UUID of the target account.")
    var category: String?

    @Parameter(title: "Notes", description: "Transaction notes. Markdown supported.")
    var notes: String?

    @Parameter(title: "Title", description: "Transaction title.")
    var title: String?

    @Parameter(title: "Date of transaction", description: "Date.")
    var transactionDate: Date?

    static var openAppWhenRun = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal

        let parsedAmount: Double
        if let number = formatter.number(from: amount) {
            parsedAmount = number.doubleValue
        } else {
            let digitsOnly = amount.replacingOccurrences(
                of: "[^0-9]", with: "", options: .regularExpression)
            let hadDecimalSeparator = amount.contains(formatter.decimalSeparator)
            guard let fallbackNumber = Double(digitsOnly) else {
                throw NSError(domain: "InvalidAmount", code: 1)
            }
            parsedAmount = fallbackNumber / (hadDecimalSeparator ? 100 : 1)
        }
        let tx = RecordedTransaction(
            transactionDate: transactionDate ?? Date(), type: .expense, amount: parsedAmount,
            title: title?.trimmingCharacters(in: .whitespacesAndNewlines), fromAccount: account?.trimmingCharacters(in: .whitespacesAndNewlines), category: category?.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes)
        try RecordedTransactionService.append(tx)
        return .result(dialog: "Expense recorded ✅")
    }
}
