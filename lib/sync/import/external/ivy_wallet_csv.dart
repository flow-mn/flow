import "package:flow/sync/import/base.dart";
import "package:flow/sync/import/import_csv.dart";
import "package:flow/sync/model/external/ivy_wallet_csv.dart";
import "package:flutter/foundation.dart";

class IvyWalletCsvImporter extends Importer<IvyWalletCsv> {
  @override
  final IvyWalletCsv data;

  @override
  final ValueNotifier<ImportCSVProgress> progressNotifier = ValueNotifier(
    ImportCSVProgress.waitingConfirmation,
  );

  IvyWalletCsvImporter(this.data);

  @override
  Future<String?> execute({bool ignoreSafetyBackupFail = false}) {
    // TODO: implement execute
    throw UnimplementedError();
  }
}
