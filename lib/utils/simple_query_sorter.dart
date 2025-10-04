import "package:flow/data/currencies.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction_tag.dart";
import "package:fuzzywuzzy/fuzzywuzzy.dart";

List<T> simpleSortByQuery<T>(List<T> items, String query) {
  final String normalizedQuery = query.trim().toLowerCase();

  if (normalizedQuery.isEmpty) return items;

  return extractAllSorted<T>(
    query: normalizedQuery,
    choices: items,
    getter: (item) => switch (item) {
      Account account => account.name.toLowerCase(),
      Category category => category.name.toLowerCase(),
      TransactionTag tag => tag.title.toLowerCase(),
      CurrencyData currencyData => [
        currencyData.code,
        currencyData.name,
        currencyData.country,
      ].join(" "),
      _ => item.toString().toLowerCase(),
    },
  ).map((result) => result.choice).toList();
}
