import "package:flow/data/currencies.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:fuzzywuzzy/fuzzywuzzy.dart";

List<T> simpleSortByQuery<T>(List<T> items, String query) {
  final String normalizedQuery = query.trim().toLowerCase();

  if (normalizedQuery.isEmpty) return items;

  return extractAllSorted<T>(
    query: normalizedQuery,
    choices: items,
    getter: (item) {
      if (item case Category category) {
        return category.name;
      }

      if (item case Account account) {
        return account.name;
      }

      if (item case CurrencyData currencyData) {
        return [
          currencyData.code,
          currencyData.name,
          currencyData.country,
        ].join(" ");
      }

      return item.toString();
    },
  ).map((result) => result.choice).toList();
}
