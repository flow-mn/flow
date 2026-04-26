import "package:flow/entity/transaction.dart";
import "package:flutter/foundation.dart";

/// Tracks transactions selected for bulk operations.
class TransactionsSelectionController extends ChangeNotifier {
  final Set<String> _uuids = {};

  bool _hasAnyTransfer = false;
  bool _hasAnyDeleted = false;
  bool _hasAnyAlive = false;
  bool _hasAnyPending = false;
  bool _hasAnyNonPending = false;
  Set<String> _currencies = {};

  bool get active => _uuids.isNotEmpty;
  int get count => _uuids.length;
  Set<String> get selectedUuids => Set.unmodifiable(_uuids);

  bool get hasAnyTransfer => _hasAnyTransfer;
  bool get allDeleted => _hasAnyDeleted && !_hasAnyAlive;
  bool get allPending => _hasAnyPending && !_hasAnyNonPending;

  Set<String> get currencies => Set.unmodifiable(_currencies);

  bool contains(String uuid) => _uuids.contains(uuid);

  void toggle(Transaction transaction) {
    final String uuid = transaction.uuid;
    final String? partnerUuid =
        transaction.extensions.transfer?.relatedTransactionUuid;

    if (_uuids.contains(uuid)) {
      _uuids.remove(uuid);
      if (partnerUuid != null) _uuids.remove(partnerUuid);
    } else {
      _uuids.add(uuid);
      if (partnerUuid != null) _uuids.add(partnerUuid);
    }

    notifyListeners();
  }

  void addAll(Iterable<Transaction> transactions) {
    for (final Transaction t in transactions) {
      _uuids.add(t.uuid);
      final String? partnerUuid = t.extensions.transfer?.relatedTransactionUuid;
      if (partnerUuid != null) _uuids.add(partnerUuid);
    }
    notifyListeners();
  }

  void clear() {
    if (_uuids.isEmpty) return;
    _uuids.clear();
    _hasAnyTransfer = false;
    _hasAnyDeleted = false;
    _hasAnyAlive = false;
    _hasAnyPending = false;
    _hasAnyNonPending = false;
    _currencies = {};
    notifyListeners();
  }

  /// Refreshes derived flags from the most recent visible transactions.
  void recomputeFromVisible(Iterable<Transaction> visible) {
    bool transfer = false;
    bool deleted = false;
    bool alive = false;
    bool pending = false;
    bool nonPending = false;
    final Set<String> currencies = {};
    final Set<String> stillVisible = {};

    for (final Transaction t in visible) {
      if (!_uuids.contains(t.uuid)) continue;
      stillVisible.add(t.uuid);

      if (t.isTransfer) transfer = true;
      if (t.isDeleted == true) {
        deleted = true;
      } else {
        alive = true;
      }
      if (t.isPending == true && t.isDeleted != true) {
        pending = true;
      } else {
        nonPending = true;
      }
      currencies.add(t.currency);
    }

    bool changed = false;
    if (stillVisible.length != _uuids.length) {
      _uuids
        ..clear()
        ..addAll(stillVisible);
      changed = true;
    }
    if (transfer != _hasAnyTransfer) {
      _hasAnyTransfer = transfer;
      changed = true;
    }
    if (deleted != _hasAnyDeleted) {
      _hasAnyDeleted = deleted;
      changed = true;
    }
    if (alive != _hasAnyAlive) {
      _hasAnyAlive = alive;
      changed = true;
    }
    if (pending != _hasAnyPending) {
      _hasAnyPending = pending;
      changed = true;
    }
    if (nonPending != _hasAnyNonPending) {
      _hasAnyNonPending = nonPending;
      changed = true;
    }
    if (!setEquals(currencies, _currencies)) {
      _currencies = currencies;
      changed = true;
    }

    if (changed) notifyListeners();
  }
}
