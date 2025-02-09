import "package:flow/data/money.dart";
import "package:flow/entity/_base.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction/extensions/base.dart";
import "package:flow/entity/transaction/wrapper.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/utils/extensions.dart";
import "package:flow/utils/json/utc_datetime_converter.dart";
import "package:json_annotation/json_annotation.dart";
import "package:objectbox/objectbox.dart";

part "transaction.g.dart";

@Entity()
@JsonSerializable(
  explicitToJson: true,
  converters: [UTCDateTimeConverter()],
)
class Transaction implements EntityBase {
  @JsonKey(includeFromJson: false, includeToJson: false)
  int id;

  @override
  @Unique()
  String uuid;

  @Property(type: PropertyType.date)
  DateTime createdDate;

  @Property(type: PropertyType.date)
  DateTime transactionDate;

  bool? isDeleted;

  @Property(type: PropertyType.date)
  DateTime? deletedDate;

  static const int maxTitleLength = 256;

  String? title;

  static const int maxDescriptionLength = 65536;
  String? description;

  double amount;

  bool? isPending;

  /// Currency code complying with [ISO 4217](https://en.wikipedia.org/wiki/ISO_4217)
  String currency;

  @Transient()
  Money get money => Money(amount, currency);

  // Later, we might need to reference the parent transaction in order to
  // edit them as one. This can be useful, for example, in loan/savings with
  // interest. Then again, showing the interest and the base as two separate
  // transactions might not be good idea.
  //
  /// Subtype of transaction
  @Property()
  String? subtype;

  @Transient()
  @JsonKey(includeFromJson: false, includeToJson: false)
  TransactionSubtype? get transactionSubtype => subtype == null
      ? null
      : TransactionSubtype.values
          .where((element) => element.value == (subtype!))
          .firstOrNull;

  @Transient()
  set transactionSubtype(TransactionSubtype? value) {
    subtype = value?.value;
  }

  /// Extra information related to the transaction
  ///
  /// We plan to use this field as place to store data for custom extensions.
  /// e.g., We can use JSON, and give each extension ability to edit their "key"
  /// in this field. (ensuring no collision between extensions)
  String? extra;

  @Transient()
  @JsonKey(includeFromJson: false, includeToJson: false)
  ExtensionsWrapper get extensions => ExtensionsWrapper.parse(extra);

  @Transient()
  set extensions(ExtensionsWrapper newValue) {
    extra = newValue.serialize();
  }

  void addExtensions(Iterable<TransactionExtension> newExtensions) {
    extensions = extensions.getMerged(newExtensions.toList());
  }

  @Transient()
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get isTransfer => extensions.transfer != null;

  @Transient()
  @JsonKey(includeFromJson: false, includeToJson: false)
  TransactionType get type {
    if (isTransfer) return TransactionType.transfer;

    return amount.isNegative ? TransactionType.expense : TransactionType.income;
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  final category = ToOne<Category>();

  @Transient()
  String? _categoryUuid;

  String? get categoryUuid => _categoryUuid ?? category.target?.uuid;

  set categoryUuid(String? value) {
    _categoryUuid = value;
  }

  /// This won't be saved until you call `Box.put()`
  void setCategory(Category? newCategory) {
    category.target = newCategory;
    categoryUuid = newCategory?.uuid;
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  final account = ToOne<Account>();

  @Transient()
  String? _accountUuid;

  String? get accountUuid => _accountUuid ?? account.target?.uuid;

  set accountUuid(String? value) {
    _accountUuid = value;
  }

  /// This won't be saved until you call `Box.put()`
  void setAccount(Account? newAccount) {
    // TODO (sadespresso): When changing currencies, we can either ask
    // the user to re-enter the amount, or do an automatic conversion

    if (currency != newAccount?.currency) {
      throw Exception("Cannot convert between currencies");
    }

    account.target = newAccount;
    accountUuid = newAccount?.uuid;
    currency = newAccount?.currency ?? currency;
  }

  Transaction({
    this.id = 0,
    this.title,
    this.description,
    this.subtype,
    this.isPending,
    required this.amount,
    required this.currency,
    required this.uuid,
    DateTime? transactionDate,
    DateTime? createdDate,
  })  : createdDate = createdDate ?? DateTime.now(),
        transactionDate = transactionDate ?? createdDate ?? DateTime.now();

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}

@JsonEnum(valueField: "value")
enum TransactionType implements LocalizedEnum {
  transfer("transfer"),
  income("income"),
  expense("expense");

  final String value;

  const TransactionType(this.value);

  @override
  String get localizationEnumValue => name;
  @override
  String get localizationEnumName => "TransactionType";

  static TransactionType? fromJson(Map json) {
    return TransactionType.values
        .firstWhereOrNull((element) => element.value == json["value"]);
  }

  Map<String, dynamic> toJson() => {"value": value};
}

@JsonEnum(valueField: "value")
enum TransactionSubtype implements LocalizedEnum {
  transactionFee("transactionFee"),
  givenLoan("loan.given"),
  receivedLoan("loan.received"),
  updateBalance("updateBalance");

  final String value;

  const TransactionSubtype(this.value);

  @override
  String get localizationEnumValue => name;
  @override
  String get localizationEnumName => "TransactionSubtype";
}
