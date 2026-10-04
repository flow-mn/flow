import "package:flow/data/exchange_rates.dart";
import "package:flow/data/insights/insight_adapter.dart";
import "package:flow/data/insights/insight_engine.dart";
import "package:flow/entity/recurring_transaction.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction/extensions/default/recurring.dart";
import "package:flow/entity/transaction/extensions/default/transfer.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  final ExchangeRates rates = ExchangeRates(
    date: DateTime(2026, 9, 25),
    baseCurrency: "USD",
    rates: const {"usd": 1, "eur": 0.5, "mnt": 3500},
  );

  int counter = 0;

  Transaction transaction(
    double amount, {
    String currency = "USD",
    String? title,
    bool? isPending,
    bool? isDeleted,
  }) => Transaction(
    amount: amount,
    currency: currency,
    title: title,
    isPending: isPending,
    uuid: "tx-${counter++}",
    transactionDate: DateTime.utc(2026, 9, 10, 12),
  )..isDeleted = isDeleted;

  ({List<InsightTransaction> transactions, bool hasMissingRates}) adapt(
    List<Transaction> transactions, {
    ExchangeRates? withRates,
  }) => insightTransactionsOf(
    transactions,
    primaryCurrency: "USD",
    rates: withRates,
  );

  test("converts other currencies to the primary one", () {
    final result = adapt([
      transaction(-10.0, currency: "EUR"),
      transaction(-7000.0, currency: "MNT"),
      transaction(-3.0),
    ], withRates: rates);

    expect(result.hasMissingRates, isFalse);
    expect(result.transactions.map((item) => item.amount), [-20.0, -2.0, -3.0]);
  });

  test("skips and flags what can't be converted", () {
    final withoutRates = adapt([
      transaction(-10.0, currency: "EUR"),
      transaction(-3.0),
    ]);
    final unknownRate = adapt([
      transaction(-10.0, currency: "JPY"),
    ], withRates: rates);

    expect(withoutRates.transactions.single.amount, -3.0);
    expect(withoutRates.hasMissingRates, isTrue);
    expect(unknownRate.transactions, isEmpty);
    expect(unknownRate.hasMissingRates, isTrue);
  });

  test("leaves out deleted, pending and transfers", () {
    final Transaction transfer = transaction(-50.0)
      ..addExtensions([
        Transfer(
          uuid: "transfer",
          fromAccountUuid: "a",
          toAccountUuid: "b",
          relatedTransactionUuid: "other",
        ),
      ]);

    final result = adapt([
      transaction(-1.0, isDeleted: true),
      transaction(-2.0, isPending: true),
      transfer,
      transaction(-4.0, isDeleted: false, isPending: false),
    ], withRates: rates);

    expect(result.transactions.single.amount, -4.0);
    expect(result.hasMissingRates, isFalse);
  });

  test("carries title, local date and the recurring link", () {
    final Transaction generated = transaction(-11.99, title: "Spotify")
      ..addExtensions([
        Recurring(
          uuid: "recurring-1",
          initialTransactionDate: DateTime(2026, 1, 3),
        ),
      ]);

    final InsightTransaction item = adapt([generated]).transactions.single;

    expect(item.uuid, generated.uuid);
    expect(item.title, "Spotify");
    expect(item.recurringUuid, "recurring-1");
    expect(item.date.isUtc, isFalse);
    expect(item.date, DateTime.utc(2026, 9, 10, 12).toLocal());
  });

  test("recurring templates: active, non-transfer, converted", () {
    RecurringTransaction recurring(
      Transaction template, {
      bool disabled = false,
      String? transferTo,
    }) => RecurringTransaction(
      rules: const [],
      range: "",
      jsonTransactionTemplate: "",
      disabled: disabled,
      transferToAccountUuid: transferTo,
    )..template = template;

    final List<InsightRecurringTemplate> templates = insightTemplatesOf(
      [
        recurring(transaction(-15.0, currency: "EUR", title: "Netflix")),
        recurring(transaction(-9.0, title: "Old"), disabled: true),
        recurring(transaction(-100.0, title: "Savings"), transferTo: "b"),
        recurring(transaction(-5.0, currency: "JPY", title: "Unknown")),
        RecurringTransaction(
          rules: const [],
          range: "",
          jsonTransactionTemplate: "not json",
        ),
      ],
      primaryCurrency: "USD",
      rates: rates,
    );

    expect(templates.single.title, "Netflix");
    expect(templates.single.amount, -30.0);
  });
}
