import 'package:flow/data/flow_icon.dart';
import 'package:flow/entity/_base.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/entity/transaction.dart';
import 'package:flow/entity/transaction/extensions/base.dart';
import 'package:flow/entity/transaction/extensions/default/transfer.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/objectbox.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:objectbox/objectbox.dart';
import 'package:uuid/uuid.dart';

part "account.g.dart";

@Entity()
@JsonSerializable()
class Account implements EntityBase {
  @JsonKey(includeFromJson: false, includeToJson: false)
  int id;

  @override
  @Unique()
  String uuid;

  @Property(type: PropertyType.date)
  DateTime createdDate;

  @Property(type: PropertyType.date)
  DateTime lastUsedDate;

  @Unique()
  String name;

  /// Currency code complying with [ISO 4217](https://en.wikipedia.org/wiki/ISO_4217)
  String currency;

  @Backlink('account')
  @JsonKey(includeFromJson: false, includeToJson: false)
  final transactions = ToMany<Transaction>();

  String iconCode;

  bool excludeFromTotalBalance;

  /// Returns [IconData] from [iconCode]
  ///
  /// Falls back to [Symbols.error_rounded]
  @JsonKey(includeFromJson: false, includeToJson: false)
  @Transient()
  FlowIconData get icon {
    try {
      return FlowIconData.parse(iconCode);
    } catch (e) {
      return FlowIconData.emoji("🤷");
    }
  }

  /// Returns current balance. This is calculated by summing up every single transaction
  @Transient()
  double get balance {
    return transactions.fold<double>(
      0,
      (previousValue, element) => previousValue + element.amount,
    );
  }

  Account({
    this.id = 0,
    required this.name,
    required this.currency,
    required this.iconCode,
    this.excludeFromTotalBalance = false,
    DateTime? createdDate,
  })  : createdDate = createdDate ?? DateTime.now(),
        lastUsedDate = createdDate ?? DateTime.now(),
        uuid = const Uuid().v4();

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
  Map<String, dynamic> toJson() => _$AccountToJson(this);

  void updateBalance(double targetBalance, {String? title}) {
    final double delta = targetBalance - balance;

    transactions.add(
      Transaction(
        amount: delta,
        title: title,
        currency: currency,
      ),
    );

    ObjectBox().box<Account>().put(this);
  }

  /// Returns object ids from `box.put`
  ///
  /// First transaction represents money going out of [this] account
  ///
  /// Second transaction represents money incoming to the target account
  (int from, int to) transferTo({
    required Account targetAccount,
    required double amount,
  }) {
    if (amount <= 0) {
      throw ArgumentError.value(
          amount, "amount", "Must be positive, and more than zero");
    }

    final Transfer transferData = Transfer(
      fromAccountUuid: uuid,
      toAccountUuid: targetAccount.uuid,
    );

    final int fromTransaction = createTransaction(
      amount: -amount,
      title: "transaction.transfer.to".tr(targetAccount.name),
      extensions: [transferData],
    );
    final int toTransaction = createTransaction(
      amount: amount,
      title: "transaction.transfer.from".tr(name),
      extensions: [transferData],
    );

    return (fromTransaction, toTransaction);
  }

  /// Returns object id
  ///
  /// (From box.put())
  int createTransaction({
    required double amount,
    DateTime? transactionDate,
    String? title,
    Category? category,
    List<TransactionExtension>? extensions,
  }) {
    Transaction value = Transaction(
      amount: amount,
      currency: currency,
      title: title,
      transactionDate: transactionDate,
    )..setCategory(category);

    if (extensions != null && extensions.isNotEmpty) {
      value.setExtra(extensions);
    }

    transactions.add(value);
    return ObjectBox().box<Account>().put(this);
  }
}
