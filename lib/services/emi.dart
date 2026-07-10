import "package:flow/entity/emi.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction/extensions/default/emi.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:uuid/uuid.dart";

class EmiService {
  static EmiService? _instance;

  factory EmiService() => _instance ??= EmiService._internal();

  EmiService._internal() {
    // Constructor
  }

  Future<Emi?> getOne(int id) async {
    return ObjectBox().box<Emi>().getAsync(id);
  }

  Emi? getOneSync(int id) {
    return ObjectBox().box<Emi>().get(id);
  }

  Future<List<Emi>> getAll() async {
    return ObjectBox().box<Emi>().getAllAsync();
  }

  List<Emi> getAllSync() {
    return ObjectBox().box<Emi>().getAll();
  }

  Future<int> upsertOne(Emi emi) async {
    return ObjectBox().box<Emi>().putAsync(emi);
  }

  int upsertOneSync(Emi emi) {
    return ObjectBox().box<Emi>().put(emi);
  }

  Future<bool> deleteOne(int id) async {
    return ObjectBox().box<Emi>().removeAsync(id);
  }

  bool deleteOneSync(int id) {
    return ObjectBox().box<Emi>().remove(id);
  }

  Future<void> payInstallment(Emi emi) async {
    if (emi.status == "completed") {
      throw Exception("EMI is already completed");
    }

    emi.paidInstallments += 1;
    emi.remainingInstallments -= 1;
    emi.paidAmount += emi.installmentAmount;

    // Ensure remaining amount does not go below zero
    final calculatedRemaining = emi.totalAmount - emi.paidAmount;
    emi.remainingAmount = calculatedRemaining > 0.0 ? calculatedRemaining : 0.0;

    final isFinished =
        emi.paidInstallments >= emi.totalInstallments ||
        emi.remainingAmount <= 0.0;

    DateTime? paidDate = emi.nextDueDate ?? DateTime.now();

    if (isFinished) {
      emi.status = "completed";
      emi.remainingAmount = 0.0;
      emi.remainingInstallments = 0;
      emi.nextDueDate = null;
    } else {
      if (emi.nextDueDate != null) {
        emi.nextDueDate = DateTime(
          emi.nextDueDate!.year,
          emi.nextDueDate!.month + 1,
          emi.nextDueDate!.day,
        );
      } else {
        emi.nextDueDate = DateTime(
          emi.startDate.year,
          emi.startDate.month + 1,
          emi.startDate.day,
        );
      }
    }

    final Transaction transaction = Transaction(
      uuid: const Uuid().v4(),
      title: "${emi.title} (${emi.paidInstallments}/${emi.totalInstallments})",
      amount: -emi.installmentAmount, // Expenses are negative
      currency: emi.account.target?.currency ?? "USD",
      transactionDate: paidDate,
    );

    transaction.setAccount(emi.account.target);
    transaction.setCategory(emi.category.target);
    transaction.extensions = transaction.extensions.getMerged([
      EmiExtension(uuid: const Uuid().v4(), emiUuid: emi.uuid),
    ]);

    // Put both Emi and Transaction in the store
    ObjectBox().store.runInTransaction(TxMode.write, () {
      ObjectBox().box<Emi>().put(emi);
      ObjectBox().box<Transaction>().put(transaction);
    });
  }
}
