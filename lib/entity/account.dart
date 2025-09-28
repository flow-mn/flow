import "package:flow/data/flow_icon.dart";
import "package:flow/data/money.dart";
import "package:flow/entity/_base.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/theme/color_themes/registry.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/utils/json/utc_datetime_converter.dart";
import "package:json_annotation/json_annotation.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";
import "package:objectbox/objectbox.dart";
import "package:uuid/uuid.dart";

part "account.g.dart";

@Entity()
@JsonSerializable(explicitToJson: true, converters: [UTCDateTimeConverter()])
class Account implements EntityBase {
  @JsonKey(includeFromJson: false, includeToJson: false)
  int id;

  @override
  @Unique()
  String uuid;

  @Property(type: PropertyType.date)
  DateTime createdDate;

  static const int maxNameLength = 48;

  @Unique()
  String name;

  /// Currency code complying with [ISO 4217](https://en.wikipedia.org/wiki/ISO_4217)
  String currency;

  /// Exclusive to [AccountType.creditLine] accounts
  double? creditLimit;

  int sortOrder;

  String type;

  @Transient()
  @JsonKey(includeFromJson: false, includeToJson: false)
  AccountType get accountType {
    try {
      return AccountType.values.firstWhere((element) => element.value == type);
    } catch (e) {
      return AccountType.debit;
    }
  }

  set accountType(AccountType value) {
    type = value.value;
  }

  @Backlink("account")
  @JsonKey(includeFromJson: false, includeToJson: false)
  final transactions = ToMany<Transaction>();

  bool excludeFromTotalBalance;
  bool archived;

  String? colorSchemeName;

  @Transient()
  FlowColorScheme? get colorScheme => getThemeStrict(colorSchemeName);

  String iconCode;

  @Transient()
  @JsonKey(includeFromJson: false, includeToJson: false)
  FlowIconData get icon {
    try {
      return FlowIconData.parse(iconCode);
    } catch (e) {
      return FlowIconData.icon(Symbols.wallet_rounded);
    }
  }

  @Transient()
  @JsonKey(includeFromJson: false, includeToJson: false)
  Money get balance => balanceAt(DateTime.now());

  Money balanceAt(DateTime anchor) => Money(
    transactions
        .where((element) => !element.transactionDate.isFutureAnchored(anchor))
        .nonPending
        .nonDeleted
        .fold<double>(
          0,
          (previousValue, element) => previousValue + element.amount,
        ),
    currency,
  );

  Account({
    this.id = 0,
    required this.name,
    required this.currency,
    required this.iconCode,
    this.creditLimit,
    this.colorSchemeName,
    this.excludeFromTotalBalance = false,
    this.archived = false,
    this.sortOrder = -1,
    this.type = AccountType.debitValue,
    DateTime? createdDate,
  }) : createdDate = createdDate ?? DateTime.now(),
       uuid = const Uuid().v4();

  Account.preset({
    required this.name,
    required this.currency,
    required this.iconCode,
    required this.uuid,
    this.creditLimit,
    this.colorSchemeName,
    this.type = AccountType.debitValue,
    this.excludeFromTotalBalance = false,
  }) : archived = false,
       sortOrder = -1,
       id = -1,
       createdDate = DateTime.now();

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
  Map<String, dynamic> toJson() => _$AccountToJson(this);
}

@JsonEnum(valueField: "value")
enum AccountType with LocalizedEnum {
  /// Accounts that hold money. This includes but not limited to: checking,
  /// savings, cash.
  debit(debitValue),

  /// Just another name for debit. I added this just because I thought people
  /// would ask me to add this if I added [AccountType]
  savings(savingsValue),

  /// Accounts that are not holding money but rather a credit line. This
  /// includes but not limited to: credit cards
  creditLine(creditLineValue),

  /// Accounts that are not holding money but rather a credit line. This
  /// includes but not limited to: credit cards
  loan(loanValue),

  /// Assets. IDK, I don't have any assets yet.
  asset(assetValue),

  /// If people want more distinction.
  other(otherValue);

  static const String debitValue = "debit";
  static const String savingsValue = "savings";
  static const String creditLineValue = "creditLine";
  static const String loanValue = "loan";
  static const String assetValue = "asset";
  static const String otherValue = "other";

  final String value;

  const AccountType(this.value);

  @override
  String get localizationEnumValue => name;
  @override
  String get localizationEnumName => "AccountType";

  bool get preferExcludeFromBalance => switch (this) {
    AccountType.debit => false,
    AccountType.savings => false,
    AccountType.creditLine => true,
    AccountType.asset => true,
    AccountType.loan => true,
    AccountType.other => false,
  };

  bool get showCreditLimit => switch (this) {
    AccountType.creditLine => true,
    _ => false,
  };
}
