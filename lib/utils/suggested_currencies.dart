import "package:flow/entity/account.dart";
import "package:flow/objectbox.dart";
import "package:flow/prefs/transitive.dart";
import "package:flow/services/user_preferences.dart";

/// Currency codes to offer first in currency pickers, deduped
List<String> suggestedCurrencies({String? accountCurrency}) {
  final List<Account> accounts = ObjectBox().box<Account>().getAll();

  return {
    ?accountCurrency,
    UserPreferencesService().primaryCurrency,
    ...TransitiveLocalPreferences().getRecentForeignCurrencies(),
    ...accounts
        .where((account) => !account.archived)
        .map((account) => account.currency),
  }.toList();
}
