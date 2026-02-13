import "dart:io";

import "package:flow/data/transaction_programmable_object.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/services/external_toasts.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/utils/ios/get_siri_transactions.dart";
import "package:logging/logging.dart";

final Logger _log = Logger("SiriPendingService");

class SiriPendingService {
  static SiriPendingService? _instance;

  factory SiriPendingService() => _instance ??= SiriPendingService._internal();

  SiriPendingService._internal() {
    // Constructor
  }

  Future<void> resolveSiriTransactions() async {
    try {
      if (!Platform.isIOS) {
        _log.fine("Not on iOS, skipping Siri transactions resolution");
        return;
      }

      final bool markPendingAllTransactions =
          UserPreferencesService().scansPendingThresholdInHours == 0;

      final List<TransactionProgrammableObject> transactions =
          await getSiriTransactions();

      int saved = 0;

      for (final TransactionProgrammableObject transaction in transactions) {
        try {
          transaction.save(
            extraTags: [Transaction.importedFromSiriTag],
            isPendingOverride: markPendingAllTransactions,
          );
          saved++;
        } catch (e, stackTrace) {
          _log.severe(
            "Failed to save transaction from Siri: $transaction",
            e,
            stackTrace,
          );
        }
      }
      if (saved > 0) {
        ExternalToastsService().addToast(
          "transaction.external.added.from".tr("Siri"),
          .success,
        );
      }
      _log.info(
        "Successfully imported $saved out of ${transactions.length} transactions from Siri",
      );
    } catch (e, stackTrace) {
      _log.severe("Failed to resolve Siri transactions", e, stackTrace);
    }
  }
}
