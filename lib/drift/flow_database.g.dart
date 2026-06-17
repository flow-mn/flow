// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flow_database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts
    with TableInfo<$AccountsTable, DbAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creditLimitMeta = const VerificationMeta(
    'creditLimit',
  );
  @override
  late final GeneratedColumn<double> creditLimit = GeneratedColumn<double>(
    'credit_limit',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(-1),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _excludeFromTotalBalanceMeta =
      const VerificationMeta('excludeFromTotalBalance');
  @override
  late final GeneratedColumn<bool> excludeFromTotalBalance =
      GeneratedColumn<bool>(
        'exclude_from_total_balance',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("exclude_from_total_balance" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _colorSchemeNameMeta = const VerificationMeta(
    'colorSchemeName',
  );
  @override
  late final GeneratedColumn<String> colorSchemeName = GeneratedColumn<String>(
    'color_scheme_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconCodeMeta = const VerificationMeta(
    'iconCode',
  );
  @override
  late final GeneratedColumn<String> iconCode = GeneratedColumn<String>(
    'icon_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdDate =
      GeneratedColumn<String>(
        'created_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($AccountsTable.$convertercreatedDate);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($AccountsTable.$converterupdatedAtn);
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedDate =
      GeneratedColumn<String>(
        'deleted_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($AccountsTable.$converterdeletedDaten);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    currency,
    creditLimit,
    sortOrder,
    type,
    excludeFromTotalBalance,
    archived,
    colorSchemeName,
    iconCode,
    createdDate,
    updatedAt,
    isDeleted,
    deletedDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbAccount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('credit_limit')) {
      context.handle(
        _creditLimitMeta,
        creditLimit.isAcceptableOrUnknown(
          data['credit_limit']!,
          _creditLimitMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('exclude_from_total_balance')) {
      context.handle(
        _excludeFromTotalBalanceMeta,
        excludeFromTotalBalance.isAcceptableOrUnknown(
          data['exclude_from_total_balance']!,
          _excludeFromTotalBalanceMeta,
        ),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('color_scheme_name')) {
      context.handle(
        _colorSchemeNameMeta,
        colorSchemeName.isAcceptableOrUnknown(
          data['color_scheme_name']!,
          _colorSchemeNameMeta,
        ),
      );
    }
    if (data.containsKey('icon_code')) {
      context.handle(
        _iconCodeMeta,
        iconCode.isAcceptableOrUnknown(data['icon_code']!, _iconCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_iconCodeMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbAccount(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      creditLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}credit_limit'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      excludeFromTotalBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}exclude_from_total_balance'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      colorSchemeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_scheme_name'],
      ),
      iconCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_code'],
      )!,
      createdDate: $AccountsTable.$convertercreatedDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_date'],
        )!,
      ),
      updatedAt: $AccountsTable.$converterupdatedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        ),
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      ),
      deletedDate: $AccountsTable.$converterdeletedDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_date'],
        ),
      ),
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedDate =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterupdatedAtn =
      NullAwareTypeConverter.wrap($converterupdatedAt);
  static TypeConverter<DateTime, String> $converterdeletedDate =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedDaten =
      NullAwareTypeConverter.wrap($converterdeletedDate);
}

class DbAccount extends DataClass implements Insertable<DbAccount> {
  final String id;
  final String name;
  final String currency;
  final double? creditLimit;
  final int sortOrder;
  final String type;
  final bool excludeFromTotalBalance;
  final bool archived;
  final String? colorSchemeName;
  final String iconCode;
  final DateTime createdDate;
  final DateTime? updatedAt;
  final bool? isDeleted;
  final DateTime? deletedDate;
  const DbAccount({
    required this.id,
    required this.name,
    required this.currency,
    this.creditLimit,
    required this.sortOrder,
    required this.type,
    required this.excludeFromTotalBalance,
    required this.archived,
    this.colorSchemeName,
    required this.iconCode,
    required this.createdDate,
    this.updatedAt,
    this.isDeleted,
    this.deletedDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || creditLimit != null) {
      map['credit_limit'] = Variable<double>(creditLimit);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['type'] = Variable<String>(type);
    map['exclude_from_total_balance'] = Variable<bool>(excludeFromTotalBalance);
    map['archived'] = Variable<bool>(archived);
    if (!nullToAbsent || colorSchemeName != null) {
      map['color_scheme_name'] = Variable<String>(colorSchemeName);
    }
    map['icon_code'] = Variable<String>(iconCode);
    {
      map['created_date'] = Variable<String>(
        $AccountsTable.$convertercreatedDate.toSql(createdDate),
      );
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(
        $AccountsTable.$converterupdatedAtn.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || isDeleted != null) {
      map['is_deleted'] = Variable<bool>(isDeleted);
    }
    if (!nullToAbsent || deletedDate != null) {
      map['deleted_date'] = Variable<String>(
        $AccountsTable.$converterdeletedDaten.toSql(deletedDate),
      );
    }
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name),
      currency: Value(currency),
      creditLimit: creditLimit == null && nullToAbsent
          ? const Value.absent()
          : Value(creditLimit),
      sortOrder: Value(sortOrder),
      type: Value(type),
      excludeFromTotalBalance: Value(excludeFromTotalBalance),
      archived: Value(archived),
      colorSchemeName: colorSchemeName == null && nullToAbsent
          ? const Value.absent()
          : Value(colorSchemeName),
      iconCode: Value(iconCode),
      createdDate: Value(createdDate),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      isDeleted: isDeleted == null && nullToAbsent
          ? const Value.absent()
          : Value(isDeleted),
      deletedDate: deletedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedDate),
    );
  }

  factory DbAccount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbAccount(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      currency: serializer.fromJson<String>(json['currency']),
      creditLimit: serializer.fromJson<double?>(json['creditLimit']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      type: serializer.fromJson<String>(json['type']),
      excludeFromTotalBalance: serializer.fromJson<bool>(
        json['excludeFromTotalBalance'],
      ),
      archived: serializer.fromJson<bool>(json['archived']),
      colorSchemeName: serializer.fromJson<String?>(json['colorSchemeName']),
      iconCode: serializer.fromJson<String>(json['iconCode']),
      createdDate: serializer.fromJson<DateTime>(json['createdDate']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool?>(json['isDeleted']),
      deletedDate: serializer.fromJson<DateTime?>(json['deletedDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'currency': serializer.toJson<String>(currency),
      'creditLimit': serializer.toJson<double?>(creditLimit),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'type': serializer.toJson<String>(type),
      'excludeFromTotalBalance': serializer.toJson<bool>(
        excludeFromTotalBalance,
      ),
      'archived': serializer.toJson<bool>(archived),
      'colorSchemeName': serializer.toJson<String?>(colorSchemeName),
      'iconCode': serializer.toJson<String>(iconCode),
      'createdDate': serializer.toJson<DateTime>(createdDate),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'isDeleted': serializer.toJson<bool?>(isDeleted),
      'deletedDate': serializer.toJson<DateTime?>(deletedDate),
    };
  }

  DbAccount copyWith({
    String? id,
    String? name,
    String? currency,
    Value<double?> creditLimit = const Value.absent(),
    int? sortOrder,
    String? type,
    bool? excludeFromTotalBalance,
    bool? archived,
    Value<String?> colorSchemeName = const Value.absent(),
    String? iconCode,
    DateTime? createdDate,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<bool?> isDeleted = const Value.absent(),
    Value<DateTime?> deletedDate = const Value.absent(),
  }) => DbAccount(
    id: id ?? this.id,
    name: name ?? this.name,
    currency: currency ?? this.currency,
    creditLimit: creditLimit.present ? creditLimit.value : this.creditLimit,
    sortOrder: sortOrder ?? this.sortOrder,
    type: type ?? this.type,
    excludeFromTotalBalance:
        excludeFromTotalBalance ?? this.excludeFromTotalBalance,
    archived: archived ?? this.archived,
    colorSchemeName: colorSchemeName.present
        ? colorSchemeName.value
        : this.colorSchemeName,
    iconCode: iconCode ?? this.iconCode,
    createdDate: createdDate ?? this.createdDate,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    isDeleted: isDeleted.present ? isDeleted.value : this.isDeleted,
    deletedDate: deletedDate.present ? deletedDate.value : this.deletedDate,
  );
  DbAccount copyWithCompanion(AccountsCompanion data) {
    return DbAccount(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      currency: data.currency.present ? data.currency.value : this.currency,
      creditLimit: data.creditLimit.present
          ? data.creditLimit.value
          : this.creditLimit,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      type: data.type.present ? data.type.value : this.type,
      excludeFromTotalBalance: data.excludeFromTotalBalance.present
          ? data.excludeFromTotalBalance.value
          : this.excludeFromTotalBalance,
      archived: data.archived.present ? data.archived.value : this.archived,
      colorSchemeName: data.colorSchemeName.present
          ? data.colorSchemeName.value
          : this.colorSchemeName,
      iconCode: data.iconCode.present ? data.iconCode.value : this.iconCode,
      createdDate: data.createdDate.present
          ? data.createdDate.value
          : this.createdDate,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      deletedDate: data.deletedDate.present
          ? data.deletedDate.value
          : this.deletedDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbAccount(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('currency: $currency, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('type: $type, ')
          ..write('excludeFromTotalBalance: $excludeFromTotalBalance, ')
          ..write('archived: $archived, ')
          ..write('colorSchemeName: $colorSchemeName, ')
          ..write('iconCode: $iconCode, ')
          ..write('createdDate: $createdDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedDate: $deletedDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    currency,
    creditLimit,
    sortOrder,
    type,
    excludeFromTotalBalance,
    archived,
    colorSchemeName,
    iconCode,
    createdDate,
    updatedAt,
    isDeleted,
    deletedDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbAccount &&
          other.id == this.id &&
          other.name == this.name &&
          other.currency == this.currency &&
          other.creditLimit == this.creditLimit &&
          other.sortOrder == this.sortOrder &&
          other.type == this.type &&
          other.excludeFromTotalBalance == this.excludeFromTotalBalance &&
          other.archived == this.archived &&
          other.colorSchemeName == this.colorSchemeName &&
          other.iconCode == this.iconCode &&
          other.createdDate == this.createdDate &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.deletedDate == this.deletedDate);
}

class AccountsCompanion extends UpdateCompanion<DbAccount> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> currency;
  final Value<double?> creditLimit;
  final Value<int> sortOrder;
  final Value<String> type;
  final Value<bool> excludeFromTotalBalance;
  final Value<bool> archived;
  final Value<String?> colorSchemeName;
  final Value<String> iconCode;
  final Value<DateTime> createdDate;
  final Value<DateTime?> updatedAt;
  final Value<bool?> isDeleted;
  final Value<DateTime?> deletedDate;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.currency = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.type = const Value.absent(),
    this.excludeFromTotalBalance = const Value.absent(),
    this.archived = const Value.absent(),
    this.colorSchemeName = const Value.absent(),
    this.iconCode = const Value.absent(),
    this.createdDate = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String currency,
    this.creditLimit = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required String type,
    this.excludeFromTotalBalance = const Value.absent(),
    this.archived = const Value.absent(),
    this.colorSchemeName = const Value.absent(),
    required String iconCode,
    required DateTime createdDate,
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       currency = Value(currency),
       type = Value(type),
       iconCode = Value(iconCode),
       createdDate = Value(createdDate);
  static Insertable<DbAccount> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? currency,
    Expression<double>? creditLimit,
    Expression<int>? sortOrder,
    Expression<String>? type,
    Expression<bool>? excludeFromTotalBalance,
    Expression<bool>? archived,
    Expression<String>? colorSchemeName,
    Expression<String>? iconCode,
    Expression<String>? createdDate,
    Expression<String>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? deletedDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (currency != null) 'currency': currency,
      if (creditLimit != null) 'credit_limit': creditLimit,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (type != null) 'type': type,
      if (excludeFromTotalBalance != null)
        'exclude_from_total_balance': excludeFromTotalBalance,
      if (archived != null) 'archived': archived,
      if (colorSchemeName != null) 'color_scheme_name': colorSchemeName,
      if (iconCode != null) 'icon_code': iconCode,
      if (createdDate != null) 'created_date': createdDate,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (deletedDate != null) 'deleted_date': deletedDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? currency,
    Value<double?>? creditLimit,
    Value<int>? sortOrder,
    Value<String>? type,
    Value<bool>? excludeFromTotalBalance,
    Value<bool>? archived,
    Value<String?>? colorSchemeName,
    Value<String>? iconCode,
    Value<DateTime>? createdDate,
    Value<DateTime?>? updatedAt,
    Value<bool?>? isDeleted,
    Value<DateTime?>? deletedDate,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      creditLimit: creditLimit ?? this.creditLimit,
      sortOrder: sortOrder ?? this.sortOrder,
      type: type ?? this.type,
      excludeFromTotalBalance:
          excludeFromTotalBalance ?? this.excludeFromTotalBalance,
      archived: archived ?? this.archived,
      colorSchemeName: colorSchemeName ?? this.colorSchemeName,
      iconCode: iconCode ?? this.iconCode,
      createdDate: createdDate ?? this.createdDate,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedDate: deletedDate ?? this.deletedDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (creditLimit.present) {
      map['credit_limit'] = Variable<double>(creditLimit.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (excludeFromTotalBalance.present) {
      map['exclude_from_total_balance'] = Variable<bool>(
        excludeFromTotalBalance.value,
      );
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (colorSchemeName.present) {
      map['color_scheme_name'] = Variable<String>(colorSchemeName.value);
    }
    if (iconCode.present) {
      map['icon_code'] = Variable<String>(iconCode.value);
    }
    if (createdDate.present) {
      map['created_date'] = Variable<String>(
        $AccountsTable.$convertercreatedDate.toSql(createdDate.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $AccountsTable.$converterupdatedAtn.toSql(updatedAt.value),
      );
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (deletedDate.present) {
      map['deleted_date'] = Variable<String>(
        $AccountsTable.$converterdeletedDaten.toSql(deletedDate.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('currency: $currency, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('type: $type, ')
          ..write('excludeFromTotalBalance: $excludeFromTotalBalance, ')
          ..write('archived: $archived, ')
          ..write('colorSchemeName: $colorSchemeName, ')
          ..write('iconCode: $iconCode, ')
          ..write('createdDate: $createdDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedDate: $deletedDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, DbCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconCodeMeta = const VerificationMeta(
    'iconCode',
  );
  @override
  late final GeneratedColumn<String> iconCode = GeneratedColumn<String>(
    'icon_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorSchemeNameMeta = const VerificationMeta(
    'colorSchemeName',
  );
  @override
  late final GeneratedColumn<String> colorSchemeName = GeneratedColumn<String>(
    'color_scheme_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdDate =
      GeneratedColumn<String>(
        'created_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($CategoriesTable.$convertercreatedDate);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($CategoriesTable.$converterupdatedAtn);
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedDate =
      GeneratedColumn<String>(
        'deleted_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($CategoriesTable.$converterdeletedDaten);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    iconCode,
    colorSchemeName,
    createdDate,
    updatedAt,
    isDeleted,
    deletedDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_code')) {
      context.handle(
        _iconCodeMeta,
        iconCode.isAcceptableOrUnknown(data['icon_code']!, _iconCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_iconCodeMeta);
    }
    if (data.containsKey('color_scheme_name')) {
      context.handle(
        _colorSchemeNameMeta,
        colorSchemeName.isAcceptableOrUnknown(
          data['color_scheme_name']!,
          _colorSchemeNameMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_code'],
      )!,
      colorSchemeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_scheme_name'],
      ),
      createdDate: $CategoriesTable.$convertercreatedDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_date'],
        )!,
      ),
      updatedAt: $CategoriesTable.$converterupdatedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        ),
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      ),
      deletedDate: $CategoriesTable.$converterdeletedDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_date'],
        ),
      ),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedDate =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterupdatedAtn =
      NullAwareTypeConverter.wrap($converterupdatedAt);
  static TypeConverter<DateTime, String> $converterdeletedDate =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedDaten =
      NullAwareTypeConverter.wrap($converterdeletedDate);
}

class DbCategory extends DataClass implements Insertable<DbCategory> {
  final String id;
  final String name;
  final String iconCode;
  final String? colorSchemeName;
  final DateTime createdDate;
  final DateTime? updatedAt;
  final bool? isDeleted;
  final DateTime? deletedDate;
  const DbCategory({
    required this.id,
    required this.name,
    required this.iconCode,
    this.colorSchemeName,
    required this.createdDate,
    this.updatedAt,
    this.isDeleted,
    this.deletedDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon_code'] = Variable<String>(iconCode);
    if (!nullToAbsent || colorSchemeName != null) {
      map['color_scheme_name'] = Variable<String>(colorSchemeName);
    }
    {
      map['created_date'] = Variable<String>(
        $CategoriesTable.$convertercreatedDate.toSql(createdDate),
      );
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(
        $CategoriesTable.$converterupdatedAtn.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || isDeleted != null) {
      map['is_deleted'] = Variable<bool>(isDeleted);
    }
    if (!nullToAbsent || deletedDate != null) {
      map['deleted_date'] = Variable<String>(
        $CategoriesTable.$converterdeletedDaten.toSql(deletedDate),
      );
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      iconCode: Value(iconCode),
      colorSchemeName: colorSchemeName == null && nullToAbsent
          ? const Value.absent()
          : Value(colorSchemeName),
      createdDate: Value(createdDate),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      isDeleted: isDeleted == null && nullToAbsent
          ? const Value.absent()
          : Value(isDeleted),
      deletedDate: deletedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedDate),
    );
  }

  factory DbCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbCategory(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconCode: serializer.fromJson<String>(json['iconCode']),
      colorSchemeName: serializer.fromJson<String?>(json['colorSchemeName']),
      createdDate: serializer.fromJson<DateTime>(json['createdDate']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool?>(json['isDeleted']),
      deletedDate: serializer.fromJson<DateTime?>(json['deletedDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'iconCode': serializer.toJson<String>(iconCode),
      'colorSchemeName': serializer.toJson<String?>(colorSchemeName),
      'createdDate': serializer.toJson<DateTime>(createdDate),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'isDeleted': serializer.toJson<bool?>(isDeleted),
      'deletedDate': serializer.toJson<DateTime?>(deletedDate),
    };
  }

  DbCategory copyWith({
    String? id,
    String? name,
    String? iconCode,
    Value<String?> colorSchemeName = const Value.absent(),
    DateTime? createdDate,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<bool?> isDeleted = const Value.absent(),
    Value<DateTime?> deletedDate = const Value.absent(),
  }) => DbCategory(
    id: id ?? this.id,
    name: name ?? this.name,
    iconCode: iconCode ?? this.iconCode,
    colorSchemeName: colorSchemeName.present
        ? colorSchemeName.value
        : this.colorSchemeName,
    createdDate: createdDate ?? this.createdDate,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    isDeleted: isDeleted.present ? isDeleted.value : this.isDeleted,
    deletedDate: deletedDate.present ? deletedDate.value : this.deletedDate,
  );
  DbCategory copyWithCompanion(CategoriesCompanion data) {
    return DbCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconCode: data.iconCode.present ? data.iconCode.value : this.iconCode,
      colorSchemeName: data.colorSchemeName.present
          ? data.colorSchemeName.value
          : this.colorSchemeName,
      createdDate: data.createdDate.present
          ? data.createdDate.value
          : this.createdDate,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      deletedDate: data.deletedDate.present
          ? data.deletedDate.value
          : this.deletedDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconCode: $iconCode, ')
          ..write('colorSchemeName: $colorSchemeName, ')
          ..write('createdDate: $createdDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedDate: $deletedDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    iconCode,
    colorSchemeName,
    createdDate,
    updatedAt,
    isDeleted,
    deletedDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconCode == this.iconCode &&
          other.colorSchemeName == this.colorSchemeName &&
          other.createdDate == this.createdDate &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.deletedDate == this.deletedDate);
}

class CategoriesCompanion extends UpdateCompanion<DbCategory> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> iconCode;
  final Value<String?> colorSchemeName;
  final Value<DateTime> createdDate;
  final Value<DateTime?> updatedAt;
  final Value<bool?> isDeleted;
  final Value<DateTime?> deletedDate;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconCode = const Value.absent(),
    this.colorSchemeName = const Value.absent(),
    this.createdDate = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String iconCode,
    this.colorSchemeName = const Value.absent(),
    required DateTime createdDate,
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       iconCode = Value(iconCode),
       createdDate = Value(createdDate);
  static Insertable<DbCategory> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? iconCode,
    Expression<String>? colorSchemeName,
    Expression<String>? createdDate,
    Expression<String>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? deletedDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconCode != null) 'icon_code': iconCode,
      if (colorSchemeName != null) 'color_scheme_name': colorSchemeName,
      if (createdDate != null) 'created_date': createdDate,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (deletedDate != null) 'deleted_date': deletedDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? iconCode,
    Value<String?>? colorSchemeName,
    Value<DateTime>? createdDate,
    Value<DateTime?>? updatedAt,
    Value<bool?>? isDeleted,
    Value<DateTime?>? deletedDate,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      colorSchemeName: colorSchemeName ?? this.colorSchemeName,
      createdDate: createdDate ?? this.createdDate,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedDate: deletedDate ?? this.deletedDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconCode.present) {
      map['icon_code'] = Variable<String>(iconCode.value);
    }
    if (colorSchemeName.present) {
      map['color_scheme_name'] = Variable<String>(colorSchemeName.value);
    }
    if (createdDate.present) {
      map['created_date'] = Variable<String>(
        $CategoriesTable.$convertercreatedDate.toSql(createdDate.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $CategoriesTable.$converterupdatedAtn.toSql(updatedAt.value),
      );
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (deletedDate.present) {
      map['deleted_date'] = Variable<String>(
        $CategoriesTable.$converterdeletedDaten.toSql(deletedDate.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconCode: $iconCode, ')
          ..write('colorSchemeName: $colorSchemeName, ')
          ..write('createdDate: $createdDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedDate: $deletedDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, DbTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPendingMeta = const VerificationMeta(
    'isPending',
  );
  @override
  late final GeneratedColumn<bool> isPending = GeneratedColumn<bool>(
    'is_pending',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pending" IN (0, 1))',
    ),
  );
  static const VerificationMeta _subtypeMeta = const VerificationMeta(
    'subtype',
  );
  @override
  late final GeneratedColumn<String> subtype = GeneratedColumn<String>(
    'subtype',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extraMeta = const VerificationMeta('extra');
  @override
  late final GeneratedColumn<String> extra = GeneratedColumn<String>(
    'extra',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String> extraTags =
      GeneratedColumn<String>(
        'extra_tags',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<String>?>($TransactionsTable.$converterextraTagsn);
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String>
  transactionDate = GeneratedColumn<String>(
    'transaction_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<DateTime>($TransactionsTable.$convertertransactionDate);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdDate =
      GeneratedColumn<String>(
        'created_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($TransactionsTable.$convertercreatedDate);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($TransactionsTable.$converterupdatedAtn);
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedDate =
      GeneratedColumn<String>(
        'deleted_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($TransactionsTable.$converterdeletedDaten);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    amount,
    currency,
    isPending,
    subtype,
    extra,
    extraTags,
    latitude,
    longitude,
    accountId,
    categoryId,
    transactionDate,
    createdDate,
    updatedAt,
    isDeleted,
    deletedDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('is_pending')) {
      context.handle(
        _isPendingMeta,
        isPending.isAcceptableOrUnknown(data['is_pending']!, _isPendingMeta),
      );
    }
    if (data.containsKey('subtype')) {
      context.handle(
        _subtypeMeta,
        subtype.isAcceptableOrUnknown(data['subtype']!, _subtypeMeta),
      );
    }
    if (data.containsKey('extra')) {
      context.handle(
        _extraMeta,
        extra.isAcceptableOrUnknown(data['extra']!, _extraMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      isPending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pending'],
      ),
      subtype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtype'],
      ),
      extra: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extra'],
      ),
      extraTags: $TransactionsTable.$converterextraTagsn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}extra_tags'],
        ),
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      transactionDate: $TransactionsTable.$convertertransactionDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}transaction_date'],
        )!,
      ),
      createdDate: $TransactionsTable.$convertercreatedDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_date'],
        )!,
      ),
      updatedAt: $TransactionsTable.$converterupdatedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        ),
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      ),
      deletedDate: $TransactionsTable.$converterdeletedDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_date'],
        ),
      ),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterextraTags =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $converterextraTagsn =
      NullAwareTypeConverter.wrap($converterextraTags);
  static TypeConverter<DateTime, String> $convertertransactionDate =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, String> $convertercreatedDate =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterupdatedAtn =
      NullAwareTypeConverter.wrap($converterupdatedAt);
  static TypeConverter<DateTime, String> $converterdeletedDate =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedDaten =
      NullAwareTypeConverter.wrap($converterdeletedDate);
}

class DbTransaction extends DataClass implements Insertable<DbTransaction> {
  final String id;
  final String? title;
  final String? description;
  final double amount;
  final String currency;
  final bool? isPending;
  final String? subtype;
  final String? extra;
  final List<String>? extraTags;
  final double? latitude;
  final double? longitude;
  final String? accountId;
  final String? categoryId;
  final DateTime transactionDate;
  final DateTime createdDate;
  final DateTime? updatedAt;
  final bool? isDeleted;
  final DateTime? deletedDate;
  const DbTransaction({
    required this.id,
    this.title,
    this.description,
    required this.amount,
    required this.currency,
    this.isPending,
    this.subtype,
    this.extra,
    this.extraTags,
    this.latitude,
    this.longitude,
    this.accountId,
    this.categoryId,
    required this.transactionDate,
    required this.createdDate,
    this.updatedAt,
    this.isDeleted,
    this.deletedDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['amount'] = Variable<double>(amount);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || isPending != null) {
      map['is_pending'] = Variable<bool>(isPending);
    }
    if (!nullToAbsent || subtype != null) {
      map['subtype'] = Variable<String>(subtype);
    }
    if (!nullToAbsent || extra != null) {
      map['extra'] = Variable<String>(extra);
    }
    if (!nullToAbsent || extraTags != null) {
      map['extra_tags'] = Variable<String>(
        $TransactionsTable.$converterextraTagsn.toSql(extraTags),
      );
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    {
      map['transaction_date'] = Variable<String>(
        $TransactionsTable.$convertertransactionDate.toSql(transactionDate),
      );
    }
    {
      map['created_date'] = Variable<String>(
        $TransactionsTable.$convertercreatedDate.toSql(createdDate),
      );
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(
        $TransactionsTable.$converterupdatedAtn.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || isDeleted != null) {
      map['is_deleted'] = Variable<bool>(isDeleted);
    }
    if (!nullToAbsent || deletedDate != null) {
      map['deleted_date'] = Variable<String>(
        $TransactionsTable.$converterdeletedDaten.toSql(deletedDate),
      );
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      amount: Value(amount),
      currency: Value(currency),
      isPending: isPending == null && nullToAbsent
          ? const Value.absent()
          : Value(isPending),
      subtype: subtype == null && nullToAbsent
          ? const Value.absent()
          : Value(subtype),
      extra: extra == null && nullToAbsent
          ? const Value.absent()
          : Value(extra),
      extraTags: extraTags == null && nullToAbsent
          ? const Value.absent()
          : Value(extraTags),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      transactionDate: Value(transactionDate),
      createdDate: Value(createdDate),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      isDeleted: isDeleted == null && nullToAbsent
          ? const Value.absent()
          : Value(isDeleted),
      deletedDate: deletedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedDate),
    );
  }

  factory DbTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbTransaction(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String?>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      amount: serializer.fromJson<double>(json['amount']),
      currency: serializer.fromJson<String>(json['currency']),
      isPending: serializer.fromJson<bool?>(json['isPending']),
      subtype: serializer.fromJson<String?>(json['subtype']),
      extra: serializer.fromJson<String?>(json['extra']),
      extraTags: serializer.fromJson<List<String>?>(json['extraTags']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      transactionDate: serializer.fromJson<DateTime>(json['transactionDate']),
      createdDate: serializer.fromJson<DateTime>(json['createdDate']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool?>(json['isDeleted']),
      deletedDate: serializer.fromJson<DateTime?>(json['deletedDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String?>(title),
      'description': serializer.toJson<String?>(description),
      'amount': serializer.toJson<double>(amount),
      'currency': serializer.toJson<String>(currency),
      'isPending': serializer.toJson<bool?>(isPending),
      'subtype': serializer.toJson<String?>(subtype),
      'extra': serializer.toJson<String?>(extra),
      'extraTags': serializer.toJson<List<String>?>(extraTags),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'accountId': serializer.toJson<String?>(accountId),
      'categoryId': serializer.toJson<String?>(categoryId),
      'transactionDate': serializer.toJson<DateTime>(transactionDate),
      'createdDate': serializer.toJson<DateTime>(createdDate),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'isDeleted': serializer.toJson<bool?>(isDeleted),
      'deletedDate': serializer.toJson<DateTime?>(deletedDate),
    };
  }

  DbTransaction copyWith({
    String? id,
    Value<String?> title = const Value.absent(),
    Value<String?> description = const Value.absent(),
    double? amount,
    String? currency,
    Value<bool?> isPending = const Value.absent(),
    Value<String?> subtype = const Value.absent(),
    Value<String?> extra = const Value.absent(),
    Value<List<String>?> extraTags = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<String?> accountId = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    DateTime? transactionDate,
    DateTime? createdDate,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<bool?> isDeleted = const Value.absent(),
    Value<DateTime?> deletedDate = const Value.absent(),
  }) => DbTransaction(
    id: id ?? this.id,
    title: title.present ? title.value : this.title,
    description: description.present ? description.value : this.description,
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    isPending: isPending.present ? isPending.value : this.isPending,
    subtype: subtype.present ? subtype.value : this.subtype,
    extra: extra.present ? extra.value : this.extra,
    extraTags: extraTags.present ? extraTags.value : this.extraTags,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    accountId: accountId.present ? accountId.value : this.accountId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    transactionDate: transactionDate ?? this.transactionDate,
    createdDate: createdDate ?? this.createdDate,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    isDeleted: isDeleted.present ? isDeleted.value : this.isDeleted,
    deletedDate: deletedDate.present ? deletedDate.value : this.deletedDate,
  );
  DbTransaction copyWithCompanion(TransactionsCompanion data) {
    return DbTransaction(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      amount: data.amount.present ? data.amount.value : this.amount,
      currency: data.currency.present ? data.currency.value : this.currency,
      isPending: data.isPending.present ? data.isPending.value : this.isPending,
      subtype: data.subtype.present ? data.subtype.value : this.subtype,
      extra: data.extra.present ? data.extra.value : this.extra,
      extraTags: data.extraTags.present ? data.extraTags.value : this.extraTags,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      createdDate: data.createdDate.present
          ? data.createdDate.value
          : this.createdDate,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      deletedDate: data.deletedDate.present
          ? data.deletedDate.value
          : this.deletedDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbTransaction(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('isPending: $isPending, ')
          ..write('subtype: $subtype, ')
          ..write('extra: $extra, ')
          ..write('extraTags: $extraTags, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('createdDate: $createdDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedDate: $deletedDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    amount,
    currency,
    isPending,
    subtype,
    extra,
    extraTags,
    latitude,
    longitude,
    accountId,
    categoryId,
    transactionDate,
    createdDate,
    updatedAt,
    isDeleted,
    deletedDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbTransaction &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.amount == this.amount &&
          other.currency == this.currency &&
          other.isPending == this.isPending &&
          other.subtype == this.subtype &&
          other.extra == this.extra &&
          other.extraTags == this.extraTags &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.accountId == this.accountId &&
          other.categoryId == this.categoryId &&
          other.transactionDate == this.transactionDate &&
          other.createdDate == this.createdDate &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.deletedDate == this.deletedDate);
}

class TransactionsCompanion extends UpdateCompanion<DbTransaction> {
  final Value<String> id;
  final Value<String?> title;
  final Value<String?> description;
  final Value<double> amount;
  final Value<String> currency;
  final Value<bool?> isPending;
  final Value<String?> subtype;
  final Value<String?> extra;
  final Value<List<String>?> extraTags;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> accountId;
  final Value<String?> categoryId;
  final Value<DateTime> transactionDate;
  final Value<DateTime> createdDate;
  final Value<DateTime?> updatedAt;
  final Value<bool?> isDeleted;
  final Value<DateTime?> deletedDate;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.isPending = const Value.absent(),
    this.subtype = const Value.absent(),
    this.extra = const Value.absent(),
    this.extraTags = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.accountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.createdDate = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    required double amount,
    required String currency,
    this.isPending = const Value.absent(),
    this.subtype = const Value.absent(),
    this.extra = const Value.absent(),
    this.extraTags = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.accountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    required DateTime transactionDate,
    required DateTime createdDate,
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : amount = Value(amount),
       currency = Value(currency),
       transactionDate = Value(transactionDate),
       createdDate = Value(createdDate);
  static Insertable<DbTransaction> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<double>? amount,
    Expression<String>? currency,
    Expression<bool>? isPending,
    Expression<String>? subtype,
    Expression<String>? extra,
    Expression<String>? extraTags,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? accountId,
    Expression<String>? categoryId,
    Expression<String>? transactionDate,
    Expression<String>? createdDate,
    Expression<String>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? deletedDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (isPending != null) 'is_pending': isPending,
      if (subtype != null) 'subtype': subtype,
      if (extra != null) 'extra': extra,
      if (extraTags != null) 'extra_tags': extraTags,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (accountId != null) 'account_id': accountId,
      if (categoryId != null) 'category_id': categoryId,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (createdDate != null) 'created_date': createdDate,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (deletedDate != null) 'deleted_date': deletedDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<String?>? title,
    Value<String?>? description,
    Value<double>? amount,
    Value<String>? currency,
    Value<bool?>? isPending,
    Value<String?>? subtype,
    Value<String?>? extra,
    Value<List<String>?>? extraTags,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<String?>? accountId,
    Value<String?>? categoryId,
    Value<DateTime>? transactionDate,
    Value<DateTime>? createdDate,
    Value<DateTime?>? updatedAt,
    Value<bool?>? isDeleted,
    Value<DateTime?>? deletedDate,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      isPending: isPending ?? this.isPending,
      subtype: subtype ?? this.subtype,
      extra: extra ?? this.extra,
      extraTags: extraTags ?? this.extraTags,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      transactionDate: transactionDate ?? this.transactionDate,
      createdDate: createdDate ?? this.createdDate,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedDate: deletedDate ?? this.deletedDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (isPending.present) {
      map['is_pending'] = Variable<bool>(isPending.value);
    }
    if (subtype.present) {
      map['subtype'] = Variable<String>(subtype.value);
    }
    if (extra.present) {
      map['extra'] = Variable<String>(extra.value);
    }
    if (extraTags.present) {
      map['extra_tags'] = Variable<String>(
        $TransactionsTable.$converterextraTagsn.toSql(extraTags.value),
      );
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<String>(
        $TransactionsTable.$convertertransactionDate.toSql(
          transactionDate.value,
        ),
      );
    }
    if (createdDate.present) {
      map['created_date'] = Variable<String>(
        $TransactionsTable.$convertercreatedDate.toSql(createdDate.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $TransactionsTable.$converterupdatedAtn.toSql(updatedAt.value),
      );
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (deletedDate.present) {
      map['deleted_date'] = Variable<String>(
        $TransactionsTable.$converterdeletedDaten.toSql(deletedDate.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('isPending: $isPending, ')
          ..write('subtype: $subtype, ')
          ..write('extra: $extra, ')
          ..write('extraTags: $extraTags, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('createdDate: $createdDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedDate: $deletedDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, DbTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconCodeMeta = const VerificationMeta(
    'iconCode',
  );
  @override
  late final GeneratedColumn<String> iconCode = GeneratedColumn<String>(
    'icon_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorSchemeNameMeta = const VerificationMeta(
    'colorSchemeName',
  );
  @override
  late final GeneratedColumn<String> colorSchemeName = GeneratedColumn<String>(
    'color_scheme_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdDate =
      GeneratedColumn<String>(
        'created_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($TagsTable.$convertercreatedDate);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($TagsTable.$converterupdatedAtn);
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedDate =
      GeneratedColumn<String>(
        'deleted_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($TagsTable.$converterdeletedDaten);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    iconCode,
    colorSchemeName,
    type,
    payload,
    createdDate,
    updatedAt,
    isDeleted,
    deletedDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('icon_code')) {
      context.handle(
        _iconCodeMeta,
        iconCode.isAcceptableOrUnknown(data['icon_code']!, _iconCodeMeta),
      );
    }
    if (data.containsKey('color_scheme_name')) {
      context.handle(
        _colorSchemeNameMeta,
        colorSchemeName.isAcceptableOrUnknown(
          data['color_scheme_name']!,
          _colorSchemeNameMeta,
        ),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbTag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      iconCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_code'],
      ),
      colorSchemeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_scheme_name'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      ),
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      ),
      createdDate: $TagsTable.$convertercreatedDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_date'],
        )!,
      ),
      updatedAt: $TagsTable.$converterupdatedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        ),
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      ),
      deletedDate: $TagsTable.$converterdeletedDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_date'],
        ),
      ),
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedDate =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterupdatedAtn =
      NullAwareTypeConverter.wrap($converterupdatedAt);
  static TypeConverter<DateTime, String> $converterdeletedDate =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedDaten =
      NullAwareTypeConverter.wrap($converterdeletedDate);
}

class DbTag extends DataClass implements Insertable<DbTag> {
  final String id;
  final String title;
  final String? iconCode;
  final String? colorSchemeName;
  final String? type;
  final String? payload;
  final DateTime createdDate;
  final DateTime? updatedAt;
  final bool? isDeleted;
  final DateTime? deletedDate;
  const DbTag({
    required this.id,
    required this.title,
    this.iconCode,
    this.colorSchemeName,
    this.type,
    this.payload,
    required this.createdDate,
    this.updatedAt,
    this.isDeleted,
    this.deletedDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || iconCode != null) {
      map['icon_code'] = Variable<String>(iconCode);
    }
    if (!nullToAbsent || colorSchemeName != null) {
      map['color_scheme_name'] = Variable<String>(colorSchemeName);
    }
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<String>(payload);
    }
    {
      map['created_date'] = Variable<String>(
        $TagsTable.$convertercreatedDate.toSql(createdDate),
      );
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(
        $TagsTable.$converterupdatedAtn.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || isDeleted != null) {
      map['is_deleted'] = Variable<bool>(isDeleted);
    }
    if (!nullToAbsent || deletedDate != null) {
      map['deleted_date'] = Variable<String>(
        $TagsTable.$converterdeletedDaten.toSql(deletedDate),
      );
    }
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      title: Value(title),
      iconCode: iconCode == null && nullToAbsent
          ? const Value.absent()
          : Value(iconCode),
      colorSchemeName: colorSchemeName == null && nullToAbsent
          ? const Value.absent()
          : Value(colorSchemeName),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      payload: payload == null && nullToAbsent
          ? const Value.absent()
          : Value(payload),
      createdDate: Value(createdDate),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      isDeleted: isDeleted == null && nullToAbsent
          ? const Value.absent()
          : Value(isDeleted),
      deletedDate: deletedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedDate),
    );
  }

  factory DbTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbTag(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      iconCode: serializer.fromJson<String?>(json['iconCode']),
      colorSchemeName: serializer.fromJson<String?>(json['colorSchemeName']),
      type: serializer.fromJson<String?>(json['type']),
      payload: serializer.fromJson<String?>(json['payload']),
      createdDate: serializer.fromJson<DateTime>(json['createdDate']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool?>(json['isDeleted']),
      deletedDate: serializer.fromJson<DateTime?>(json['deletedDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'iconCode': serializer.toJson<String?>(iconCode),
      'colorSchemeName': serializer.toJson<String?>(colorSchemeName),
      'type': serializer.toJson<String?>(type),
      'payload': serializer.toJson<String?>(payload),
      'createdDate': serializer.toJson<DateTime>(createdDate),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'isDeleted': serializer.toJson<bool?>(isDeleted),
      'deletedDate': serializer.toJson<DateTime?>(deletedDate),
    };
  }

  DbTag copyWith({
    String? id,
    String? title,
    Value<String?> iconCode = const Value.absent(),
    Value<String?> colorSchemeName = const Value.absent(),
    Value<String?> type = const Value.absent(),
    Value<String?> payload = const Value.absent(),
    DateTime? createdDate,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<bool?> isDeleted = const Value.absent(),
    Value<DateTime?> deletedDate = const Value.absent(),
  }) => DbTag(
    id: id ?? this.id,
    title: title ?? this.title,
    iconCode: iconCode.present ? iconCode.value : this.iconCode,
    colorSchemeName: colorSchemeName.present
        ? colorSchemeName.value
        : this.colorSchemeName,
    type: type.present ? type.value : this.type,
    payload: payload.present ? payload.value : this.payload,
    createdDate: createdDate ?? this.createdDate,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    isDeleted: isDeleted.present ? isDeleted.value : this.isDeleted,
    deletedDate: deletedDate.present ? deletedDate.value : this.deletedDate,
  );
  DbTag copyWithCompanion(TagsCompanion data) {
    return DbTag(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      iconCode: data.iconCode.present ? data.iconCode.value : this.iconCode,
      colorSchemeName: data.colorSchemeName.present
          ? data.colorSchemeName.value
          : this.colorSchemeName,
      type: data.type.present ? data.type.value : this.type,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdDate: data.createdDate.present
          ? data.createdDate.value
          : this.createdDate,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      deletedDate: data.deletedDate.present
          ? data.deletedDate.value
          : this.deletedDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbTag(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('iconCode: $iconCode, ')
          ..write('colorSchemeName: $colorSchemeName, ')
          ..write('type: $type, ')
          ..write('payload: $payload, ')
          ..write('createdDate: $createdDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedDate: $deletedDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    iconCode,
    colorSchemeName,
    type,
    payload,
    createdDate,
    updatedAt,
    isDeleted,
    deletedDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbTag &&
          other.id == this.id &&
          other.title == this.title &&
          other.iconCode == this.iconCode &&
          other.colorSchemeName == this.colorSchemeName &&
          other.type == this.type &&
          other.payload == this.payload &&
          other.createdDate == this.createdDate &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.deletedDate == this.deletedDate);
}

class TagsCompanion extends UpdateCompanion<DbTag> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> iconCode;
  final Value<String?> colorSchemeName;
  final Value<String?> type;
  final Value<String?> payload;
  final Value<DateTime> createdDate;
  final Value<DateTime?> updatedAt;
  final Value<bool?> isDeleted;
  final Value<DateTime?> deletedDate;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.iconCode = const Value.absent(),
    this.colorSchemeName = const Value.absent(),
    this.type = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdDate = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.iconCode = const Value.absent(),
    this.colorSchemeName = const Value.absent(),
    this.type = const Value.absent(),
    this.payload = const Value.absent(),
    required DateTime createdDate,
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : title = Value(title),
       createdDate = Value(createdDate);
  static Insertable<DbTag> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? iconCode,
    Expression<String>? colorSchemeName,
    Expression<String>? type,
    Expression<String>? payload,
    Expression<String>? createdDate,
    Expression<String>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? deletedDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (iconCode != null) 'icon_code': iconCode,
      if (colorSchemeName != null) 'color_scheme_name': colorSchemeName,
      if (type != null) 'type': type,
      if (payload != null) 'payload': payload,
      if (createdDate != null) 'created_date': createdDate,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (deletedDate != null) 'deleted_date': deletedDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? iconCode,
    Value<String?>? colorSchemeName,
    Value<String?>? type,
    Value<String?>? payload,
    Value<DateTime>? createdDate,
    Value<DateTime?>? updatedAt,
    Value<bool?>? isDeleted,
    Value<DateTime?>? deletedDate,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      iconCode: iconCode ?? this.iconCode,
      colorSchemeName: colorSchemeName ?? this.colorSchemeName,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      createdDate: createdDate ?? this.createdDate,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedDate: deletedDate ?? this.deletedDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (iconCode.present) {
      map['icon_code'] = Variable<String>(iconCode.value);
    }
    if (colorSchemeName.present) {
      map['color_scheme_name'] = Variable<String>(colorSchemeName.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdDate.present) {
      map['created_date'] = Variable<String>(
        $TagsTable.$convertercreatedDate.toSql(createdDate.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $TagsTable.$converterupdatedAtn.toSql(updatedAt.value),
      );
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (deletedDate.present) {
      map['deleted_date'] = Variable<String>(
        $TagsTable.$converterdeletedDaten.toSql(deletedDate.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('iconCode: $iconCode, ')
          ..write('colorSchemeName: $colorSchemeName, ')
          ..write('type: $type, ')
          ..write('payload: $payload, ')
          ..write('createdDate: $createdDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedDate: $deletedDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionTagsTable extends TransactionTags
    with TableInfo<$TransactionTagsTable, DbTransactionTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, transactionId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbTransactionTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbTransactionTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbTransactionTag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $TransactionTagsTable createAlias(String alias) {
    return $TransactionTagsTable(attachedDatabase, alias);
  }
}

class DbTransactionTag extends DataClass
    implements Insertable<DbTransactionTag> {
  final String id;
  final String transactionId;
  final String tagId;
  const DbTransactionTag({
    required this.id,
    required this.transactionId,
    required this.tagId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_id'] = Variable<String>(transactionId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  TransactionTagsCompanion toCompanion(bool nullToAbsent) {
    return TransactionTagsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      tagId: Value(tagId),
    );
  }

  factory DbTransactionTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbTransactionTag(
      id: serializer.fromJson<String>(json['id']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionId': serializer.toJson<String>(transactionId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  DbTransactionTag copyWith({
    String? id,
    String? transactionId,
    String? tagId,
  }) => DbTransactionTag(
    id: id ?? this.id,
    transactionId: transactionId ?? this.transactionId,
    tagId: tagId ?? this.tagId,
  );
  DbTransactionTag copyWithCompanion(TransactionTagsCompanion data) {
    return DbTransactionTag(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbTransactionTag(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, transactionId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbTransactionTag &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.tagId == this.tagId);
}

class TransactionTagsCompanion extends UpdateCompanion<DbTransactionTag> {
  final Value<String> id;
  final Value<String> transactionId;
  final Value<String> tagId;
  final Value<int> rowid;
  const TransactionTagsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionTagsCompanion.insert({
    this.id = const Value.absent(),
    required String transactionId,
    required String tagId,
    this.rowid = const Value.absent(),
  }) : transactionId = Value(transactionId),
       tagId = Value(tagId);
  static Insertable<DbTransactionTag> custom({
    Expression<String>? id,
    Expression<String>? transactionId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionTagsCompanion copyWith({
    Value<String>? id,
    Value<String>? transactionId,
    Value<String>? tagId,
    Value<int>? rowid,
  }) {
    return TransactionTagsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionTagsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, DbBudget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rangeMeta = const VerificationMeta('range');
  @override
  late final GeneratedColumn<String> range = GeneratedColumn<String>(
    'range',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _renewAutomaticallyMeta =
      const VerificationMeta('renewAutomatically');
  @override
  late final GeneratedColumn<bool> renewAutomatically = GeneratedColumn<bool>(
    'renew_automatically',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("renew_automatically" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdDate =
      GeneratedColumn<String>(
        'created_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($BudgetsTable.$convertercreatedDate);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($BudgetsTable.$converterupdatedAtn);
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedDate =
      GeneratedColumn<String>(
        'deleted_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($BudgetsTable.$converterdeletedDaten);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    range,
    renewAutomatically,
    amount,
    currency,
    createdDate,
    updatedAt,
    isDeleted,
    deletedDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbBudget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('range')) {
      context.handle(
        _rangeMeta,
        range.isAcceptableOrUnknown(data['range']!, _rangeMeta),
      );
    } else if (isInserting) {
      context.missing(_rangeMeta);
    }
    if (data.containsKey('renew_automatically')) {
      context.handle(
        _renewAutomaticallyMeta,
        renewAutomatically.isAcceptableOrUnknown(
          data['renew_automatically']!,
          _renewAutomaticallyMeta,
        ),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbBudget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbBudget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      range: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}range'],
      )!,
      renewAutomatically: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}renew_automatically'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      createdDate: $BudgetsTable.$convertercreatedDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_date'],
        )!,
      ),
      updatedAt: $BudgetsTable.$converterupdatedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        ),
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      ),
      deletedDate: $BudgetsTable.$converterdeletedDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_date'],
        ),
      ),
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedDate =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterupdatedAtn =
      NullAwareTypeConverter.wrap($converterupdatedAt);
  static TypeConverter<DateTime, String> $converterdeletedDate =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedDaten =
      NullAwareTypeConverter.wrap($converterdeletedDate);
}

class DbBudget extends DataClass implements Insertable<DbBudget> {
  final String id;
  final String name;
  final String range;
  final bool renewAutomatically;
  final double amount;
  final String currency;
  final DateTime createdDate;
  final DateTime? updatedAt;
  final bool? isDeleted;
  final DateTime? deletedDate;
  const DbBudget({
    required this.id,
    required this.name,
    required this.range,
    required this.renewAutomatically,
    required this.amount,
    required this.currency,
    required this.createdDate,
    this.updatedAt,
    this.isDeleted,
    this.deletedDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['range'] = Variable<String>(range);
    map['renew_automatically'] = Variable<bool>(renewAutomatically);
    map['amount'] = Variable<double>(amount);
    map['currency'] = Variable<String>(currency);
    {
      map['created_date'] = Variable<String>(
        $BudgetsTable.$convertercreatedDate.toSql(createdDate),
      );
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(
        $BudgetsTable.$converterupdatedAtn.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || isDeleted != null) {
      map['is_deleted'] = Variable<bool>(isDeleted);
    }
    if (!nullToAbsent || deletedDate != null) {
      map['deleted_date'] = Variable<String>(
        $BudgetsTable.$converterdeletedDaten.toSql(deletedDate),
      );
    }
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      name: Value(name),
      range: Value(range),
      renewAutomatically: Value(renewAutomatically),
      amount: Value(amount),
      currency: Value(currency),
      createdDate: Value(createdDate),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      isDeleted: isDeleted == null && nullToAbsent
          ? const Value.absent()
          : Value(isDeleted),
      deletedDate: deletedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedDate),
    );
  }

  factory DbBudget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbBudget(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      range: serializer.fromJson<String>(json['range']),
      renewAutomatically: serializer.fromJson<bool>(json['renewAutomatically']),
      amount: serializer.fromJson<double>(json['amount']),
      currency: serializer.fromJson<String>(json['currency']),
      createdDate: serializer.fromJson<DateTime>(json['createdDate']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool?>(json['isDeleted']),
      deletedDate: serializer.fromJson<DateTime?>(json['deletedDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'range': serializer.toJson<String>(range),
      'renewAutomatically': serializer.toJson<bool>(renewAutomatically),
      'amount': serializer.toJson<double>(amount),
      'currency': serializer.toJson<String>(currency),
      'createdDate': serializer.toJson<DateTime>(createdDate),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'isDeleted': serializer.toJson<bool?>(isDeleted),
      'deletedDate': serializer.toJson<DateTime?>(deletedDate),
    };
  }

  DbBudget copyWith({
    String? id,
    String? name,
    String? range,
    bool? renewAutomatically,
    double? amount,
    String? currency,
    DateTime? createdDate,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<bool?> isDeleted = const Value.absent(),
    Value<DateTime?> deletedDate = const Value.absent(),
  }) => DbBudget(
    id: id ?? this.id,
    name: name ?? this.name,
    range: range ?? this.range,
    renewAutomatically: renewAutomatically ?? this.renewAutomatically,
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    createdDate: createdDate ?? this.createdDate,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    isDeleted: isDeleted.present ? isDeleted.value : this.isDeleted,
    deletedDate: deletedDate.present ? deletedDate.value : this.deletedDate,
  );
  DbBudget copyWithCompanion(BudgetsCompanion data) {
    return DbBudget(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      range: data.range.present ? data.range.value : this.range,
      renewAutomatically: data.renewAutomatically.present
          ? data.renewAutomatically.value
          : this.renewAutomatically,
      amount: data.amount.present ? data.amount.value : this.amount,
      currency: data.currency.present ? data.currency.value : this.currency,
      createdDate: data.createdDate.present
          ? data.createdDate.value
          : this.createdDate,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      deletedDate: data.deletedDate.present
          ? data.deletedDate.value
          : this.deletedDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbBudget(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('range: $range, ')
          ..write('renewAutomatically: $renewAutomatically, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('createdDate: $createdDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedDate: $deletedDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    range,
    renewAutomatically,
    amount,
    currency,
    createdDate,
    updatedAt,
    isDeleted,
    deletedDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbBudget &&
          other.id == this.id &&
          other.name == this.name &&
          other.range == this.range &&
          other.renewAutomatically == this.renewAutomatically &&
          other.amount == this.amount &&
          other.currency == this.currency &&
          other.createdDate == this.createdDate &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.deletedDate == this.deletedDate);
}

class BudgetsCompanion extends UpdateCompanion<DbBudget> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> range;
  final Value<bool> renewAutomatically;
  final Value<double> amount;
  final Value<String> currency;
  final Value<DateTime> createdDate;
  final Value<DateTime?> updatedAt;
  final Value<bool?> isDeleted;
  final Value<DateTime?> deletedDate;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.range = const Value.absent(),
    this.renewAutomatically = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.createdDate = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String range,
    this.renewAutomatically = const Value.absent(),
    required double amount,
    required String currency,
    required DateTime createdDate,
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       range = Value(range),
       amount = Value(amount),
       currency = Value(currency),
       createdDate = Value(createdDate);
  static Insertable<DbBudget> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? range,
    Expression<bool>? renewAutomatically,
    Expression<double>? amount,
    Expression<String>? currency,
    Expression<String>? createdDate,
    Expression<String>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? deletedDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (range != null) 'range': range,
      if (renewAutomatically != null) 'renew_automatically': renewAutomatically,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (createdDate != null) 'created_date': createdDate,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (deletedDate != null) 'deleted_date': deletedDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? range,
    Value<bool>? renewAutomatically,
    Value<double>? amount,
    Value<String>? currency,
    Value<DateTime>? createdDate,
    Value<DateTime?>? updatedAt,
    Value<bool?>? isDeleted,
    Value<DateTime?>? deletedDate,
    Value<int>? rowid,
  }) {
    return BudgetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      range: range ?? this.range,
      renewAutomatically: renewAutomatically ?? this.renewAutomatically,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      createdDate: createdDate ?? this.createdDate,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedDate: deletedDate ?? this.deletedDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (range.present) {
      map['range'] = Variable<String>(range.value);
    }
    if (renewAutomatically.present) {
      map['renew_automatically'] = Variable<bool>(renewAutomatically.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (createdDate.present) {
      map['created_date'] = Variable<String>(
        $BudgetsTable.$convertercreatedDate.toSql(createdDate.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $BudgetsTable.$converterupdatedAtn.toSql(updatedAt.value),
      );
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (deletedDate.present) {
      map['deleted_date'] = Variable<String>(
        $BudgetsTable.$converterdeletedDaten.toSql(deletedDate.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('range: $range, ')
          ..write('renewAutomatically: $renewAutomatically, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('createdDate: $createdDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedDate: $deletedDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, DbGoal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rangeMeta = const VerificationMeta('range');
  @override
  late final GeneratedColumn<String> range = GeneratedColumn<String>(
    'range',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetBalanceMeta = const VerificationMeta(
    'targetBalance',
  );
  @override
  late final GeneratedColumn<double> targetBalance = GeneratedColumn<double>(
    'target_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconCodeMeta = const VerificationMeta(
    'iconCode',
  );
  @override
  late final GeneratedColumn<String> iconCode = GeneratedColumn<String>(
    'icon_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdDate =
      GeneratedColumn<String>(
        'created_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($GoalsTable.$convertercreatedDate);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($GoalsTable.$converterupdatedAtn);
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedDate =
      GeneratedColumn<String>(
        'deleted_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($GoalsTable.$converterdeletedDaten);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    range,
    targetBalance,
    currency,
    iconCode,
    accountId,
    createdDate,
    updatedAt,
    isDeleted,
    deletedDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbGoal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('range')) {
      context.handle(
        _rangeMeta,
        range.isAcceptableOrUnknown(data['range']!, _rangeMeta),
      );
    }
    if (data.containsKey('target_balance')) {
      context.handle(
        _targetBalanceMeta,
        targetBalance.isAcceptableOrUnknown(
          data['target_balance']!,
          _targetBalanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetBalanceMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('icon_code')) {
      context.handle(
        _iconCodeMeta,
        iconCode.isAcceptableOrUnknown(data['icon_code']!, _iconCodeMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbGoal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbGoal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      range: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}range'],
      ),
      targetBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_balance'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      iconCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_code'],
      ),
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      ),
      createdDate: $GoalsTable.$convertercreatedDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_date'],
        )!,
      ),
      updatedAt: $GoalsTable.$converterupdatedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        ),
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      ),
      deletedDate: $GoalsTable.$converterdeletedDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_date'],
        ),
      ),
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedDate =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterupdatedAtn =
      NullAwareTypeConverter.wrap($converterupdatedAt);
  static TypeConverter<DateTime, String> $converterdeletedDate =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedDaten =
      NullAwareTypeConverter.wrap($converterdeletedDate);
}

class DbGoal extends DataClass implements Insertable<DbGoal> {
  final String id;
  final String name;
  final String? range;
  final double targetBalance;
  final String currency;
  final String? iconCode;
  final String? accountId;
  final DateTime createdDate;
  final DateTime? updatedAt;
  final bool? isDeleted;
  final DateTime? deletedDate;
  const DbGoal({
    required this.id,
    required this.name,
    this.range,
    required this.targetBalance,
    required this.currency,
    this.iconCode,
    this.accountId,
    required this.createdDate,
    this.updatedAt,
    this.isDeleted,
    this.deletedDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || range != null) {
      map['range'] = Variable<String>(range);
    }
    map['target_balance'] = Variable<double>(targetBalance);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || iconCode != null) {
      map['icon_code'] = Variable<String>(iconCode);
    }
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    {
      map['created_date'] = Variable<String>(
        $GoalsTable.$convertercreatedDate.toSql(createdDate),
      );
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(
        $GoalsTable.$converterupdatedAtn.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || isDeleted != null) {
      map['is_deleted'] = Variable<bool>(isDeleted);
    }
    if (!nullToAbsent || deletedDate != null) {
      map['deleted_date'] = Variable<String>(
        $GoalsTable.$converterdeletedDaten.toSql(deletedDate),
      );
    }
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      name: Value(name),
      range: range == null && nullToAbsent
          ? const Value.absent()
          : Value(range),
      targetBalance: Value(targetBalance),
      currency: Value(currency),
      iconCode: iconCode == null && nullToAbsent
          ? const Value.absent()
          : Value(iconCode),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      createdDate: Value(createdDate),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      isDeleted: isDeleted == null && nullToAbsent
          ? const Value.absent()
          : Value(isDeleted),
      deletedDate: deletedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedDate),
    );
  }

  factory DbGoal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbGoal(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      range: serializer.fromJson<String?>(json['range']),
      targetBalance: serializer.fromJson<double>(json['targetBalance']),
      currency: serializer.fromJson<String>(json['currency']),
      iconCode: serializer.fromJson<String?>(json['iconCode']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      createdDate: serializer.fromJson<DateTime>(json['createdDate']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool?>(json['isDeleted']),
      deletedDate: serializer.fromJson<DateTime?>(json['deletedDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'range': serializer.toJson<String?>(range),
      'targetBalance': serializer.toJson<double>(targetBalance),
      'currency': serializer.toJson<String>(currency),
      'iconCode': serializer.toJson<String?>(iconCode),
      'accountId': serializer.toJson<String?>(accountId),
      'createdDate': serializer.toJson<DateTime>(createdDate),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'isDeleted': serializer.toJson<bool?>(isDeleted),
      'deletedDate': serializer.toJson<DateTime?>(deletedDate),
    };
  }

  DbGoal copyWith({
    String? id,
    String? name,
    Value<String?> range = const Value.absent(),
    double? targetBalance,
    String? currency,
    Value<String?> iconCode = const Value.absent(),
    Value<String?> accountId = const Value.absent(),
    DateTime? createdDate,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<bool?> isDeleted = const Value.absent(),
    Value<DateTime?> deletedDate = const Value.absent(),
  }) => DbGoal(
    id: id ?? this.id,
    name: name ?? this.name,
    range: range.present ? range.value : this.range,
    targetBalance: targetBalance ?? this.targetBalance,
    currency: currency ?? this.currency,
    iconCode: iconCode.present ? iconCode.value : this.iconCode,
    accountId: accountId.present ? accountId.value : this.accountId,
    createdDate: createdDate ?? this.createdDate,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    isDeleted: isDeleted.present ? isDeleted.value : this.isDeleted,
    deletedDate: deletedDate.present ? deletedDate.value : this.deletedDate,
  );
  DbGoal copyWithCompanion(GoalsCompanion data) {
    return DbGoal(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      range: data.range.present ? data.range.value : this.range,
      targetBalance: data.targetBalance.present
          ? data.targetBalance.value
          : this.targetBalance,
      currency: data.currency.present ? data.currency.value : this.currency,
      iconCode: data.iconCode.present ? data.iconCode.value : this.iconCode,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      createdDate: data.createdDate.present
          ? data.createdDate.value
          : this.createdDate,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      deletedDate: data.deletedDate.present
          ? data.deletedDate.value
          : this.deletedDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbGoal(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('range: $range, ')
          ..write('targetBalance: $targetBalance, ')
          ..write('currency: $currency, ')
          ..write('iconCode: $iconCode, ')
          ..write('accountId: $accountId, ')
          ..write('createdDate: $createdDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedDate: $deletedDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    range,
    targetBalance,
    currency,
    iconCode,
    accountId,
    createdDate,
    updatedAt,
    isDeleted,
    deletedDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbGoal &&
          other.id == this.id &&
          other.name == this.name &&
          other.range == this.range &&
          other.targetBalance == this.targetBalance &&
          other.currency == this.currency &&
          other.iconCode == this.iconCode &&
          other.accountId == this.accountId &&
          other.createdDate == this.createdDate &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.deletedDate == this.deletedDate);
}

class GoalsCompanion extends UpdateCompanion<DbGoal> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> range;
  final Value<double> targetBalance;
  final Value<String> currency;
  final Value<String?> iconCode;
  final Value<String?> accountId;
  final Value<DateTime> createdDate;
  final Value<DateTime?> updatedAt;
  final Value<bool?> isDeleted;
  final Value<DateTime?> deletedDate;
  final Value<int> rowid;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.range = const Value.absent(),
    this.targetBalance = const Value.absent(),
    this.currency = const Value.absent(),
    this.iconCode = const Value.absent(),
    this.accountId = const Value.absent(),
    this.createdDate = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.range = const Value.absent(),
    required double targetBalance,
    required String currency,
    this.iconCode = const Value.absent(),
    this.accountId = const Value.absent(),
    required DateTime createdDate,
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       targetBalance = Value(targetBalance),
       currency = Value(currency),
       createdDate = Value(createdDate);
  static Insertable<DbGoal> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? range,
    Expression<double>? targetBalance,
    Expression<String>? currency,
    Expression<String>? iconCode,
    Expression<String>? accountId,
    Expression<String>? createdDate,
    Expression<String>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? deletedDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (range != null) 'range': range,
      if (targetBalance != null) 'target_balance': targetBalance,
      if (currency != null) 'currency': currency,
      if (iconCode != null) 'icon_code': iconCode,
      if (accountId != null) 'account_id': accountId,
      if (createdDate != null) 'created_date': createdDate,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (deletedDate != null) 'deleted_date': deletedDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? range,
    Value<double>? targetBalance,
    Value<String>? currency,
    Value<String?>? iconCode,
    Value<String?>? accountId,
    Value<DateTime>? createdDate,
    Value<DateTime?>? updatedAt,
    Value<bool?>? isDeleted,
    Value<DateTime?>? deletedDate,
    Value<int>? rowid,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      range: range ?? this.range,
      targetBalance: targetBalance ?? this.targetBalance,
      currency: currency ?? this.currency,
      iconCode: iconCode ?? this.iconCode,
      accountId: accountId ?? this.accountId,
      createdDate: createdDate ?? this.createdDate,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedDate: deletedDate ?? this.deletedDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (range.present) {
      map['range'] = Variable<String>(range.value);
    }
    if (targetBalance.present) {
      map['target_balance'] = Variable<double>(targetBalance.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (iconCode.present) {
      map['icon_code'] = Variable<String>(iconCode.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (createdDate.present) {
      map['created_date'] = Variable<String>(
        $GoalsTable.$convertercreatedDate.toSql(createdDate.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $GoalsTable.$converterupdatedAtn.toSql(updatedAt.value),
      );
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (deletedDate.present) {
      map['deleted_date'] = Variable<String>(
        $GoalsTable.$converterdeletedDaten.toSql(deletedDate.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('range: $range, ')
          ..write('targetBalance: $targetBalance, ')
          ..write('currency: $currency, ')
          ..write('iconCode: $iconCode, ')
          ..write('accountId: $accountId, ')
          ..write('createdDate: $createdDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedDate: $deletedDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringTransactionsTable extends RecurringTransactions
    with TableInfo<$RecurringTransactionsTable, DbRecurringTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
  );
  static const VerificationMeta _jsonTransactionTemplateMeta =
      const VerificationMeta('jsonTransactionTemplate');
  @override
  late final GeneratedColumn<String> jsonTransactionTemplate =
      GeneratedColumn<String>(
        'json_transaction_template',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _transferToAccountIdMeta =
      const VerificationMeta('transferToAccountId');
  @override
  late final GeneratedColumn<String> transferToAccountId =
      GeneratedColumn<String>(
        'transfer_to_account_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _rangeMeta = const VerificationMeta('range');
  @override
  late final GeneratedColumn<String> range = GeneratedColumn<String>(
    'range',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> rules =
      GeneratedColumn<String>(
        'rules',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>(
        $RecurringTransactionsTable.$converterrules,
      );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String>
  lastGeneratedTransactionDate =
      GeneratedColumn<String>(
        'last_generated_transaction_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>(
        $RecurringTransactionsTable.$converterlastGeneratedTransactionDaten,
      );
  static const VerificationMeta _disabledMeta = const VerificationMeta(
    'disabled',
  );
  @override
  late final GeneratedColumn<bool> disabled = GeneratedColumn<bool>(
    'disabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("disabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdDate =
      GeneratedColumn<String>(
        'created_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>(
        $RecurringTransactionsTable.$convertercreatedDate,
      );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>(
        $RecurringTransactionsTable.$converterupdatedAtn,
      );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedDate =
      GeneratedColumn<String>(
        'deleted_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>(
        $RecurringTransactionsTable.$converterdeletedDaten,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jsonTransactionTemplate,
    transferToAccountId,
    range,
    rules,
    lastGeneratedTransactionDate,
    disabled,
    createdDate,
    updatedAt,
    isDeleted,
    deletedDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbRecurringTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('json_transaction_template')) {
      context.handle(
        _jsonTransactionTemplateMeta,
        jsonTransactionTemplate.isAcceptableOrUnknown(
          data['json_transaction_template']!,
          _jsonTransactionTemplateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_jsonTransactionTemplateMeta);
    }
    if (data.containsKey('transfer_to_account_id')) {
      context.handle(
        _transferToAccountIdMeta,
        transferToAccountId.isAcceptableOrUnknown(
          data['transfer_to_account_id']!,
          _transferToAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('range')) {
      context.handle(
        _rangeMeta,
        range.isAcceptableOrUnknown(data['range']!, _rangeMeta),
      );
    } else if (isInserting) {
      context.missing(_rangeMeta);
    }
    if (data.containsKey('disabled')) {
      context.handle(
        _disabledMeta,
        disabled.isAcceptableOrUnknown(data['disabled']!, _disabledMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbRecurringTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbRecurringTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      jsonTransactionTemplate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json_transaction_template'],
      )!,
      transferToAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transfer_to_account_id'],
      ),
      range: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}range'],
      )!,
      rules: $RecurringTransactionsTable.$converterrules.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}rules'],
        )!,
      ),
      lastGeneratedTransactionDate: $RecurringTransactionsTable
          .$converterlastGeneratedTransactionDaten
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}last_generated_transaction_date'],
            ),
          ),
      disabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}disabled'],
      )!,
      createdDate: $RecurringTransactionsTable.$convertercreatedDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_date'],
        )!,
      ),
      updatedAt: $RecurringTransactionsTable.$converterupdatedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        ),
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      ),
      deletedDate: $RecurringTransactionsTable.$converterdeletedDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_date'],
        ),
      ),
    );
  }

  @override
  $RecurringTransactionsTable createAlias(String alias) {
    return $RecurringTransactionsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterrules =
      const StringListConverter();
  static TypeConverter<DateTime, String>
  $converterlastGeneratedTransactionDate = const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?>
  $converterlastGeneratedTransactionDaten = NullAwareTypeConverter.wrap(
    $converterlastGeneratedTransactionDate,
  );
  static TypeConverter<DateTime, String> $convertercreatedDate =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterupdatedAtn =
      NullAwareTypeConverter.wrap($converterupdatedAt);
  static TypeConverter<DateTime, String> $converterdeletedDate =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedDaten =
      NullAwareTypeConverter.wrap($converterdeletedDate);
}

class DbRecurringTransaction extends DataClass
    implements Insertable<DbRecurringTransaction> {
  final String id;
  final String jsonTransactionTemplate;
  final String? transferToAccountId;
  final String range;
  final List<String> rules;
  final DateTime? lastGeneratedTransactionDate;
  final bool disabled;
  final DateTime createdDate;
  final DateTime? updatedAt;
  final bool? isDeleted;
  final DateTime? deletedDate;
  const DbRecurringTransaction({
    required this.id,
    required this.jsonTransactionTemplate,
    this.transferToAccountId,
    required this.range,
    required this.rules,
    this.lastGeneratedTransactionDate,
    required this.disabled,
    required this.createdDate,
    this.updatedAt,
    this.isDeleted,
    this.deletedDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['json_transaction_template'] = Variable<String>(
      jsonTransactionTemplate,
    );
    if (!nullToAbsent || transferToAccountId != null) {
      map['transfer_to_account_id'] = Variable<String>(transferToAccountId);
    }
    map['range'] = Variable<String>(range);
    {
      map['rules'] = Variable<String>(
        $RecurringTransactionsTable.$converterrules.toSql(rules),
      );
    }
    if (!nullToAbsent || lastGeneratedTransactionDate != null) {
      map['last_generated_transaction_date'] = Variable<String>(
        $RecurringTransactionsTable.$converterlastGeneratedTransactionDaten
            .toSql(lastGeneratedTransactionDate),
      );
    }
    map['disabled'] = Variable<bool>(disabled);
    {
      map['created_date'] = Variable<String>(
        $RecurringTransactionsTable.$convertercreatedDate.toSql(createdDate),
      );
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(
        $RecurringTransactionsTable.$converterupdatedAtn.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || isDeleted != null) {
      map['is_deleted'] = Variable<bool>(isDeleted);
    }
    if (!nullToAbsent || deletedDate != null) {
      map['deleted_date'] = Variable<String>(
        $RecurringTransactionsTable.$converterdeletedDaten.toSql(deletedDate),
      );
    }
    return map;
  }

  RecurringTransactionsCompanion toCompanion(bool nullToAbsent) {
    return RecurringTransactionsCompanion(
      id: Value(id),
      jsonTransactionTemplate: Value(jsonTransactionTemplate),
      transferToAccountId: transferToAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(transferToAccountId),
      range: Value(range),
      rules: Value(rules),
      lastGeneratedTransactionDate:
          lastGeneratedTransactionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastGeneratedTransactionDate),
      disabled: Value(disabled),
      createdDate: Value(createdDate),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      isDeleted: isDeleted == null && nullToAbsent
          ? const Value.absent()
          : Value(isDeleted),
      deletedDate: deletedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedDate),
    );
  }

  factory DbRecurringTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbRecurringTransaction(
      id: serializer.fromJson<String>(json['id']),
      jsonTransactionTemplate: serializer.fromJson<String>(
        json['jsonTransactionTemplate'],
      ),
      transferToAccountId: serializer.fromJson<String?>(
        json['transferToAccountId'],
      ),
      range: serializer.fromJson<String>(json['range']),
      rules: serializer.fromJson<List<String>>(json['rules']),
      lastGeneratedTransactionDate: serializer.fromJson<DateTime?>(
        json['lastGeneratedTransactionDate'],
      ),
      disabled: serializer.fromJson<bool>(json['disabled']),
      createdDate: serializer.fromJson<DateTime>(json['createdDate']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool?>(json['isDeleted']),
      deletedDate: serializer.fromJson<DateTime?>(json['deletedDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'jsonTransactionTemplate': serializer.toJson<String>(
        jsonTransactionTemplate,
      ),
      'transferToAccountId': serializer.toJson<String?>(transferToAccountId),
      'range': serializer.toJson<String>(range),
      'rules': serializer.toJson<List<String>>(rules),
      'lastGeneratedTransactionDate': serializer.toJson<DateTime?>(
        lastGeneratedTransactionDate,
      ),
      'disabled': serializer.toJson<bool>(disabled),
      'createdDate': serializer.toJson<DateTime>(createdDate),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'isDeleted': serializer.toJson<bool?>(isDeleted),
      'deletedDate': serializer.toJson<DateTime?>(deletedDate),
    };
  }

  DbRecurringTransaction copyWith({
    String? id,
    String? jsonTransactionTemplate,
    Value<String?> transferToAccountId = const Value.absent(),
    String? range,
    List<String>? rules,
    Value<DateTime?> lastGeneratedTransactionDate = const Value.absent(),
    bool? disabled,
    DateTime? createdDate,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<bool?> isDeleted = const Value.absent(),
    Value<DateTime?> deletedDate = const Value.absent(),
  }) => DbRecurringTransaction(
    id: id ?? this.id,
    jsonTransactionTemplate:
        jsonTransactionTemplate ?? this.jsonTransactionTemplate,
    transferToAccountId: transferToAccountId.present
        ? transferToAccountId.value
        : this.transferToAccountId,
    range: range ?? this.range,
    rules: rules ?? this.rules,
    lastGeneratedTransactionDate: lastGeneratedTransactionDate.present
        ? lastGeneratedTransactionDate.value
        : this.lastGeneratedTransactionDate,
    disabled: disabled ?? this.disabled,
    createdDate: createdDate ?? this.createdDate,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    isDeleted: isDeleted.present ? isDeleted.value : this.isDeleted,
    deletedDate: deletedDate.present ? deletedDate.value : this.deletedDate,
  );
  DbRecurringTransaction copyWithCompanion(
    RecurringTransactionsCompanion data,
  ) {
    return DbRecurringTransaction(
      id: data.id.present ? data.id.value : this.id,
      jsonTransactionTemplate: data.jsonTransactionTemplate.present
          ? data.jsonTransactionTemplate.value
          : this.jsonTransactionTemplate,
      transferToAccountId: data.transferToAccountId.present
          ? data.transferToAccountId.value
          : this.transferToAccountId,
      range: data.range.present ? data.range.value : this.range,
      rules: data.rules.present ? data.rules.value : this.rules,
      lastGeneratedTransactionDate: data.lastGeneratedTransactionDate.present
          ? data.lastGeneratedTransactionDate.value
          : this.lastGeneratedTransactionDate,
      disabled: data.disabled.present ? data.disabled.value : this.disabled,
      createdDate: data.createdDate.present
          ? data.createdDate.value
          : this.createdDate,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      deletedDate: data.deletedDate.present
          ? data.deletedDate.value
          : this.deletedDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbRecurringTransaction(')
          ..write('id: $id, ')
          ..write('jsonTransactionTemplate: $jsonTransactionTemplate, ')
          ..write('transferToAccountId: $transferToAccountId, ')
          ..write('range: $range, ')
          ..write('rules: $rules, ')
          ..write(
            'lastGeneratedTransactionDate: $lastGeneratedTransactionDate, ',
          )
          ..write('disabled: $disabled, ')
          ..write('createdDate: $createdDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedDate: $deletedDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    jsonTransactionTemplate,
    transferToAccountId,
    range,
    rules,
    lastGeneratedTransactionDate,
    disabled,
    createdDate,
    updatedAt,
    isDeleted,
    deletedDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbRecurringTransaction &&
          other.id == this.id &&
          other.jsonTransactionTemplate == this.jsonTransactionTemplate &&
          other.transferToAccountId == this.transferToAccountId &&
          other.range == this.range &&
          other.rules == this.rules &&
          other.lastGeneratedTransactionDate ==
              this.lastGeneratedTransactionDate &&
          other.disabled == this.disabled &&
          other.createdDate == this.createdDate &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.deletedDate == this.deletedDate);
}

class RecurringTransactionsCompanion
    extends UpdateCompanion<DbRecurringTransaction> {
  final Value<String> id;
  final Value<String> jsonTransactionTemplate;
  final Value<String?> transferToAccountId;
  final Value<String> range;
  final Value<List<String>> rules;
  final Value<DateTime?> lastGeneratedTransactionDate;
  final Value<bool> disabled;
  final Value<DateTime> createdDate;
  final Value<DateTime?> updatedAt;
  final Value<bool?> isDeleted;
  final Value<DateTime?> deletedDate;
  final Value<int> rowid;
  const RecurringTransactionsCompanion({
    this.id = const Value.absent(),
    this.jsonTransactionTemplate = const Value.absent(),
    this.transferToAccountId = const Value.absent(),
    this.range = const Value.absent(),
    this.rules = const Value.absent(),
    this.lastGeneratedTransactionDate = const Value.absent(),
    this.disabled = const Value.absent(),
    this.createdDate = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringTransactionsCompanion.insert({
    this.id = const Value.absent(),
    required String jsonTransactionTemplate,
    this.transferToAccountId = const Value.absent(),
    required String range,
    required List<String> rules,
    this.lastGeneratedTransactionDate = const Value.absent(),
    this.disabled = const Value.absent(),
    required DateTime createdDate,
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : jsonTransactionTemplate = Value(jsonTransactionTemplate),
       range = Value(range),
       rules = Value(rules),
       createdDate = Value(createdDate);
  static Insertable<DbRecurringTransaction> custom({
    Expression<String>? id,
    Expression<String>? jsonTransactionTemplate,
    Expression<String>? transferToAccountId,
    Expression<String>? range,
    Expression<String>? rules,
    Expression<String>? lastGeneratedTransactionDate,
    Expression<bool>? disabled,
    Expression<String>? createdDate,
    Expression<String>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? deletedDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jsonTransactionTemplate != null)
        'json_transaction_template': jsonTransactionTemplate,
      if (transferToAccountId != null)
        'transfer_to_account_id': transferToAccountId,
      if (range != null) 'range': range,
      if (rules != null) 'rules': rules,
      if (lastGeneratedTransactionDate != null)
        'last_generated_transaction_date': lastGeneratedTransactionDate,
      if (disabled != null) 'disabled': disabled,
      if (createdDate != null) 'created_date': createdDate,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (deletedDate != null) 'deleted_date': deletedDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringTransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? jsonTransactionTemplate,
    Value<String?>? transferToAccountId,
    Value<String>? range,
    Value<List<String>>? rules,
    Value<DateTime?>? lastGeneratedTransactionDate,
    Value<bool>? disabled,
    Value<DateTime>? createdDate,
    Value<DateTime?>? updatedAt,
    Value<bool?>? isDeleted,
    Value<DateTime?>? deletedDate,
    Value<int>? rowid,
  }) {
    return RecurringTransactionsCompanion(
      id: id ?? this.id,
      jsonTransactionTemplate:
          jsonTransactionTemplate ?? this.jsonTransactionTemplate,
      transferToAccountId: transferToAccountId ?? this.transferToAccountId,
      range: range ?? this.range,
      rules: rules ?? this.rules,
      lastGeneratedTransactionDate:
          lastGeneratedTransactionDate ?? this.lastGeneratedTransactionDate,
      disabled: disabled ?? this.disabled,
      createdDate: createdDate ?? this.createdDate,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedDate: deletedDate ?? this.deletedDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (jsonTransactionTemplate.present) {
      map['json_transaction_template'] = Variable<String>(
        jsonTransactionTemplate.value,
      );
    }
    if (transferToAccountId.present) {
      map['transfer_to_account_id'] = Variable<String>(
        transferToAccountId.value,
      );
    }
    if (range.present) {
      map['range'] = Variable<String>(range.value);
    }
    if (rules.present) {
      map['rules'] = Variable<String>(
        $RecurringTransactionsTable.$converterrules.toSql(rules.value),
      );
    }
    if (lastGeneratedTransactionDate.present) {
      map['last_generated_transaction_date'] = Variable<String>(
        $RecurringTransactionsTable.$converterlastGeneratedTransactionDaten
            .toSql(lastGeneratedTransactionDate.value),
      );
    }
    if (disabled.present) {
      map['disabled'] = Variable<bool>(disabled.value);
    }
    if (createdDate.present) {
      map['created_date'] = Variable<String>(
        $RecurringTransactionsTable.$convertercreatedDate.toSql(
          createdDate.value,
        ),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $RecurringTransactionsTable.$converterupdatedAtn.toSql(updatedAt.value),
      );
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (deletedDate.present) {
      map['deleted_date'] = Variable<String>(
        $RecurringTransactionsTable.$converterdeletedDaten.toSql(
          deletedDate.value,
        ),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('jsonTransactionTemplate: $jsonTransactionTemplate, ')
          ..write('transferToAccountId: $transferToAccountId, ')
          ..write('range: $range, ')
          ..write('rules: $rules, ')
          ..write(
            'lastGeneratedTransactionDate: $lastGeneratedTransactionDate, ',
          )
          ..write('disabled: $disabled, ')
          ..write('createdDate: $createdDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedDate: $deletedDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, DbAttachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdDate =
      GeneratedColumn<String>(
        'created_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($AttachmentsTable.$convertercreatedDate);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($AttachmentsTable.$converterupdatedAtn);
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedDate =
      GeneratedColumn<String>(
        'deleted_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($AttachmentsTable.$converterdeletedDaten);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    filePath,
    createdDate,
    updatedAt,
    isDeleted,
    deletedDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbAttachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbAttachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbAttachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      createdDate: $AttachmentsTable.$convertercreatedDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_date'],
        )!,
      ),
      updatedAt: $AttachmentsTable.$converterupdatedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        ),
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      ),
      deletedDate: $AttachmentsTable.$converterdeletedDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_date'],
        ),
      ),
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedDate =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterupdatedAtn =
      NullAwareTypeConverter.wrap($converterupdatedAt);
  static TypeConverter<DateTime, String> $converterdeletedDate =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedDaten =
      NullAwareTypeConverter.wrap($converterdeletedDate);
}

class DbAttachment extends DataClass implements Insertable<DbAttachment> {
  final String id;
  final String? name;
  final String filePath;
  final DateTime createdDate;
  final DateTime? updatedAt;
  final bool? isDeleted;
  final DateTime? deletedDate;
  const DbAttachment({
    required this.id,
    this.name,
    required this.filePath,
    required this.createdDate,
    this.updatedAt,
    this.isDeleted,
    this.deletedDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['file_path'] = Variable<String>(filePath);
    {
      map['created_date'] = Variable<String>(
        $AttachmentsTable.$convertercreatedDate.toSql(createdDate),
      );
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(
        $AttachmentsTable.$converterupdatedAtn.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || isDeleted != null) {
      map['is_deleted'] = Variable<bool>(isDeleted);
    }
    if (!nullToAbsent || deletedDate != null) {
      map['deleted_date'] = Variable<String>(
        $AttachmentsTable.$converterdeletedDaten.toSql(deletedDate),
      );
    }
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      filePath: Value(filePath),
      createdDate: Value(createdDate),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      isDeleted: isDeleted == null && nullToAbsent
          ? const Value.absent()
          : Value(isDeleted),
      deletedDate: deletedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedDate),
    );
  }

  factory DbAttachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbAttachment(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      filePath: serializer.fromJson<String>(json['filePath']),
      createdDate: serializer.fromJson<DateTime>(json['createdDate']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool?>(json['isDeleted']),
      deletedDate: serializer.fromJson<DateTime?>(json['deletedDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String?>(name),
      'filePath': serializer.toJson<String>(filePath),
      'createdDate': serializer.toJson<DateTime>(createdDate),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'isDeleted': serializer.toJson<bool?>(isDeleted),
      'deletedDate': serializer.toJson<DateTime?>(deletedDate),
    };
  }

  DbAttachment copyWith({
    String? id,
    Value<String?> name = const Value.absent(),
    String? filePath,
    DateTime? createdDate,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<bool?> isDeleted = const Value.absent(),
    Value<DateTime?> deletedDate = const Value.absent(),
  }) => DbAttachment(
    id: id ?? this.id,
    name: name.present ? name.value : this.name,
    filePath: filePath ?? this.filePath,
    createdDate: createdDate ?? this.createdDate,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    isDeleted: isDeleted.present ? isDeleted.value : this.isDeleted,
    deletedDate: deletedDate.present ? deletedDate.value : this.deletedDate,
  );
  DbAttachment copyWithCompanion(AttachmentsCompanion data) {
    return DbAttachment(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      createdDate: data.createdDate.present
          ? data.createdDate.value
          : this.createdDate,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      deletedDate: data.deletedDate.present
          ? data.deletedDate.value
          : this.deletedDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbAttachment(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('filePath: $filePath, ')
          ..write('createdDate: $createdDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedDate: $deletedDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    filePath,
    createdDate,
    updatedAt,
    isDeleted,
    deletedDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbAttachment &&
          other.id == this.id &&
          other.name == this.name &&
          other.filePath == this.filePath &&
          other.createdDate == this.createdDate &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.deletedDate == this.deletedDate);
}

class AttachmentsCompanion extends UpdateCompanion<DbAttachment> {
  final Value<String> id;
  final Value<String?> name;
  final Value<String> filePath;
  final Value<DateTime> createdDate;
  final Value<DateTime?> updatedAt;
  final Value<bool?> isDeleted;
  final Value<DateTime?> deletedDate;
  final Value<int> rowid;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.filePath = const Value.absent(),
    this.createdDate = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    required String filePath,
    required DateTime createdDate,
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : filePath = Value(filePath),
       createdDate = Value(createdDate);
  static Insertable<DbAttachment> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? filePath,
    Expression<String>? createdDate,
    Expression<String>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? deletedDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (filePath != null) 'file_path': filePath,
      if (createdDate != null) 'created_date': createdDate,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (deletedDate != null) 'deleted_date': deletedDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String?>? name,
    Value<String>? filePath,
    Value<DateTime>? createdDate,
    Value<DateTime?>? updatedAt,
    Value<bool?>? isDeleted,
    Value<DateTime?>? deletedDate,
    Value<int>? rowid,
  }) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      filePath: filePath ?? this.filePath,
      createdDate: createdDate ?? this.createdDate,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedDate: deletedDate ?? this.deletedDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (createdDate.present) {
      map['created_date'] = Variable<String>(
        $AttachmentsTable.$convertercreatedDate.toSql(createdDate.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $AttachmentsTable.$converterupdatedAtn.toSql(updatedAt.value),
      );
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (deletedDate.present) {
      map['deleted_date'] = Variable<String>(
        $AttachmentsTable.$converterdeletedDaten.toSql(deletedDate.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('filePath: $filePath, ')
          ..write('createdDate: $createdDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedDate: $deletedDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfilesTable extends Profiles
    with TableInfo<$ProfilesTable, DbProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdDate =
      GeneratedColumn<String>(
        'created_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ProfilesTable.$convertercreatedDate);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($ProfilesTable.$converterupdatedAtn);
  @override
  List<GeneratedColumn> get $columns => [id, name, createdDate, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdDate: $ProfilesTable.$convertercreatedDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_date'],
        )!,
      ),
      updatedAt: $ProfilesTable.$converterupdatedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        ),
      ),
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedDate =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterupdatedAtn =
      NullAwareTypeConverter.wrap($converterupdatedAt);
}

class DbProfile extends DataClass implements Insertable<DbProfile> {
  final String id;
  final String name;
  final DateTime createdDate;
  final DateTime? updatedAt;
  const DbProfile({
    required this.id,
    required this.name,
    required this.createdDate,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['created_date'] = Variable<String>(
        $ProfilesTable.$convertercreatedDate.toSql(createdDate),
      );
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(
        $ProfilesTable.$converterupdatedAtn.toSql(updatedAt),
      );
    }
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      name: Value(name),
      createdDate: Value(createdDate),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory DbProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbProfile(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdDate: serializer.fromJson<DateTime>(json['createdDate']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdDate': serializer.toJson<DateTime>(createdDate),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  DbProfile copyWith({
    String? id,
    String? name,
    DateTime? createdDate,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => DbProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    createdDate: createdDate ?? this.createdDate,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  DbProfile copyWithCompanion(ProfilesCompanion data) {
    return DbProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdDate: data.createdDate.present
          ? data.createdDate.value
          : this.createdDate,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdDate: $createdDate, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdDate, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdDate == this.createdDate &&
          other.updatedAt == this.updatedAt);
}

class ProfilesCompanion extends UpdateCompanion<DbProfile> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdDate;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdDate = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DateTime createdDate,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       createdDate = Value(createdDate);
  static Insertable<DbProfile> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? createdDate,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdDate != null) 'created_date': createdDate,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdDate,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdDate: createdDate ?? this.createdDate,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdDate.present) {
      map['created_date'] = Variable<String>(
        $ProfilesTable.$convertercreatedDate.toSql(createdDate.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $ProfilesTable.$converterupdatedAtn.toSql(updatedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdDate: $createdDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserPreferencesTableTable extends UserPreferencesTable
    with TableInfo<$UserPreferencesTableTable, DbUserPreferences> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPreferencesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
  );
  static const VerificationMeta _combineTransfersMeta = const VerificationMeta(
    'combineTransfers',
  );
  @override
  late final GeneratedColumn<bool> combineTransfers = GeneratedColumn<bool>(
    'combine_transfers',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("combine_transfers" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _excludeTransfersFromFlowMeta =
      const VerificationMeta('excludeTransfersFromFlow');
  @override
  late final GeneratedColumn<bool> excludeTransfersFromFlow =
      GeneratedColumn<bool>(
        'exclude_transfers_from_flow',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("exclude_transfers_from_flow" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _trashBinRetentionDaysMeta =
      const VerificationMeta('trashBinRetentionDays');
  @override
  late final GeneratedColumn<int> trashBinRetentionDays = GeneratedColumn<int>(
    'trash_bin_retention_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultFilterPresetMeta =
      const VerificationMeta('defaultFilterPreset');
  @override
  late final GeneratedColumn<String> defaultFilterPreset =
      GeneratedColumn<String>(
        'default_filter_preset',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta
  _homePendingTransactionsTimeRangeSerializedMeta = const VerificationMeta(
    'homePendingTransactionsTimeRangeSerialized',
  );
  @override
  late final GeneratedColumn<String>
  homePendingTransactionsTimeRangeSerialized = GeneratedColumn<String>(
    'home_pending_transactions_time_range_serialized',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remindDailyAtRelativeSecondsMeta =
      const VerificationMeta('remindDailyAtRelativeSeconds');
  @override
  late final GeneratedColumn<int> remindDailyAtRelativeSeconds =
      GeneratedColumn<int>(
        'remind_daily_at_relative_seconds',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _useCategoryNameForUntitledTransactionsMeta =
      const VerificationMeta('useCategoryNameForUntitledTransactions');
  @override
  late final GeneratedColumn<bool> useCategoryNameForUntitledTransactions =
      GeneratedColumn<bool>(
        'use_category_name_for_untitled_transactions',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("use_category_name_for_untitled_transactions" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _transactionListTileShowCategoryNameMeta =
      const VerificationMeta('transactionListTileShowCategoryName');
  @override
  late final GeneratedColumn<bool> transactionListTileShowCategoryName =
      GeneratedColumn<bool>(
        'transaction_list_tile_show_category_name',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("transaction_list_tile_show_category_name" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _transactionListTileShowAccountForLeadingMeta =
      const VerificationMeta('transactionListTileShowAccountForLeading');
  @override
  late final GeneratedColumn<bool> transactionListTileShowAccountForLeading =
      GeneratedColumn<bool>(
        'transaction_list_tile_show_account_for_leading',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("transaction_list_tile_show_account_for_leading" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _transactionListTileShowExternalSourceMeta =
      const VerificationMeta('transactionListTileShowExternalSource');
  @override
  late final GeneratedColumn<bool> transactionListTileShowExternalSource =
      GeneratedColumn<bool>(
        'transaction_list_tile_show_external_source',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("transaction_list_tile_show_external_source" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _transactionListTileRelaxedDensityMeta =
      const VerificationMeta('transactionListTileRelaxedDensity');
  @override
  late final GeneratedColumn<bool> transactionListTileRelaxedDensity =
      GeneratedColumn<bool>(
        'transaction_list_tile_relaxed_density',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("transaction_list_tile_relaxed_density" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _createTransactionsPerItemInScansMeta =
      const VerificationMeta('createTransactionsPerItemInScans');
  @override
  late final GeneratedColumn<bool> createTransactionsPerItemInScans =
      GeneratedColumn<bool>(
        'create_transactions_per_item_in_scans',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("create_transactions_per_item_in_scans" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _scansPendingThresholdInHoursMeta =
      const VerificationMeta('scansPendingThresholdInHours');
  @override
  late final GeneratedColumn<int> scansPendingThresholdInHours =
      GeneratedColumn<int>(
        'scans_pending_threshold_in_hours',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _privacyModeUponLaunchMeta =
      const VerificationMeta('privacyModeUponLaunch');
  @override
  late final GeneratedColumn<bool> privacyModeUponLaunch =
      GeneratedColumn<bool>(
        'privacy_mode_upon_launch',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("privacy_mode_upon_launch" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _privacyModeUponShakingMeta =
      const VerificationMeta('privacyModeUponShaking');
  @override
  late final GeneratedColumn<bool> privacyModeUponShaking =
      GeneratedColumn<bool>(
        'privacy_mode_upon_shaking',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("privacy_mode_upon_shaking" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _icuCurrencyFormattingPatternMeta =
      const VerificationMeta('icuCurrencyFormattingPattern');
  @override
  late final GeneratedColumn<String> icuCurrencyFormattingPattern =
      GeneratedColumn<String>(
        'icu_currency_formatting_pattern',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _primaryCurrencyMeta = const VerificationMeta(
    'primaryCurrency',
  );
  @override
  late final GeneratedColumn<String> primaryCurrency = GeneratedColumn<String>(
    'primary_currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _primaryAccountIdMeta = const VerificationMeta(
    'primaryAccountId',
  );
  @override
  late final GeneratedColumn<String> primaryAccountId = GeneratedColumn<String>(
    'primary_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _autoBackupIntervalInHoursMeta =
      const VerificationMeta('autoBackupIntervalInHours');
  @override
  late final GeneratedColumn<int> autoBackupIntervalInHours =
      GeneratedColumn<int>(
        'auto_backup_interval_in_hours',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _enableICloudSyncMeta = const VerificationMeta(
    'enableICloudSync',
  );
  @override
  late final GeneratedColumn<bool> enableICloudSync = GeneratedColumn<bool>(
    'enable_icloud_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enable_icloud_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _iCloudBackupsToKeepMeta =
      const VerificationMeta('iCloudBackupsToKeep');
  @override
  late final GeneratedColumn<int> iCloudBackupsToKeep = GeneratedColumn<int>(
    'icloud_backups_to_keep',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transactionButtonOrderJoinedMeta =
      const VerificationMeta('transactionButtonOrderJoined');
  @override
  late final GeneratedColumn<String> transactionButtonOrderJoined =
      GeneratedColumn<String>(
        'transaction_button_order_joined',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _themeNameMeta = const VerificationMeta(
    'themeName',
  );
  @override
  late final GeneratedColumn<String> themeName = GeneratedColumn<String>(
    'theme_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _themeChangesAppIconMeta =
      const VerificationMeta('themeChangesAppIcon');
  @override
  late final GeneratedColumn<bool> themeChangesAppIcon = GeneratedColumn<bool>(
    'theme_changes_app_icon',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("theme_changes_app_icon" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _changeVisualsMeta = const VerificationMeta(
    'changeVisuals',
  );
  @override
  late final GeneratedColumn<String> changeVisuals = GeneratedColumn<String>(
    'change_visuals',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transactionEntryFlowJsonMeta =
      const VerificationMeta('transactionEntryFlowJson');
  @override
  late final GeneratedColumn<String> transactionEntryFlowJson =
      GeneratedColumn<String>(
        'transaction_entry_flow_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>(
        $UserPreferencesTableTable.$converterupdatedAtn,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    combineTransfers,
    excludeTransfersFromFlow,
    trashBinRetentionDays,
    defaultFilterPreset,
    homePendingTransactionsTimeRangeSerialized,
    remindDailyAtRelativeSeconds,
    useCategoryNameForUntitledTransactions,
    transactionListTileShowCategoryName,
    transactionListTileShowAccountForLeading,
    transactionListTileShowExternalSource,
    transactionListTileRelaxedDensity,
    createTransactionsPerItemInScans,
    scansPendingThresholdInHours,
    privacyModeUponLaunch,
    privacyModeUponShaking,
    icuCurrencyFormattingPattern,
    primaryCurrency,
    primaryAccountId,
    autoBackupIntervalInHours,
    enableICloudSync,
    iCloudBackupsToKeep,
    transactionButtonOrderJoined,
    themeName,
    themeChangesAppIcon,
    changeVisuals,
    transactionEntryFlowJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbUserPreferences> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('combine_transfers')) {
      context.handle(
        _combineTransfersMeta,
        combineTransfers.isAcceptableOrUnknown(
          data['combine_transfers']!,
          _combineTransfersMeta,
        ),
      );
    }
    if (data.containsKey('exclude_transfers_from_flow')) {
      context.handle(
        _excludeTransfersFromFlowMeta,
        excludeTransfersFromFlow.isAcceptableOrUnknown(
          data['exclude_transfers_from_flow']!,
          _excludeTransfersFromFlowMeta,
        ),
      );
    }
    if (data.containsKey('trash_bin_retention_days')) {
      context.handle(
        _trashBinRetentionDaysMeta,
        trashBinRetentionDays.isAcceptableOrUnknown(
          data['trash_bin_retention_days']!,
          _trashBinRetentionDaysMeta,
        ),
      );
    }
    if (data.containsKey('default_filter_preset')) {
      context.handle(
        _defaultFilterPresetMeta,
        defaultFilterPreset.isAcceptableOrUnknown(
          data['default_filter_preset']!,
          _defaultFilterPresetMeta,
        ),
      );
    }
    if (data.containsKey('home_pending_transactions_time_range_serialized')) {
      context.handle(
        _homePendingTransactionsTimeRangeSerializedMeta,
        homePendingTransactionsTimeRangeSerialized.isAcceptableOrUnknown(
          data['home_pending_transactions_time_range_serialized']!,
          _homePendingTransactionsTimeRangeSerializedMeta,
        ),
      );
    }
    if (data.containsKey('remind_daily_at_relative_seconds')) {
      context.handle(
        _remindDailyAtRelativeSecondsMeta,
        remindDailyAtRelativeSeconds.isAcceptableOrUnknown(
          data['remind_daily_at_relative_seconds']!,
          _remindDailyAtRelativeSecondsMeta,
        ),
      );
    }
    if (data.containsKey('use_category_name_for_untitled_transactions')) {
      context.handle(
        _useCategoryNameForUntitledTransactionsMeta,
        useCategoryNameForUntitledTransactions.isAcceptableOrUnknown(
          data['use_category_name_for_untitled_transactions']!,
          _useCategoryNameForUntitledTransactionsMeta,
        ),
      );
    }
    if (data.containsKey('transaction_list_tile_show_category_name')) {
      context.handle(
        _transactionListTileShowCategoryNameMeta,
        transactionListTileShowCategoryName.isAcceptableOrUnknown(
          data['transaction_list_tile_show_category_name']!,
          _transactionListTileShowCategoryNameMeta,
        ),
      );
    }
    if (data.containsKey('transaction_list_tile_show_account_for_leading')) {
      context.handle(
        _transactionListTileShowAccountForLeadingMeta,
        transactionListTileShowAccountForLeading.isAcceptableOrUnknown(
          data['transaction_list_tile_show_account_for_leading']!,
          _transactionListTileShowAccountForLeadingMeta,
        ),
      );
    }
    if (data.containsKey('transaction_list_tile_show_external_source')) {
      context.handle(
        _transactionListTileShowExternalSourceMeta,
        transactionListTileShowExternalSource.isAcceptableOrUnknown(
          data['transaction_list_tile_show_external_source']!,
          _transactionListTileShowExternalSourceMeta,
        ),
      );
    }
    if (data.containsKey('transaction_list_tile_relaxed_density')) {
      context.handle(
        _transactionListTileRelaxedDensityMeta,
        transactionListTileRelaxedDensity.isAcceptableOrUnknown(
          data['transaction_list_tile_relaxed_density']!,
          _transactionListTileRelaxedDensityMeta,
        ),
      );
    }
    if (data.containsKey('create_transactions_per_item_in_scans')) {
      context.handle(
        _createTransactionsPerItemInScansMeta,
        createTransactionsPerItemInScans.isAcceptableOrUnknown(
          data['create_transactions_per_item_in_scans']!,
          _createTransactionsPerItemInScansMeta,
        ),
      );
    }
    if (data.containsKey('scans_pending_threshold_in_hours')) {
      context.handle(
        _scansPendingThresholdInHoursMeta,
        scansPendingThresholdInHours.isAcceptableOrUnknown(
          data['scans_pending_threshold_in_hours']!,
          _scansPendingThresholdInHoursMeta,
        ),
      );
    }
    if (data.containsKey('privacy_mode_upon_launch')) {
      context.handle(
        _privacyModeUponLaunchMeta,
        privacyModeUponLaunch.isAcceptableOrUnknown(
          data['privacy_mode_upon_launch']!,
          _privacyModeUponLaunchMeta,
        ),
      );
    }
    if (data.containsKey('privacy_mode_upon_shaking')) {
      context.handle(
        _privacyModeUponShakingMeta,
        privacyModeUponShaking.isAcceptableOrUnknown(
          data['privacy_mode_upon_shaking']!,
          _privacyModeUponShakingMeta,
        ),
      );
    }
    if (data.containsKey('icu_currency_formatting_pattern')) {
      context.handle(
        _icuCurrencyFormattingPatternMeta,
        icuCurrencyFormattingPattern.isAcceptableOrUnknown(
          data['icu_currency_formatting_pattern']!,
          _icuCurrencyFormattingPatternMeta,
        ),
      );
    }
    if (data.containsKey('primary_currency')) {
      context.handle(
        _primaryCurrencyMeta,
        primaryCurrency.isAcceptableOrUnknown(
          data['primary_currency']!,
          _primaryCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('primary_account_id')) {
      context.handle(
        _primaryAccountIdMeta,
        primaryAccountId.isAcceptableOrUnknown(
          data['primary_account_id']!,
          _primaryAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('auto_backup_interval_in_hours')) {
      context.handle(
        _autoBackupIntervalInHoursMeta,
        autoBackupIntervalInHours.isAcceptableOrUnknown(
          data['auto_backup_interval_in_hours']!,
          _autoBackupIntervalInHoursMeta,
        ),
      );
    }
    if (data.containsKey('enable_icloud_sync')) {
      context.handle(
        _enableICloudSyncMeta,
        enableICloudSync.isAcceptableOrUnknown(
          data['enable_icloud_sync']!,
          _enableICloudSyncMeta,
        ),
      );
    }
    if (data.containsKey('icloud_backups_to_keep')) {
      context.handle(
        _iCloudBackupsToKeepMeta,
        iCloudBackupsToKeep.isAcceptableOrUnknown(
          data['icloud_backups_to_keep']!,
          _iCloudBackupsToKeepMeta,
        ),
      );
    }
    if (data.containsKey('transaction_button_order_joined')) {
      context.handle(
        _transactionButtonOrderJoinedMeta,
        transactionButtonOrderJoined.isAcceptableOrUnknown(
          data['transaction_button_order_joined']!,
          _transactionButtonOrderJoinedMeta,
        ),
      );
    }
    if (data.containsKey('theme_name')) {
      context.handle(
        _themeNameMeta,
        themeName.isAcceptableOrUnknown(data['theme_name']!, _themeNameMeta),
      );
    }
    if (data.containsKey('theme_changes_app_icon')) {
      context.handle(
        _themeChangesAppIconMeta,
        themeChangesAppIcon.isAcceptableOrUnknown(
          data['theme_changes_app_icon']!,
          _themeChangesAppIconMeta,
        ),
      );
    }
    if (data.containsKey('change_visuals')) {
      context.handle(
        _changeVisualsMeta,
        changeVisuals.isAcceptableOrUnknown(
          data['change_visuals']!,
          _changeVisualsMeta,
        ),
      );
    }
    if (data.containsKey('transaction_entry_flow_json')) {
      context.handle(
        _transactionEntryFlowJsonMeta,
        transactionEntryFlowJson.isAcceptableOrUnknown(
          data['transaction_entry_flow_json']!,
          _transactionEntryFlowJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbUserPreferences map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbUserPreferences(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      combineTransfers: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}combine_transfers'],
      )!,
      excludeTransfersFromFlow: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}exclude_transfers_from_flow'],
      )!,
      trashBinRetentionDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trash_bin_retention_days'],
      ),
      defaultFilterPreset: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_filter_preset'],
      ),
      homePendingTransactionsTimeRangeSerialized: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}home_pending_transactions_time_range_serialized'],
      ),
      remindDailyAtRelativeSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remind_daily_at_relative_seconds'],
      ),
      useCategoryNameForUntitledTransactions: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}use_category_name_for_untitled_transactions'],
      )!,
      transactionListTileShowCategoryName: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}transaction_list_tile_show_category_name'],
      )!,
      transactionListTileShowAccountForLeading: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}transaction_list_tile_show_account_for_leading'],
      )!,
      transactionListTileShowExternalSource: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}transaction_list_tile_show_external_source'],
      )!,
      transactionListTileRelaxedDensity: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}transaction_list_tile_relaxed_density'],
      )!,
      createTransactionsPerItemInScans: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}create_transactions_per_item_in_scans'],
      )!,
      scansPendingThresholdInHours: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scans_pending_threshold_in_hours'],
      ),
      privacyModeUponLaunch: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}privacy_mode_upon_launch'],
      )!,
      privacyModeUponShaking: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}privacy_mode_upon_shaking'],
      )!,
      icuCurrencyFormattingPattern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icu_currency_formatting_pattern'],
      ),
      primaryCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_currency'],
      ),
      primaryAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_account_id'],
      ),
      autoBackupIntervalInHours: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}auto_backup_interval_in_hours'],
      ),
      enableICloudSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enable_icloud_sync'],
      )!,
      iCloudBackupsToKeep: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icloud_backups_to_keep'],
      ),
      transactionButtonOrderJoined: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_button_order_joined'],
      ),
      themeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_name'],
      ),
      themeChangesAppIcon: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}theme_changes_app_icon'],
      )!,
      changeVisuals: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}change_visuals'],
      ),
      transactionEntryFlowJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_entry_flow_json'],
      ),
      updatedAt: $UserPreferencesTableTable.$converterupdatedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        ),
      ),
    );
  }

  @override
  $UserPreferencesTableTable createAlias(String alias) {
    return $UserPreferencesTableTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterupdatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterupdatedAtn =
      NullAwareTypeConverter.wrap($converterupdatedAt);
}

class DbUserPreferences extends DataClass
    implements Insertable<DbUserPreferences> {
  final String id;
  final bool combineTransfers;
  final bool excludeTransfersFromFlow;
  final int? trashBinRetentionDays;
  final String? defaultFilterPreset;
  final String? homePendingTransactionsTimeRangeSerialized;
  final int? remindDailyAtRelativeSeconds;
  final bool useCategoryNameForUntitledTransactions;
  final bool transactionListTileShowCategoryName;
  final bool transactionListTileShowAccountForLeading;
  final bool transactionListTileShowExternalSource;
  final bool transactionListTileRelaxedDensity;
  final bool createTransactionsPerItemInScans;
  final int? scansPendingThresholdInHours;
  final bool privacyModeUponLaunch;
  final bool privacyModeUponShaking;
  final String? icuCurrencyFormattingPattern;
  final String? primaryCurrency;
  final String? primaryAccountId;
  final int? autoBackupIntervalInHours;
  final bool enableICloudSync;
  final int? iCloudBackupsToKeep;
  final String? transactionButtonOrderJoined;
  final String? themeName;
  final bool themeChangesAppIcon;
  final String? changeVisuals;
  final String? transactionEntryFlowJson;
  final DateTime? updatedAt;
  const DbUserPreferences({
    required this.id,
    required this.combineTransfers,
    required this.excludeTransfersFromFlow,
    this.trashBinRetentionDays,
    this.defaultFilterPreset,
    this.homePendingTransactionsTimeRangeSerialized,
    this.remindDailyAtRelativeSeconds,
    required this.useCategoryNameForUntitledTransactions,
    required this.transactionListTileShowCategoryName,
    required this.transactionListTileShowAccountForLeading,
    required this.transactionListTileShowExternalSource,
    required this.transactionListTileRelaxedDensity,
    required this.createTransactionsPerItemInScans,
    this.scansPendingThresholdInHours,
    required this.privacyModeUponLaunch,
    required this.privacyModeUponShaking,
    this.icuCurrencyFormattingPattern,
    this.primaryCurrency,
    this.primaryAccountId,
    this.autoBackupIntervalInHours,
    required this.enableICloudSync,
    this.iCloudBackupsToKeep,
    this.transactionButtonOrderJoined,
    this.themeName,
    required this.themeChangesAppIcon,
    this.changeVisuals,
    this.transactionEntryFlowJson,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['combine_transfers'] = Variable<bool>(combineTransfers);
    map['exclude_transfers_from_flow'] = Variable<bool>(
      excludeTransfersFromFlow,
    );
    if (!nullToAbsent || trashBinRetentionDays != null) {
      map['trash_bin_retention_days'] = Variable<int>(trashBinRetentionDays);
    }
    if (!nullToAbsent || defaultFilterPreset != null) {
      map['default_filter_preset'] = Variable<String>(defaultFilterPreset);
    }
    if (!nullToAbsent || homePendingTransactionsTimeRangeSerialized != null) {
      map['home_pending_transactions_time_range_serialized'] = Variable<String>(
        homePendingTransactionsTimeRangeSerialized,
      );
    }
    if (!nullToAbsent || remindDailyAtRelativeSeconds != null) {
      map['remind_daily_at_relative_seconds'] = Variable<int>(
        remindDailyAtRelativeSeconds,
      );
    }
    map['use_category_name_for_untitled_transactions'] = Variable<bool>(
      useCategoryNameForUntitledTransactions,
    );
    map['transaction_list_tile_show_category_name'] = Variable<bool>(
      transactionListTileShowCategoryName,
    );
    map['transaction_list_tile_show_account_for_leading'] = Variable<bool>(
      transactionListTileShowAccountForLeading,
    );
    map['transaction_list_tile_show_external_source'] = Variable<bool>(
      transactionListTileShowExternalSource,
    );
    map['transaction_list_tile_relaxed_density'] = Variable<bool>(
      transactionListTileRelaxedDensity,
    );
    map['create_transactions_per_item_in_scans'] = Variable<bool>(
      createTransactionsPerItemInScans,
    );
    if (!nullToAbsent || scansPendingThresholdInHours != null) {
      map['scans_pending_threshold_in_hours'] = Variable<int>(
        scansPendingThresholdInHours,
      );
    }
    map['privacy_mode_upon_launch'] = Variable<bool>(privacyModeUponLaunch);
    map['privacy_mode_upon_shaking'] = Variable<bool>(privacyModeUponShaking);
    if (!nullToAbsent || icuCurrencyFormattingPattern != null) {
      map['icu_currency_formatting_pattern'] = Variable<String>(
        icuCurrencyFormattingPattern,
      );
    }
    if (!nullToAbsent || primaryCurrency != null) {
      map['primary_currency'] = Variable<String>(primaryCurrency);
    }
    if (!nullToAbsent || primaryAccountId != null) {
      map['primary_account_id'] = Variable<String>(primaryAccountId);
    }
    if (!nullToAbsent || autoBackupIntervalInHours != null) {
      map['auto_backup_interval_in_hours'] = Variable<int>(
        autoBackupIntervalInHours,
      );
    }
    map['enable_icloud_sync'] = Variable<bool>(enableICloudSync);
    if (!nullToAbsent || iCloudBackupsToKeep != null) {
      map['icloud_backups_to_keep'] = Variable<int>(iCloudBackupsToKeep);
    }
    if (!nullToAbsent || transactionButtonOrderJoined != null) {
      map['transaction_button_order_joined'] = Variable<String>(
        transactionButtonOrderJoined,
      );
    }
    if (!nullToAbsent || themeName != null) {
      map['theme_name'] = Variable<String>(themeName);
    }
    map['theme_changes_app_icon'] = Variable<bool>(themeChangesAppIcon);
    if (!nullToAbsent || changeVisuals != null) {
      map['change_visuals'] = Variable<String>(changeVisuals);
    }
    if (!nullToAbsent || transactionEntryFlowJson != null) {
      map['transaction_entry_flow_json'] = Variable<String>(
        transactionEntryFlowJson,
      );
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(
        $UserPreferencesTableTable.$converterupdatedAtn.toSql(updatedAt),
      );
    }
    return map;
  }

  UserPreferencesTableCompanion toCompanion(bool nullToAbsent) {
    return UserPreferencesTableCompanion(
      id: Value(id),
      combineTransfers: Value(combineTransfers),
      excludeTransfersFromFlow: Value(excludeTransfersFromFlow),
      trashBinRetentionDays: trashBinRetentionDays == null && nullToAbsent
          ? const Value.absent()
          : Value(trashBinRetentionDays),
      defaultFilterPreset: defaultFilterPreset == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultFilterPreset),
      homePendingTransactionsTimeRangeSerialized:
          homePendingTransactionsTimeRangeSerialized == null && nullToAbsent
          ? const Value.absent()
          : Value(homePendingTransactionsTimeRangeSerialized),
      remindDailyAtRelativeSeconds:
          remindDailyAtRelativeSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(remindDailyAtRelativeSeconds),
      useCategoryNameForUntitledTransactions: Value(
        useCategoryNameForUntitledTransactions,
      ),
      transactionListTileShowCategoryName: Value(
        transactionListTileShowCategoryName,
      ),
      transactionListTileShowAccountForLeading: Value(
        transactionListTileShowAccountForLeading,
      ),
      transactionListTileShowExternalSource: Value(
        transactionListTileShowExternalSource,
      ),
      transactionListTileRelaxedDensity: Value(
        transactionListTileRelaxedDensity,
      ),
      createTransactionsPerItemInScans: Value(createTransactionsPerItemInScans),
      scansPendingThresholdInHours:
          scansPendingThresholdInHours == null && nullToAbsent
          ? const Value.absent()
          : Value(scansPendingThresholdInHours),
      privacyModeUponLaunch: Value(privacyModeUponLaunch),
      privacyModeUponShaking: Value(privacyModeUponShaking),
      icuCurrencyFormattingPattern:
          icuCurrencyFormattingPattern == null && nullToAbsent
          ? const Value.absent()
          : Value(icuCurrencyFormattingPattern),
      primaryCurrency: primaryCurrency == null && nullToAbsent
          ? const Value.absent()
          : Value(primaryCurrency),
      primaryAccountId: primaryAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(primaryAccountId),
      autoBackupIntervalInHours:
          autoBackupIntervalInHours == null && nullToAbsent
          ? const Value.absent()
          : Value(autoBackupIntervalInHours),
      enableICloudSync: Value(enableICloudSync),
      iCloudBackupsToKeep: iCloudBackupsToKeep == null && nullToAbsent
          ? const Value.absent()
          : Value(iCloudBackupsToKeep),
      transactionButtonOrderJoined:
          transactionButtonOrderJoined == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionButtonOrderJoined),
      themeName: themeName == null && nullToAbsent
          ? const Value.absent()
          : Value(themeName),
      themeChangesAppIcon: Value(themeChangesAppIcon),
      changeVisuals: changeVisuals == null && nullToAbsent
          ? const Value.absent()
          : Value(changeVisuals),
      transactionEntryFlowJson: transactionEntryFlowJson == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionEntryFlowJson),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory DbUserPreferences.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbUserPreferences(
      id: serializer.fromJson<String>(json['id']),
      combineTransfers: serializer.fromJson<bool>(json['combineTransfers']),
      excludeTransfersFromFlow: serializer.fromJson<bool>(
        json['excludeTransfersFromFlow'],
      ),
      trashBinRetentionDays: serializer.fromJson<int?>(
        json['trashBinRetentionDays'],
      ),
      defaultFilterPreset: serializer.fromJson<String?>(
        json['defaultFilterPreset'],
      ),
      homePendingTransactionsTimeRangeSerialized: serializer.fromJson<String?>(
        json['homePendingTransactionsTimeRangeSerialized'],
      ),
      remindDailyAtRelativeSeconds: serializer.fromJson<int?>(
        json['remindDailyAtRelativeSeconds'],
      ),
      useCategoryNameForUntitledTransactions: serializer.fromJson<bool>(
        json['useCategoryNameForUntitledTransactions'],
      ),
      transactionListTileShowCategoryName: serializer.fromJson<bool>(
        json['transactionListTileShowCategoryName'],
      ),
      transactionListTileShowAccountForLeading: serializer.fromJson<bool>(
        json['transactionListTileShowAccountForLeading'],
      ),
      transactionListTileShowExternalSource: serializer.fromJson<bool>(
        json['transactionListTileShowExternalSource'],
      ),
      transactionListTileRelaxedDensity: serializer.fromJson<bool>(
        json['transactionListTileRelaxedDensity'],
      ),
      createTransactionsPerItemInScans: serializer.fromJson<bool>(
        json['createTransactionsPerItemInScans'],
      ),
      scansPendingThresholdInHours: serializer.fromJson<int?>(
        json['scansPendingThresholdInHours'],
      ),
      privacyModeUponLaunch: serializer.fromJson<bool>(
        json['privacyModeUponLaunch'],
      ),
      privacyModeUponShaking: serializer.fromJson<bool>(
        json['privacyModeUponShaking'],
      ),
      icuCurrencyFormattingPattern: serializer.fromJson<String?>(
        json['icuCurrencyFormattingPattern'],
      ),
      primaryCurrency: serializer.fromJson<String?>(json['primaryCurrency']),
      primaryAccountId: serializer.fromJson<String?>(json['primaryAccountId']),
      autoBackupIntervalInHours: serializer.fromJson<int?>(
        json['autoBackupIntervalInHours'],
      ),
      enableICloudSync: serializer.fromJson<bool>(json['enableICloudSync']),
      iCloudBackupsToKeep: serializer.fromJson<int?>(
        json['iCloudBackupsToKeep'],
      ),
      transactionButtonOrderJoined: serializer.fromJson<String?>(
        json['transactionButtonOrderJoined'],
      ),
      themeName: serializer.fromJson<String?>(json['themeName']),
      themeChangesAppIcon: serializer.fromJson<bool>(
        json['themeChangesAppIcon'],
      ),
      changeVisuals: serializer.fromJson<String?>(json['changeVisuals']),
      transactionEntryFlowJson: serializer.fromJson<String?>(
        json['transactionEntryFlowJson'],
      ),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'combineTransfers': serializer.toJson<bool>(combineTransfers),
      'excludeTransfersFromFlow': serializer.toJson<bool>(
        excludeTransfersFromFlow,
      ),
      'trashBinRetentionDays': serializer.toJson<int?>(trashBinRetentionDays),
      'defaultFilterPreset': serializer.toJson<String?>(defaultFilterPreset),
      'homePendingTransactionsTimeRangeSerialized': serializer.toJson<String?>(
        homePendingTransactionsTimeRangeSerialized,
      ),
      'remindDailyAtRelativeSeconds': serializer.toJson<int?>(
        remindDailyAtRelativeSeconds,
      ),
      'useCategoryNameForUntitledTransactions': serializer.toJson<bool>(
        useCategoryNameForUntitledTransactions,
      ),
      'transactionListTileShowCategoryName': serializer.toJson<bool>(
        transactionListTileShowCategoryName,
      ),
      'transactionListTileShowAccountForLeading': serializer.toJson<bool>(
        transactionListTileShowAccountForLeading,
      ),
      'transactionListTileShowExternalSource': serializer.toJson<bool>(
        transactionListTileShowExternalSource,
      ),
      'transactionListTileRelaxedDensity': serializer.toJson<bool>(
        transactionListTileRelaxedDensity,
      ),
      'createTransactionsPerItemInScans': serializer.toJson<bool>(
        createTransactionsPerItemInScans,
      ),
      'scansPendingThresholdInHours': serializer.toJson<int?>(
        scansPendingThresholdInHours,
      ),
      'privacyModeUponLaunch': serializer.toJson<bool>(privacyModeUponLaunch),
      'privacyModeUponShaking': serializer.toJson<bool>(privacyModeUponShaking),
      'icuCurrencyFormattingPattern': serializer.toJson<String?>(
        icuCurrencyFormattingPattern,
      ),
      'primaryCurrency': serializer.toJson<String?>(primaryCurrency),
      'primaryAccountId': serializer.toJson<String?>(primaryAccountId),
      'autoBackupIntervalInHours': serializer.toJson<int?>(
        autoBackupIntervalInHours,
      ),
      'enableICloudSync': serializer.toJson<bool>(enableICloudSync),
      'iCloudBackupsToKeep': serializer.toJson<int?>(iCloudBackupsToKeep),
      'transactionButtonOrderJoined': serializer.toJson<String?>(
        transactionButtonOrderJoined,
      ),
      'themeName': serializer.toJson<String?>(themeName),
      'themeChangesAppIcon': serializer.toJson<bool>(themeChangesAppIcon),
      'changeVisuals': serializer.toJson<String?>(changeVisuals),
      'transactionEntryFlowJson': serializer.toJson<String?>(
        transactionEntryFlowJson,
      ),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  DbUserPreferences copyWith({
    String? id,
    bool? combineTransfers,
    bool? excludeTransfersFromFlow,
    Value<int?> trashBinRetentionDays = const Value.absent(),
    Value<String?> defaultFilterPreset = const Value.absent(),
    Value<String?> homePendingTransactionsTimeRangeSerialized =
        const Value.absent(),
    Value<int?> remindDailyAtRelativeSeconds = const Value.absent(),
    bool? useCategoryNameForUntitledTransactions,
    bool? transactionListTileShowCategoryName,
    bool? transactionListTileShowAccountForLeading,
    bool? transactionListTileShowExternalSource,
    bool? transactionListTileRelaxedDensity,
    bool? createTransactionsPerItemInScans,
    Value<int?> scansPendingThresholdInHours = const Value.absent(),
    bool? privacyModeUponLaunch,
    bool? privacyModeUponShaking,
    Value<String?> icuCurrencyFormattingPattern = const Value.absent(),
    Value<String?> primaryCurrency = const Value.absent(),
    Value<String?> primaryAccountId = const Value.absent(),
    Value<int?> autoBackupIntervalInHours = const Value.absent(),
    bool? enableICloudSync,
    Value<int?> iCloudBackupsToKeep = const Value.absent(),
    Value<String?> transactionButtonOrderJoined = const Value.absent(),
    Value<String?> themeName = const Value.absent(),
    bool? themeChangesAppIcon,
    Value<String?> changeVisuals = const Value.absent(),
    Value<String?> transactionEntryFlowJson = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => DbUserPreferences(
    id: id ?? this.id,
    combineTransfers: combineTransfers ?? this.combineTransfers,
    excludeTransfersFromFlow:
        excludeTransfersFromFlow ?? this.excludeTransfersFromFlow,
    trashBinRetentionDays: trashBinRetentionDays.present
        ? trashBinRetentionDays.value
        : this.trashBinRetentionDays,
    defaultFilterPreset: defaultFilterPreset.present
        ? defaultFilterPreset.value
        : this.defaultFilterPreset,
    homePendingTransactionsTimeRangeSerialized:
        homePendingTransactionsTimeRangeSerialized.present
        ? homePendingTransactionsTimeRangeSerialized.value
        : this.homePendingTransactionsTimeRangeSerialized,
    remindDailyAtRelativeSeconds: remindDailyAtRelativeSeconds.present
        ? remindDailyAtRelativeSeconds.value
        : this.remindDailyAtRelativeSeconds,
    useCategoryNameForUntitledTransactions:
        useCategoryNameForUntitledTransactions ??
        this.useCategoryNameForUntitledTransactions,
    transactionListTileShowCategoryName:
        transactionListTileShowCategoryName ??
        this.transactionListTileShowCategoryName,
    transactionListTileShowAccountForLeading:
        transactionListTileShowAccountForLeading ??
        this.transactionListTileShowAccountForLeading,
    transactionListTileShowExternalSource:
        transactionListTileShowExternalSource ??
        this.transactionListTileShowExternalSource,
    transactionListTileRelaxedDensity:
        transactionListTileRelaxedDensity ??
        this.transactionListTileRelaxedDensity,
    createTransactionsPerItemInScans:
        createTransactionsPerItemInScans ??
        this.createTransactionsPerItemInScans,
    scansPendingThresholdInHours: scansPendingThresholdInHours.present
        ? scansPendingThresholdInHours.value
        : this.scansPendingThresholdInHours,
    privacyModeUponLaunch: privacyModeUponLaunch ?? this.privacyModeUponLaunch,
    privacyModeUponShaking:
        privacyModeUponShaking ?? this.privacyModeUponShaking,
    icuCurrencyFormattingPattern: icuCurrencyFormattingPattern.present
        ? icuCurrencyFormattingPattern.value
        : this.icuCurrencyFormattingPattern,
    primaryCurrency: primaryCurrency.present
        ? primaryCurrency.value
        : this.primaryCurrency,
    primaryAccountId: primaryAccountId.present
        ? primaryAccountId.value
        : this.primaryAccountId,
    autoBackupIntervalInHours: autoBackupIntervalInHours.present
        ? autoBackupIntervalInHours.value
        : this.autoBackupIntervalInHours,
    enableICloudSync: enableICloudSync ?? this.enableICloudSync,
    iCloudBackupsToKeep: iCloudBackupsToKeep.present
        ? iCloudBackupsToKeep.value
        : this.iCloudBackupsToKeep,
    transactionButtonOrderJoined: transactionButtonOrderJoined.present
        ? transactionButtonOrderJoined.value
        : this.transactionButtonOrderJoined,
    themeName: themeName.present ? themeName.value : this.themeName,
    themeChangesAppIcon: themeChangesAppIcon ?? this.themeChangesAppIcon,
    changeVisuals: changeVisuals.present
        ? changeVisuals.value
        : this.changeVisuals,
    transactionEntryFlowJson: transactionEntryFlowJson.present
        ? transactionEntryFlowJson.value
        : this.transactionEntryFlowJson,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  DbUserPreferences copyWithCompanion(UserPreferencesTableCompanion data) {
    return DbUserPreferences(
      id: data.id.present ? data.id.value : this.id,
      combineTransfers: data.combineTransfers.present
          ? data.combineTransfers.value
          : this.combineTransfers,
      excludeTransfersFromFlow: data.excludeTransfersFromFlow.present
          ? data.excludeTransfersFromFlow.value
          : this.excludeTransfersFromFlow,
      trashBinRetentionDays: data.trashBinRetentionDays.present
          ? data.trashBinRetentionDays.value
          : this.trashBinRetentionDays,
      defaultFilterPreset: data.defaultFilterPreset.present
          ? data.defaultFilterPreset.value
          : this.defaultFilterPreset,
      homePendingTransactionsTimeRangeSerialized:
          data.homePendingTransactionsTimeRangeSerialized.present
          ? data.homePendingTransactionsTimeRangeSerialized.value
          : this.homePendingTransactionsTimeRangeSerialized,
      remindDailyAtRelativeSeconds: data.remindDailyAtRelativeSeconds.present
          ? data.remindDailyAtRelativeSeconds.value
          : this.remindDailyAtRelativeSeconds,
      useCategoryNameForUntitledTransactions:
          data.useCategoryNameForUntitledTransactions.present
          ? data.useCategoryNameForUntitledTransactions.value
          : this.useCategoryNameForUntitledTransactions,
      transactionListTileShowCategoryName:
          data.transactionListTileShowCategoryName.present
          ? data.transactionListTileShowCategoryName.value
          : this.transactionListTileShowCategoryName,
      transactionListTileShowAccountForLeading:
          data.transactionListTileShowAccountForLeading.present
          ? data.transactionListTileShowAccountForLeading.value
          : this.transactionListTileShowAccountForLeading,
      transactionListTileShowExternalSource:
          data.transactionListTileShowExternalSource.present
          ? data.transactionListTileShowExternalSource.value
          : this.transactionListTileShowExternalSource,
      transactionListTileRelaxedDensity:
          data.transactionListTileRelaxedDensity.present
          ? data.transactionListTileRelaxedDensity.value
          : this.transactionListTileRelaxedDensity,
      createTransactionsPerItemInScans:
          data.createTransactionsPerItemInScans.present
          ? data.createTransactionsPerItemInScans.value
          : this.createTransactionsPerItemInScans,
      scansPendingThresholdInHours: data.scansPendingThresholdInHours.present
          ? data.scansPendingThresholdInHours.value
          : this.scansPendingThresholdInHours,
      privacyModeUponLaunch: data.privacyModeUponLaunch.present
          ? data.privacyModeUponLaunch.value
          : this.privacyModeUponLaunch,
      privacyModeUponShaking: data.privacyModeUponShaking.present
          ? data.privacyModeUponShaking.value
          : this.privacyModeUponShaking,
      icuCurrencyFormattingPattern: data.icuCurrencyFormattingPattern.present
          ? data.icuCurrencyFormattingPattern.value
          : this.icuCurrencyFormattingPattern,
      primaryCurrency: data.primaryCurrency.present
          ? data.primaryCurrency.value
          : this.primaryCurrency,
      primaryAccountId: data.primaryAccountId.present
          ? data.primaryAccountId.value
          : this.primaryAccountId,
      autoBackupIntervalInHours: data.autoBackupIntervalInHours.present
          ? data.autoBackupIntervalInHours.value
          : this.autoBackupIntervalInHours,
      enableICloudSync: data.enableICloudSync.present
          ? data.enableICloudSync.value
          : this.enableICloudSync,
      iCloudBackupsToKeep: data.iCloudBackupsToKeep.present
          ? data.iCloudBackupsToKeep.value
          : this.iCloudBackupsToKeep,
      transactionButtonOrderJoined: data.transactionButtonOrderJoined.present
          ? data.transactionButtonOrderJoined.value
          : this.transactionButtonOrderJoined,
      themeName: data.themeName.present ? data.themeName.value : this.themeName,
      themeChangesAppIcon: data.themeChangesAppIcon.present
          ? data.themeChangesAppIcon.value
          : this.themeChangesAppIcon,
      changeVisuals: data.changeVisuals.present
          ? data.changeVisuals.value
          : this.changeVisuals,
      transactionEntryFlowJson: data.transactionEntryFlowJson.present
          ? data.transactionEntryFlowJson.value
          : this.transactionEntryFlowJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbUserPreferences(')
          ..write('id: $id, ')
          ..write('combineTransfers: $combineTransfers, ')
          ..write('excludeTransfersFromFlow: $excludeTransfersFromFlow, ')
          ..write('trashBinRetentionDays: $trashBinRetentionDays, ')
          ..write('defaultFilterPreset: $defaultFilterPreset, ')
          ..write(
            'homePendingTransactionsTimeRangeSerialized: $homePendingTransactionsTimeRangeSerialized, ',
          )
          ..write(
            'remindDailyAtRelativeSeconds: $remindDailyAtRelativeSeconds, ',
          )
          ..write(
            'useCategoryNameForUntitledTransactions: $useCategoryNameForUntitledTransactions, ',
          )
          ..write(
            'transactionListTileShowCategoryName: $transactionListTileShowCategoryName, ',
          )
          ..write(
            'transactionListTileShowAccountForLeading: $transactionListTileShowAccountForLeading, ',
          )
          ..write(
            'transactionListTileShowExternalSource: $transactionListTileShowExternalSource, ',
          )
          ..write(
            'transactionListTileRelaxedDensity: $transactionListTileRelaxedDensity, ',
          )
          ..write(
            'createTransactionsPerItemInScans: $createTransactionsPerItemInScans, ',
          )
          ..write(
            'scansPendingThresholdInHours: $scansPendingThresholdInHours, ',
          )
          ..write('privacyModeUponLaunch: $privacyModeUponLaunch, ')
          ..write('privacyModeUponShaking: $privacyModeUponShaking, ')
          ..write(
            'icuCurrencyFormattingPattern: $icuCurrencyFormattingPattern, ',
          )
          ..write('primaryCurrency: $primaryCurrency, ')
          ..write('primaryAccountId: $primaryAccountId, ')
          ..write('autoBackupIntervalInHours: $autoBackupIntervalInHours, ')
          ..write('enableICloudSync: $enableICloudSync, ')
          ..write('iCloudBackupsToKeep: $iCloudBackupsToKeep, ')
          ..write(
            'transactionButtonOrderJoined: $transactionButtonOrderJoined, ',
          )
          ..write('themeName: $themeName, ')
          ..write('themeChangesAppIcon: $themeChangesAppIcon, ')
          ..write('changeVisuals: $changeVisuals, ')
          ..write('transactionEntryFlowJson: $transactionEntryFlowJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    combineTransfers,
    excludeTransfersFromFlow,
    trashBinRetentionDays,
    defaultFilterPreset,
    homePendingTransactionsTimeRangeSerialized,
    remindDailyAtRelativeSeconds,
    useCategoryNameForUntitledTransactions,
    transactionListTileShowCategoryName,
    transactionListTileShowAccountForLeading,
    transactionListTileShowExternalSource,
    transactionListTileRelaxedDensity,
    createTransactionsPerItemInScans,
    scansPendingThresholdInHours,
    privacyModeUponLaunch,
    privacyModeUponShaking,
    icuCurrencyFormattingPattern,
    primaryCurrency,
    primaryAccountId,
    autoBackupIntervalInHours,
    enableICloudSync,
    iCloudBackupsToKeep,
    transactionButtonOrderJoined,
    themeName,
    themeChangesAppIcon,
    changeVisuals,
    transactionEntryFlowJson,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbUserPreferences &&
          other.id == this.id &&
          other.combineTransfers == this.combineTransfers &&
          other.excludeTransfersFromFlow == this.excludeTransfersFromFlow &&
          other.trashBinRetentionDays == this.trashBinRetentionDays &&
          other.defaultFilterPreset == this.defaultFilterPreset &&
          other.homePendingTransactionsTimeRangeSerialized ==
              this.homePendingTransactionsTimeRangeSerialized &&
          other.remindDailyAtRelativeSeconds ==
              this.remindDailyAtRelativeSeconds &&
          other.useCategoryNameForUntitledTransactions ==
              this.useCategoryNameForUntitledTransactions &&
          other.transactionListTileShowCategoryName ==
              this.transactionListTileShowCategoryName &&
          other.transactionListTileShowAccountForLeading ==
              this.transactionListTileShowAccountForLeading &&
          other.transactionListTileShowExternalSource ==
              this.transactionListTileShowExternalSource &&
          other.transactionListTileRelaxedDensity ==
              this.transactionListTileRelaxedDensity &&
          other.createTransactionsPerItemInScans ==
              this.createTransactionsPerItemInScans &&
          other.scansPendingThresholdInHours ==
              this.scansPendingThresholdInHours &&
          other.privacyModeUponLaunch == this.privacyModeUponLaunch &&
          other.privacyModeUponShaking == this.privacyModeUponShaking &&
          other.icuCurrencyFormattingPattern ==
              this.icuCurrencyFormattingPattern &&
          other.primaryCurrency == this.primaryCurrency &&
          other.primaryAccountId == this.primaryAccountId &&
          other.autoBackupIntervalInHours == this.autoBackupIntervalInHours &&
          other.enableICloudSync == this.enableICloudSync &&
          other.iCloudBackupsToKeep == this.iCloudBackupsToKeep &&
          other.transactionButtonOrderJoined ==
              this.transactionButtonOrderJoined &&
          other.themeName == this.themeName &&
          other.themeChangesAppIcon == this.themeChangesAppIcon &&
          other.changeVisuals == this.changeVisuals &&
          other.transactionEntryFlowJson == this.transactionEntryFlowJson &&
          other.updatedAt == this.updatedAt);
}

class UserPreferencesTableCompanion extends UpdateCompanion<DbUserPreferences> {
  final Value<String> id;
  final Value<bool> combineTransfers;
  final Value<bool> excludeTransfersFromFlow;
  final Value<int?> trashBinRetentionDays;
  final Value<String?> defaultFilterPreset;
  final Value<String?> homePendingTransactionsTimeRangeSerialized;
  final Value<int?> remindDailyAtRelativeSeconds;
  final Value<bool> useCategoryNameForUntitledTransactions;
  final Value<bool> transactionListTileShowCategoryName;
  final Value<bool> transactionListTileShowAccountForLeading;
  final Value<bool> transactionListTileShowExternalSource;
  final Value<bool> transactionListTileRelaxedDensity;
  final Value<bool> createTransactionsPerItemInScans;
  final Value<int?> scansPendingThresholdInHours;
  final Value<bool> privacyModeUponLaunch;
  final Value<bool> privacyModeUponShaking;
  final Value<String?> icuCurrencyFormattingPattern;
  final Value<String?> primaryCurrency;
  final Value<String?> primaryAccountId;
  final Value<int?> autoBackupIntervalInHours;
  final Value<bool> enableICloudSync;
  final Value<int?> iCloudBackupsToKeep;
  final Value<String?> transactionButtonOrderJoined;
  final Value<String?> themeName;
  final Value<bool> themeChangesAppIcon;
  final Value<String?> changeVisuals;
  final Value<String?> transactionEntryFlowJson;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const UserPreferencesTableCompanion({
    this.id = const Value.absent(),
    this.combineTransfers = const Value.absent(),
    this.excludeTransfersFromFlow = const Value.absent(),
    this.trashBinRetentionDays = const Value.absent(),
    this.defaultFilterPreset = const Value.absent(),
    this.homePendingTransactionsTimeRangeSerialized = const Value.absent(),
    this.remindDailyAtRelativeSeconds = const Value.absent(),
    this.useCategoryNameForUntitledTransactions = const Value.absent(),
    this.transactionListTileShowCategoryName = const Value.absent(),
    this.transactionListTileShowAccountForLeading = const Value.absent(),
    this.transactionListTileShowExternalSource = const Value.absent(),
    this.transactionListTileRelaxedDensity = const Value.absent(),
    this.createTransactionsPerItemInScans = const Value.absent(),
    this.scansPendingThresholdInHours = const Value.absent(),
    this.privacyModeUponLaunch = const Value.absent(),
    this.privacyModeUponShaking = const Value.absent(),
    this.icuCurrencyFormattingPattern = const Value.absent(),
    this.primaryCurrency = const Value.absent(),
    this.primaryAccountId = const Value.absent(),
    this.autoBackupIntervalInHours = const Value.absent(),
    this.enableICloudSync = const Value.absent(),
    this.iCloudBackupsToKeep = const Value.absent(),
    this.transactionButtonOrderJoined = const Value.absent(),
    this.themeName = const Value.absent(),
    this.themeChangesAppIcon = const Value.absent(),
    this.changeVisuals = const Value.absent(),
    this.transactionEntryFlowJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserPreferencesTableCompanion.insert({
    this.id = const Value.absent(),
    this.combineTransfers = const Value.absent(),
    this.excludeTransfersFromFlow = const Value.absent(),
    this.trashBinRetentionDays = const Value.absent(),
    this.defaultFilterPreset = const Value.absent(),
    this.homePendingTransactionsTimeRangeSerialized = const Value.absent(),
    this.remindDailyAtRelativeSeconds = const Value.absent(),
    this.useCategoryNameForUntitledTransactions = const Value.absent(),
    this.transactionListTileShowCategoryName = const Value.absent(),
    this.transactionListTileShowAccountForLeading = const Value.absent(),
    this.transactionListTileShowExternalSource = const Value.absent(),
    this.transactionListTileRelaxedDensity = const Value.absent(),
    this.createTransactionsPerItemInScans = const Value.absent(),
    this.scansPendingThresholdInHours = const Value.absent(),
    this.privacyModeUponLaunch = const Value.absent(),
    this.privacyModeUponShaking = const Value.absent(),
    this.icuCurrencyFormattingPattern = const Value.absent(),
    this.primaryCurrency = const Value.absent(),
    this.primaryAccountId = const Value.absent(),
    this.autoBackupIntervalInHours = const Value.absent(),
    this.enableICloudSync = const Value.absent(),
    this.iCloudBackupsToKeep = const Value.absent(),
    this.transactionButtonOrderJoined = const Value.absent(),
    this.themeName = const Value.absent(),
    this.themeChangesAppIcon = const Value.absent(),
    this.changeVisuals = const Value.absent(),
    this.transactionEntryFlowJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<DbUserPreferences> custom({
    Expression<String>? id,
    Expression<bool>? combineTransfers,
    Expression<bool>? excludeTransfersFromFlow,
    Expression<int>? trashBinRetentionDays,
    Expression<String>? defaultFilterPreset,
    Expression<String>? homePendingTransactionsTimeRangeSerialized,
    Expression<int>? remindDailyAtRelativeSeconds,
    Expression<bool>? useCategoryNameForUntitledTransactions,
    Expression<bool>? transactionListTileShowCategoryName,
    Expression<bool>? transactionListTileShowAccountForLeading,
    Expression<bool>? transactionListTileShowExternalSource,
    Expression<bool>? transactionListTileRelaxedDensity,
    Expression<bool>? createTransactionsPerItemInScans,
    Expression<int>? scansPendingThresholdInHours,
    Expression<bool>? privacyModeUponLaunch,
    Expression<bool>? privacyModeUponShaking,
    Expression<String>? icuCurrencyFormattingPattern,
    Expression<String>? primaryCurrency,
    Expression<String>? primaryAccountId,
    Expression<int>? autoBackupIntervalInHours,
    Expression<bool>? enableICloudSync,
    Expression<int>? iCloudBackupsToKeep,
    Expression<String>? transactionButtonOrderJoined,
    Expression<String>? themeName,
    Expression<bool>? themeChangesAppIcon,
    Expression<String>? changeVisuals,
    Expression<String>? transactionEntryFlowJson,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (combineTransfers != null) 'combine_transfers': combineTransfers,
      if (excludeTransfersFromFlow != null)
        'exclude_transfers_from_flow': excludeTransfersFromFlow,
      if (trashBinRetentionDays != null)
        'trash_bin_retention_days': trashBinRetentionDays,
      if (defaultFilterPreset != null)
        'default_filter_preset': defaultFilterPreset,
      if (homePendingTransactionsTimeRangeSerialized != null)
        'home_pending_transactions_time_range_serialized':
            homePendingTransactionsTimeRangeSerialized,
      if (remindDailyAtRelativeSeconds != null)
        'remind_daily_at_relative_seconds': remindDailyAtRelativeSeconds,
      if (useCategoryNameForUntitledTransactions != null)
        'use_category_name_for_untitled_transactions':
            useCategoryNameForUntitledTransactions,
      if (transactionListTileShowCategoryName != null)
        'transaction_list_tile_show_category_name':
            transactionListTileShowCategoryName,
      if (transactionListTileShowAccountForLeading != null)
        'transaction_list_tile_show_account_for_leading':
            transactionListTileShowAccountForLeading,
      if (transactionListTileShowExternalSource != null)
        'transaction_list_tile_show_external_source':
            transactionListTileShowExternalSource,
      if (transactionListTileRelaxedDensity != null)
        'transaction_list_tile_relaxed_density':
            transactionListTileRelaxedDensity,
      if (createTransactionsPerItemInScans != null)
        'create_transactions_per_item_in_scans':
            createTransactionsPerItemInScans,
      if (scansPendingThresholdInHours != null)
        'scans_pending_threshold_in_hours': scansPendingThresholdInHours,
      if (privacyModeUponLaunch != null)
        'privacy_mode_upon_launch': privacyModeUponLaunch,
      if (privacyModeUponShaking != null)
        'privacy_mode_upon_shaking': privacyModeUponShaking,
      if (icuCurrencyFormattingPattern != null)
        'icu_currency_formatting_pattern': icuCurrencyFormattingPattern,
      if (primaryCurrency != null) 'primary_currency': primaryCurrency,
      if (primaryAccountId != null) 'primary_account_id': primaryAccountId,
      if (autoBackupIntervalInHours != null)
        'auto_backup_interval_in_hours': autoBackupIntervalInHours,
      if (enableICloudSync != null) 'enable_icloud_sync': enableICloudSync,
      if (iCloudBackupsToKeep != null)
        'icloud_backups_to_keep': iCloudBackupsToKeep,
      if (transactionButtonOrderJoined != null)
        'transaction_button_order_joined': transactionButtonOrderJoined,
      if (themeName != null) 'theme_name': themeName,
      if (themeChangesAppIcon != null)
        'theme_changes_app_icon': themeChangesAppIcon,
      if (changeVisuals != null) 'change_visuals': changeVisuals,
      if (transactionEntryFlowJson != null)
        'transaction_entry_flow_json': transactionEntryFlowJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserPreferencesTableCompanion copyWith({
    Value<String>? id,
    Value<bool>? combineTransfers,
    Value<bool>? excludeTransfersFromFlow,
    Value<int?>? trashBinRetentionDays,
    Value<String?>? defaultFilterPreset,
    Value<String?>? homePendingTransactionsTimeRangeSerialized,
    Value<int?>? remindDailyAtRelativeSeconds,
    Value<bool>? useCategoryNameForUntitledTransactions,
    Value<bool>? transactionListTileShowCategoryName,
    Value<bool>? transactionListTileShowAccountForLeading,
    Value<bool>? transactionListTileShowExternalSource,
    Value<bool>? transactionListTileRelaxedDensity,
    Value<bool>? createTransactionsPerItemInScans,
    Value<int?>? scansPendingThresholdInHours,
    Value<bool>? privacyModeUponLaunch,
    Value<bool>? privacyModeUponShaking,
    Value<String?>? icuCurrencyFormattingPattern,
    Value<String?>? primaryCurrency,
    Value<String?>? primaryAccountId,
    Value<int?>? autoBackupIntervalInHours,
    Value<bool>? enableICloudSync,
    Value<int?>? iCloudBackupsToKeep,
    Value<String?>? transactionButtonOrderJoined,
    Value<String?>? themeName,
    Value<bool>? themeChangesAppIcon,
    Value<String?>? changeVisuals,
    Value<String?>? transactionEntryFlowJson,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserPreferencesTableCompanion(
      id: id ?? this.id,
      combineTransfers: combineTransfers ?? this.combineTransfers,
      excludeTransfersFromFlow:
          excludeTransfersFromFlow ?? this.excludeTransfersFromFlow,
      trashBinRetentionDays:
          trashBinRetentionDays ?? this.trashBinRetentionDays,
      defaultFilterPreset: defaultFilterPreset ?? this.defaultFilterPreset,
      homePendingTransactionsTimeRangeSerialized:
          homePendingTransactionsTimeRangeSerialized ??
          this.homePendingTransactionsTimeRangeSerialized,
      remindDailyAtRelativeSeconds:
          remindDailyAtRelativeSeconds ?? this.remindDailyAtRelativeSeconds,
      useCategoryNameForUntitledTransactions:
          useCategoryNameForUntitledTransactions ??
          this.useCategoryNameForUntitledTransactions,
      transactionListTileShowCategoryName:
          transactionListTileShowCategoryName ??
          this.transactionListTileShowCategoryName,
      transactionListTileShowAccountForLeading:
          transactionListTileShowAccountForLeading ??
          this.transactionListTileShowAccountForLeading,
      transactionListTileShowExternalSource:
          transactionListTileShowExternalSource ??
          this.transactionListTileShowExternalSource,
      transactionListTileRelaxedDensity:
          transactionListTileRelaxedDensity ??
          this.transactionListTileRelaxedDensity,
      createTransactionsPerItemInScans:
          createTransactionsPerItemInScans ??
          this.createTransactionsPerItemInScans,
      scansPendingThresholdInHours:
          scansPendingThresholdInHours ?? this.scansPendingThresholdInHours,
      privacyModeUponLaunch:
          privacyModeUponLaunch ?? this.privacyModeUponLaunch,
      privacyModeUponShaking:
          privacyModeUponShaking ?? this.privacyModeUponShaking,
      icuCurrencyFormattingPattern:
          icuCurrencyFormattingPattern ?? this.icuCurrencyFormattingPattern,
      primaryCurrency: primaryCurrency ?? this.primaryCurrency,
      primaryAccountId: primaryAccountId ?? this.primaryAccountId,
      autoBackupIntervalInHours:
          autoBackupIntervalInHours ?? this.autoBackupIntervalInHours,
      enableICloudSync: enableICloudSync ?? this.enableICloudSync,
      iCloudBackupsToKeep: iCloudBackupsToKeep ?? this.iCloudBackupsToKeep,
      transactionButtonOrderJoined:
          transactionButtonOrderJoined ?? this.transactionButtonOrderJoined,
      themeName: themeName ?? this.themeName,
      themeChangesAppIcon: themeChangesAppIcon ?? this.themeChangesAppIcon,
      changeVisuals: changeVisuals ?? this.changeVisuals,
      transactionEntryFlowJson:
          transactionEntryFlowJson ?? this.transactionEntryFlowJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (combineTransfers.present) {
      map['combine_transfers'] = Variable<bool>(combineTransfers.value);
    }
    if (excludeTransfersFromFlow.present) {
      map['exclude_transfers_from_flow'] = Variable<bool>(
        excludeTransfersFromFlow.value,
      );
    }
    if (trashBinRetentionDays.present) {
      map['trash_bin_retention_days'] = Variable<int>(
        trashBinRetentionDays.value,
      );
    }
    if (defaultFilterPreset.present) {
      map['default_filter_preset'] = Variable<String>(
        defaultFilterPreset.value,
      );
    }
    if (homePendingTransactionsTimeRangeSerialized.present) {
      map['home_pending_transactions_time_range_serialized'] = Variable<String>(
        homePendingTransactionsTimeRangeSerialized.value,
      );
    }
    if (remindDailyAtRelativeSeconds.present) {
      map['remind_daily_at_relative_seconds'] = Variable<int>(
        remindDailyAtRelativeSeconds.value,
      );
    }
    if (useCategoryNameForUntitledTransactions.present) {
      map['use_category_name_for_untitled_transactions'] = Variable<bool>(
        useCategoryNameForUntitledTransactions.value,
      );
    }
    if (transactionListTileShowCategoryName.present) {
      map['transaction_list_tile_show_category_name'] = Variable<bool>(
        transactionListTileShowCategoryName.value,
      );
    }
    if (transactionListTileShowAccountForLeading.present) {
      map['transaction_list_tile_show_account_for_leading'] = Variable<bool>(
        transactionListTileShowAccountForLeading.value,
      );
    }
    if (transactionListTileShowExternalSource.present) {
      map['transaction_list_tile_show_external_source'] = Variable<bool>(
        transactionListTileShowExternalSource.value,
      );
    }
    if (transactionListTileRelaxedDensity.present) {
      map['transaction_list_tile_relaxed_density'] = Variable<bool>(
        transactionListTileRelaxedDensity.value,
      );
    }
    if (createTransactionsPerItemInScans.present) {
      map['create_transactions_per_item_in_scans'] = Variable<bool>(
        createTransactionsPerItemInScans.value,
      );
    }
    if (scansPendingThresholdInHours.present) {
      map['scans_pending_threshold_in_hours'] = Variable<int>(
        scansPendingThresholdInHours.value,
      );
    }
    if (privacyModeUponLaunch.present) {
      map['privacy_mode_upon_launch'] = Variable<bool>(
        privacyModeUponLaunch.value,
      );
    }
    if (privacyModeUponShaking.present) {
      map['privacy_mode_upon_shaking'] = Variable<bool>(
        privacyModeUponShaking.value,
      );
    }
    if (icuCurrencyFormattingPattern.present) {
      map['icu_currency_formatting_pattern'] = Variable<String>(
        icuCurrencyFormattingPattern.value,
      );
    }
    if (primaryCurrency.present) {
      map['primary_currency'] = Variable<String>(primaryCurrency.value);
    }
    if (primaryAccountId.present) {
      map['primary_account_id'] = Variable<String>(primaryAccountId.value);
    }
    if (autoBackupIntervalInHours.present) {
      map['auto_backup_interval_in_hours'] = Variable<int>(
        autoBackupIntervalInHours.value,
      );
    }
    if (enableICloudSync.present) {
      map['enable_icloud_sync'] = Variable<bool>(enableICloudSync.value);
    }
    if (iCloudBackupsToKeep.present) {
      map['icloud_backups_to_keep'] = Variable<int>(iCloudBackupsToKeep.value);
    }
    if (transactionButtonOrderJoined.present) {
      map['transaction_button_order_joined'] = Variable<String>(
        transactionButtonOrderJoined.value,
      );
    }
    if (themeName.present) {
      map['theme_name'] = Variable<String>(themeName.value);
    }
    if (themeChangesAppIcon.present) {
      map['theme_changes_app_icon'] = Variable<bool>(themeChangesAppIcon.value);
    }
    if (changeVisuals.present) {
      map['change_visuals'] = Variable<String>(changeVisuals.value);
    }
    if (transactionEntryFlowJson.present) {
      map['transaction_entry_flow_json'] = Variable<String>(
        transactionEntryFlowJson.value,
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $UserPreferencesTableTable.$converterupdatedAtn.toSql(updatedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPreferencesTableCompanion(')
          ..write('id: $id, ')
          ..write('combineTransfers: $combineTransfers, ')
          ..write('excludeTransfersFromFlow: $excludeTransfersFromFlow, ')
          ..write('trashBinRetentionDays: $trashBinRetentionDays, ')
          ..write('defaultFilterPreset: $defaultFilterPreset, ')
          ..write(
            'homePendingTransactionsTimeRangeSerialized: $homePendingTransactionsTimeRangeSerialized, ',
          )
          ..write(
            'remindDailyAtRelativeSeconds: $remindDailyAtRelativeSeconds, ',
          )
          ..write(
            'useCategoryNameForUntitledTransactions: $useCategoryNameForUntitledTransactions, ',
          )
          ..write(
            'transactionListTileShowCategoryName: $transactionListTileShowCategoryName, ',
          )
          ..write(
            'transactionListTileShowAccountForLeading: $transactionListTileShowAccountForLeading, ',
          )
          ..write(
            'transactionListTileShowExternalSource: $transactionListTileShowExternalSource, ',
          )
          ..write(
            'transactionListTileRelaxedDensity: $transactionListTileRelaxedDensity, ',
          )
          ..write(
            'createTransactionsPerItemInScans: $createTransactionsPerItemInScans, ',
          )
          ..write(
            'scansPendingThresholdInHours: $scansPendingThresholdInHours, ',
          )
          ..write('privacyModeUponLaunch: $privacyModeUponLaunch, ')
          ..write('privacyModeUponShaking: $privacyModeUponShaking, ')
          ..write(
            'icuCurrencyFormattingPattern: $icuCurrencyFormattingPattern, ',
          )
          ..write('primaryCurrency: $primaryCurrency, ')
          ..write('primaryAccountId: $primaryAccountId, ')
          ..write('autoBackupIntervalInHours: $autoBackupIntervalInHours, ')
          ..write('enableICloudSync: $enableICloudSync, ')
          ..write('iCloudBackupsToKeep: $iCloudBackupsToKeep, ')
          ..write(
            'transactionButtonOrderJoined: $transactionButtonOrderJoined, ',
          )
          ..write('themeName: $themeName, ')
          ..write('themeChangesAppIcon: $themeChangesAppIcon, ')
          ..write('changeVisuals: $changeVisuals, ')
          ..write('transactionEntryFlowJson: $transactionEntryFlowJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionFilterPresetsTable extends TransactionFilterPresets
    with TableInfo<$TransactionFilterPresetsTable, DbTransactionFilterPreset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionFilterPresetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonTransactionFilterMeta =
      const VerificationMeta('jsonTransactionFilter');
  @override
  late final GeneratedColumn<String> jsonTransactionFilter =
      GeneratedColumn<String>(
        'json_transaction_filter',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdDate =
      GeneratedColumn<String>(
        'created_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>(
        $TransactionFilterPresetsTable.$convertercreatedDate,
      );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>(
        $TransactionFilterPresetsTable.$converterupdatedAtn,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    jsonTransactionFilter,
    createdDate,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_filter_presets';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbTransactionFilterPreset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('json_transaction_filter')) {
      context.handle(
        _jsonTransactionFilterMeta,
        jsonTransactionFilter.isAcceptableOrUnknown(
          data['json_transaction_filter']!,
          _jsonTransactionFilterMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_jsonTransactionFilterMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbTransactionFilterPreset map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbTransactionFilterPreset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      jsonTransactionFilter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json_transaction_filter'],
      )!,
      createdDate: $TransactionFilterPresetsTable.$convertercreatedDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_date'],
        )!,
      ),
      updatedAt: $TransactionFilterPresetsTable.$converterupdatedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        ),
      ),
    );
  }

  @override
  $TransactionFilterPresetsTable createAlias(String alias) {
    return $TransactionFilterPresetsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedDate =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterupdatedAtn =
      NullAwareTypeConverter.wrap($converterupdatedAt);
}

class DbTransactionFilterPreset extends DataClass
    implements Insertable<DbTransactionFilterPreset> {
  final String id;
  final String name;
  final String jsonTransactionFilter;
  final DateTime createdDate;
  final DateTime? updatedAt;
  const DbTransactionFilterPreset({
    required this.id,
    required this.name,
    required this.jsonTransactionFilter,
    required this.createdDate,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['json_transaction_filter'] = Variable<String>(jsonTransactionFilter);
    {
      map['created_date'] = Variable<String>(
        $TransactionFilterPresetsTable.$convertercreatedDate.toSql(createdDate),
      );
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(
        $TransactionFilterPresetsTable.$converterupdatedAtn.toSql(updatedAt),
      );
    }
    return map;
  }

  TransactionFilterPresetsCompanion toCompanion(bool nullToAbsent) {
    return TransactionFilterPresetsCompanion(
      id: Value(id),
      name: Value(name),
      jsonTransactionFilter: Value(jsonTransactionFilter),
      createdDate: Value(createdDate),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory DbTransactionFilterPreset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbTransactionFilterPreset(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      jsonTransactionFilter: serializer.fromJson<String>(
        json['jsonTransactionFilter'],
      ),
      createdDate: serializer.fromJson<DateTime>(json['createdDate']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'jsonTransactionFilter': serializer.toJson<String>(jsonTransactionFilter),
      'createdDate': serializer.toJson<DateTime>(createdDate),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  DbTransactionFilterPreset copyWith({
    String? id,
    String? name,
    String? jsonTransactionFilter,
    DateTime? createdDate,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => DbTransactionFilterPreset(
    id: id ?? this.id,
    name: name ?? this.name,
    jsonTransactionFilter: jsonTransactionFilter ?? this.jsonTransactionFilter,
    createdDate: createdDate ?? this.createdDate,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  DbTransactionFilterPreset copyWithCompanion(
    TransactionFilterPresetsCompanion data,
  ) {
    return DbTransactionFilterPreset(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      jsonTransactionFilter: data.jsonTransactionFilter.present
          ? data.jsonTransactionFilter.value
          : this.jsonTransactionFilter,
      createdDate: data.createdDate.present
          ? data.createdDate.value
          : this.createdDate,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbTransactionFilterPreset(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('jsonTransactionFilter: $jsonTransactionFilter, ')
          ..write('createdDate: $createdDate, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, jsonTransactionFilter, createdDate, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbTransactionFilterPreset &&
          other.id == this.id &&
          other.name == this.name &&
          other.jsonTransactionFilter == this.jsonTransactionFilter &&
          other.createdDate == this.createdDate &&
          other.updatedAt == this.updatedAt);
}

class TransactionFilterPresetsCompanion
    extends UpdateCompanion<DbTransactionFilterPreset> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> jsonTransactionFilter;
  final Value<DateTime> createdDate;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const TransactionFilterPresetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.jsonTransactionFilter = const Value.absent(),
    this.createdDate = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionFilterPresetsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String jsonTransactionFilter,
    required DateTime createdDate,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       jsonTransactionFilter = Value(jsonTransactionFilter),
       createdDate = Value(createdDate);
  static Insertable<DbTransactionFilterPreset> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? jsonTransactionFilter,
    Expression<String>? createdDate,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (jsonTransactionFilter != null)
        'json_transaction_filter': jsonTransactionFilter,
      if (createdDate != null) 'created_date': createdDate,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionFilterPresetsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? jsonTransactionFilter,
    Value<DateTime>? createdDate,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return TransactionFilterPresetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      jsonTransactionFilter:
          jsonTransactionFilter ?? this.jsonTransactionFilter,
      createdDate: createdDate ?? this.createdDate,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (jsonTransactionFilter.present) {
      map['json_transaction_filter'] = Variable<String>(
        jsonTransactionFilter.value,
      );
    }
    if (createdDate.present) {
      map['created_date'] = Variable<String>(
        $TransactionFilterPresetsTable.$convertercreatedDate.toSql(
          createdDate.value,
        ),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $TransactionFilterPresetsTable.$converterupdatedAtn.toSql(
          updatedAt.value,
        ),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionFilterPresetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('jsonTransactionFilter: $jsonTransactionFilter, ')
          ..write('createdDate: $createdDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionAttachmentsTable extends TransactionAttachments
    with TableInfo<$TransactionAttachmentsTable, DbTransactionAttachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionAttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attachmentIdMeta = const VerificationMeta(
    'attachmentId',
  );
  @override
  late final GeneratedColumn<String> attachmentId = GeneratedColumn<String>(
    'attachment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, transactionId, attachmentId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbTransactionAttachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('attachment_id')) {
      context.handle(
        _attachmentIdMeta,
        attachmentId.isAcceptableOrUnknown(
          data['attachment_id']!,
          _attachmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attachmentIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbTransactionAttachment map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbTransactionAttachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      attachmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attachment_id'],
      )!,
    );
  }

  @override
  $TransactionAttachmentsTable createAlias(String alias) {
    return $TransactionAttachmentsTable(attachedDatabase, alias);
  }
}

class DbTransactionAttachment extends DataClass
    implements Insertable<DbTransactionAttachment> {
  final String id;
  final String transactionId;
  final String attachmentId;
  const DbTransactionAttachment({
    required this.id,
    required this.transactionId,
    required this.attachmentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_id'] = Variable<String>(transactionId);
    map['attachment_id'] = Variable<String>(attachmentId);
    return map;
  }

  TransactionAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return TransactionAttachmentsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      attachmentId: Value(attachmentId),
    );
  }

  factory DbTransactionAttachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbTransactionAttachment(
      id: serializer.fromJson<String>(json['id']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      attachmentId: serializer.fromJson<String>(json['attachmentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionId': serializer.toJson<String>(transactionId),
      'attachmentId': serializer.toJson<String>(attachmentId),
    };
  }

  DbTransactionAttachment copyWith({
    String? id,
    String? transactionId,
    String? attachmentId,
  }) => DbTransactionAttachment(
    id: id ?? this.id,
    transactionId: transactionId ?? this.transactionId,
    attachmentId: attachmentId ?? this.attachmentId,
  );
  DbTransactionAttachment copyWithCompanion(
    TransactionAttachmentsCompanion data,
  ) {
    return DbTransactionAttachment(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      attachmentId: data.attachmentId.present
          ? data.attachmentId.value
          : this.attachmentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbTransactionAttachment(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('attachmentId: $attachmentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, transactionId, attachmentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbTransactionAttachment &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.attachmentId == this.attachmentId);
}

class TransactionAttachmentsCompanion
    extends UpdateCompanion<DbTransactionAttachment> {
  final Value<String> id;
  final Value<String> transactionId;
  final Value<String> attachmentId;
  final Value<int> rowid;
  const TransactionAttachmentsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.attachmentId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionAttachmentsCompanion.insert({
    this.id = const Value.absent(),
    required String transactionId,
    required String attachmentId,
    this.rowid = const Value.absent(),
  }) : transactionId = Value(transactionId),
       attachmentId = Value(attachmentId);
  static Insertable<DbTransactionAttachment> custom({
    Expression<String>? id,
    Expression<String>? transactionId,
    Expression<String>? attachmentId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (attachmentId != null) 'attachment_id': attachmentId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionAttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? transactionId,
    Value<String>? attachmentId,
    Value<int>? rowid,
  }) {
    return TransactionAttachmentsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      attachmentId: attachmentId ?? this.attachmentId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (attachmentId.present) {
      map['attachment_id'] = Variable<String>(attachmentId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionAttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('attachmentId: $attachmentId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetCategoriesTable extends BudgetCategories
    with TableInfo<$BudgetCategoriesTable, DbBudgetCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
  );
  static const VerificationMeta _budgetIdMeta = const VerificationMeta(
    'budgetId',
  );
  @override
  late final GeneratedColumn<String> budgetId = GeneratedColumn<String>(
    'budget_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, budgetId, categoryId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbBudgetCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('budget_id')) {
      context.handle(
        _budgetIdMeta,
        budgetId.isAcceptableOrUnknown(data['budget_id']!, _budgetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_budgetIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbBudgetCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbBudgetCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      budgetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}budget_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
    );
  }

  @override
  $BudgetCategoriesTable createAlias(String alias) {
    return $BudgetCategoriesTable(attachedDatabase, alias);
  }
}

class DbBudgetCategory extends DataClass
    implements Insertable<DbBudgetCategory> {
  final String id;
  final String budgetId;
  final String categoryId;
  const DbBudgetCategory({
    required this.id,
    required this.budgetId,
    required this.categoryId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['budget_id'] = Variable<String>(budgetId);
    map['category_id'] = Variable<String>(categoryId);
    return map;
  }

  BudgetCategoriesCompanion toCompanion(bool nullToAbsent) {
    return BudgetCategoriesCompanion(
      id: Value(id),
      budgetId: Value(budgetId),
      categoryId: Value(categoryId),
    );
  }

  factory DbBudgetCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbBudgetCategory(
      id: serializer.fromJson<String>(json['id']),
      budgetId: serializer.fromJson<String>(json['budgetId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'budgetId': serializer.toJson<String>(budgetId),
      'categoryId': serializer.toJson<String>(categoryId),
    };
  }

  DbBudgetCategory copyWith({
    String? id,
    String? budgetId,
    String? categoryId,
  }) => DbBudgetCategory(
    id: id ?? this.id,
    budgetId: budgetId ?? this.budgetId,
    categoryId: categoryId ?? this.categoryId,
  );
  DbBudgetCategory copyWithCompanion(BudgetCategoriesCompanion data) {
    return DbBudgetCategory(
      id: data.id.present ? data.id.value : this.id,
      budgetId: data.budgetId.present ? data.budgetId.value : this.budgetId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbBudgetCategory(')
          ..write('id: $id, ')
          ..write('budgetId: $budgetId, ')
          ..write('categoryId: $categoryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, budgetId, categoryId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbBudgetCategory &&
          other.id == this.id &&
          other.budgetId == this.budgetId &&
          other.categoryId == this.categoryId);
}

class BudgetCategoriesCompanion extends UpdateCompanion<DbBudgetCategory> {
  final Value<String> id;
  final Value<String> budgetId;
  final Value<String> categoryId;
  final Value<int> rowid;
  const BudgetCategoriesCompanion({
    this.id = const Value.absent(),
    this.budgetId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetCategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String budgetId,
    required String categoryId,
    this.rowid = const Value.absent(),
  }) : budgetId = Value(budgetId),
       categoryId = Value(categoryId);
  static Insertable<DbBudgetCategory> custom({
    Expression<String>? id,
    Expression<String>? budgetId,
    Expression<String>? categoryId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (budgetId != null) 'budget_id': budgetId,
      if (categoryId != null) 'category_id': categoryId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? budgetId,
    Value<String>? categoryId,
    Value<int>? rowid,
  }) {
    return BudgetCategoriesCompanion(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      categoryId: categoryId ?? this.categoryId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (budgetId.present) {
      map['budget_id'] = Variable<String>(budgetId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('budgetId: $budgetId, ')
          ..write('categoryId: $categoryId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$FlowDatabase extends GeneratedDatabase {
  _$FlowDatabase(QueryExecutor e) : super(e);
  $FlowDatabaseManager get managers => $FlowDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $TransactionTagsTable transactionTags = $TransactionTagsTable(
    this,
  );
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $RecurringTransactionsTable recurringTransactions =
      $RecurringTransactionsTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $UserPreferencesTableTable userPreferencesTable =
      $UserPreferencesTableTable(this);
  late final $TransactionFilterPresetsTable transactionFilterPresets =
      $TransactionFilterPresetsTable(this);
  late final $TransactionAttachmentsTable transactionAttachments =
      $TransactionAttachmentsTable(this);
  late final $BudgetCategoriesTable budgetCategories = $BudgetCategoriesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accounts,
    categories,
    transactions,
    tags,
    transactionTags,
    budgets,
    goals,
    recurringTransactions,
    attachments,
    profiles,
    userPreferencesTable,
    transactionFilterPresets,
    transactionAttachments,
    budgetCategories,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$AccountsTableCreateCompanionBuilder =
    AccountsCompanion Function({
      Value<String> id,
      required String name,
      required String currency,
      Value<double?> creditLimit,
      Value<int> sortOrder,
      required String type,
      Value<bool> excludeFromTotalBalance,
      Value<bool> archived,
      Value<String?> colorSchemeName,
      required String iconCode,
      required DateTime createdDate,
      Value<DateTime?> updatedAt,
      Value<bool?> isDeleted,
      Value<DateTime?> deletedDate,
      Value<int> rowid,
    });
typedef $$AccountsTableUpdateCompanionBuilder =
    AccountsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> currency,
      Value<double?> creditLimit,
      Value<int> sortOrder,
      Value<String> type,
      Value<bool> excludeFromTotalBalance,
      Value<bool> archived,
      Value<String?> colorSchemeName,
      Value<String> iconCode,
      Value<DateTime> createdDate,
      Value<DateTime?> updatedAt,
      Value<bool?> isDeleted,
      Value<DateTime?> deletedDate,
      Value<int> rowid,
    });

class $$AccountsTableFilterComposer
    extends Composer<_$FlowDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get excludeFromTotalBalance => $composableBuilder(
    column: $table.excludeFromTotalBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorSchemeName => $composableBuilder(
    column: $table.colorSchemeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdDate =>
      $composableBuilder(
        column: $table.createdDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get deletedDate =>
      $composableBuilder(
        column: $table.deletedDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$AccountsTableOrderingComposer
    extends Composer<_$FlowDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get excludeFromTotalBalance => $composableBuilder(
    column: $table.excludeFromTotalBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorSchemeName => $composableBuilder(
    column: $table.colorSchemeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedDate => $composableBuilder(
    column: $table.deletedDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$FlowDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get excludeFromTotalBalance => $composableBuilder(
    column: $table.excludeFromTotalBalance,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<String> get colorSchemeName => $composableBuilder(
    column: $table.colorSchemeName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get iconCode =>
      $composableBuilder(column: $table.iconCode, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdDate =>
      $composableBuilder(
        column: $table.createdDate,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deletedDate =>
      $composableBuilder(
        column: $table.deletedDate,
        builder: (column) => column,
      );
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$FlowDatabase,
          $AccountsTable,
          DbAccount,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (
            DbAccount,
            BaseReferences<_$FlowDatabase, $AccountsTable, DbAccount>,
          ),
          DbAccount,
          PrefetchHooks Function()
        > {
  $$AccountsTableTableManager(_$FlowDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<double?> creditLimit = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<bool> excludeFromTotalBalance = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<String?> colorSchemeName = const Value.absent(),
                Value<String> iconCode = const Value.absent(),
                Value<DateTime> createdDate = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool?> isDeleted = const Value.absent(),
                Value<DateTime?> deletedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                name: name,
                currency: currency,
                creditLimit: creditLimit,
                sortOrder: sortOrder,
                type: type,
                excludeFromTotalBalance: excludeFromTotalBalance,
                archived: archived,
                colorSchemeName: colorSchemeName,
                iconCode: iconCode,
                createdDate: createdDate,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                deletedDate: deletedDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                required String currency,
                Value<double?> creditLimit = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required String type,
                Value<bool> excludeFromTotalBalance = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<String?> colorSchemeName = const Value.absent(),
                required String iconCode,
                required DateTime createdDate,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool?> isDeleted = const Value.absent(),
                Value<DateTime?> deletedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                name: name,
                currency: currency,
                creditLimit: creditLimit,
                sortOrder: sortOrder,
                type: type,
                excludeFromTotalBalance: excludeFromTotalBalance,
                archived: archived,
                colorSchemeName: colorSchemeName,
                iconCode: iconCode,
                createdDate: createdDate,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                deletedDate: deletedDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$FlowDatabase,
      $AccountsTable,
      DbAccount,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (DbAccount, BaseReferences<_$FlowDatabase, $AccountsTable, DbAccount>),
      DbAccount,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      required String name,
      required String iconCode,
      Value<String?> colorSchemeName,
      required DateTime createdDate,
      Value<DateTime?> updatedAt,
      Value<bool?> isDeleted,
      Value<DateTime?> deletedDate,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> iconCode,
      Value<String?> colorSchemeName,
      Value<DateTime> createdDate,
      Value<DateTime?> updatedAt,
      Value<bool?> isDeleted,
      Value<DateTime?> deletedDate,
      Value<int> rowid,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$FlowDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorSchemeName => $composableBuilder(
    column: $table.colorSchemeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdDate =>
      $composableBuilder(
        column: $table.createdDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get deletedDate =>
      $composableBuilder(
        column: $table.deletedDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$FlowDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorSchemeName => $composableBuilder(
    column: $table.colorSchemeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedDate => $composableBuilder(
    column: $table.deletedDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$FlowDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconCode =>
      $composableBuilder(column: $table.iconCode, builder: (column) => column);

  GeneratedColumn<String> get colorSchemeName => $composableBuilder(
    column: $table.colorSchemeName,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get createdDate =>
      $composableBuilder(
        column: $table.createdDate,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deletedDate =>
      $composableBuilder(
        column: $table.deletedDate,
        builder: (column) => column,
      );
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$FlowDatabase,
          $CategoriesTable,
          DbCategory,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (
            DbCategory,
            BaseReferences<_$FlowDatabase, $CategoriesTable, DbCategory>,
          ),
          DbCategory,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$FlowDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> iconCode = const Value.absent(),
                Value<String?> colorSchemeName = const Value.absent(),
                Value<DateTime> createdDate = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool?> isDeleted = const Value.absent(),
                Value<DateTime?> deletedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                iconCode: iconCode,
                colorSchemeName: colorSchemeName,
                createdDate: createdDate,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                deletedDate: deletedDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                required String iconCode,
                Value<String?> colorSchemeName = const Value.absent(),
                required DateTime createdDate,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool?> isDeleted = const Value.absent(),
                Value<DateTime?> deletedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                iconCode: iconCode,
                colorSchemeName: colorSchemeName,
                createdDate: createdDate,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                deletedDate: deletedDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$FlowDatabase,
      $CategoriesTable,
      DbCategory,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (
        DbCategory,
        BaseReferences<_$FlowDatabase, $CategoriesTable, DbCategory>,
      ),
      DbCategory,
      PrefetchHooks Function()
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<String?> title,
      Value<String?> description,
      required double amount,
      required String currency,
      Value<bool?> isPending,
      Value<String?> subtype,
      Value<String?> extra,
      Value<List<String>?> extraTags,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> accountId,
      Value<String?> categoryId,
      required DateTime transactionDate,
      required DateTime createdDate,
      Value<DateTime?> updatedAt,
      Value<bool?> isDeleted,
      Value<DateTime?> deletedDate,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<String?> title,
      Value<String?> description,
      Value<double> amount,
      Value<String> currency,
      Value<bool?> isPending,
      Value<String?> subtype,
      Value<String?> extra,
      Value<List<String>?> extraTags,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> accountId,
      Value<String?> categoryId,
      Value<DateTime> transactionDate,
      Value<DateTime> createdDate,
      Value<DateTime?> updatedAt,
      Value<bool?> isDeleted,
      Value<DateTime?> deletedDate,
      Value<int> rowid,
    });

class $$TransactionsTableFilterComposer
    extends Composer<_$FlowDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPending => $composableBuilder(
    column: $table.isPending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtype => $composableBuilder(
    column: $table.subtype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extra => $composableBuilder(
    column: $table.extra,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
  get extraTags => $composableBuilder(
    column: $table.extraTags,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String>
  get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdDate =>
      $composableBuilder(
        column: $table.createdDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get deletedDate =>
      $composableBuilder(
        column: $table.deletedDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$FlowDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPending => $composableBuilder(
    column: $table.isPending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtype => $composableBuilder(
    column: $table.subtype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extra => $composableBuilder(
    column: $table.extra,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extraTags => $composableBuilder(
    column: $table.extraTags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedDate => $composableBuilder(
    column: $table.deletedDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$FlowDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<bool> get isPending =>
      $composableBuilder(column: $table.isPending, builder: (column) => column);

  GeneratedColumn<String> get subtype =>
      $composableBuilder(column: $table.subtype, builder: (column) => column);

  GeneratedColumn<String> get extra =>
      $composableBuilder(column: $table.extra, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get extraTags =>
      $composableBuilder(column: $table.extraTags, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get transactionDate =>
      $composableBuilder(
        column: $table.transactionDate,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime, String> get createdDate =>
      $composableBuilder(
        column: $table.createdDate,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deletedDate =>
      $composableBuilder(
        column: $table.deletedDate,
        builder: (column) => column,
      );
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$FlowDatabase,
          $TransactionsTable,
          DbTransaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            DbTransaction,
            BaseReferences<_$FlowDatabase, $TransactionsTable, DbTransaction>,
          ),
          DbTransaction,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableManager(_$FlowDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<bool?> isPending = const Value.absent(),
                Value<String?> subtype = const Value.absent(),
                Value<String?> extra = const Value.absent(),
                Value<List<String>?> extraTags = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<DateTime> transactionDate = const Value.absent(),
                Value<DateTime> createdDate = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool?> isDeleted = const Value.absent(),
                Value<DateTime?> deletedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                title: title,
                description: description,
                amount: amount,
                currency: currency,
                isPending: isPending,
                subtype: subtype,
                extra: extra,
                extraTags: extraTags,
                latitude: latitude,
                longitude: longitude,
                accountId: accountId,
                categoryId: categoryId,
                transactionDate: transactionDate,
                createdDate: createdDate,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                deletedDate: deletedDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                required double amount,
                required String currency,
                Value<bool?> isPending = const Value.absent(),
                Value<String?> subtype = const Value.absent(),
                Value<String?> extra = const Value.absent(),
                Value<List<String>?> extraTags = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                required DateTime transactionDate,
                required DateTime createdDate,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool?> isDeleted = const Value.absent(),
                Value<DateTime?> deletedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                title: title,
                description: description,
                amount: amount,
                currency: currency,
                isPending: isPending,
                subtype: subtype,
                extra: extra,
                extraTags: extraTags,
                latitude: latitude,
                longitude: longitude,
                accountId: accountId,
                categoryId: categoryId,
                transactionDate: transactionDate,
                createdDate: createdDate,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                deletedDate: deletedDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$FlowDatabase,
      $TransactionsTable,
      DbTransaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (
        DbTransaction,
        BaseReferences<_$FlowDatabase, $TransactionsTable, DbTransaction>,
      ),
      DbTransaction,
      PrefetchHooks Function()
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      Value<String> id,
      required String title,
      Value<String?> iconCode,
      Value<String?> colorSchemeName,
      Value<String?> type,
      Value<String?> payload,
      required DateTime createdDate,
      Value<DateTime?> updatedAt,
      Value<bool?> isDeleted,
      Value<DateTime?> deletedDate,
      Value<int> rowid,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> iconCode,
      Value<String?> colorSchemeName,
      Value<String?> type,
      Value<String?> payload,
      Value<DateTime> createdDate,
      Value<DateTime?> updatedAt,
      Value<bool?> isDeleted,
      Value<DateTime?> deletedDate,
      Value<int> rowid,
    });

class $$TagsTableFilterComposer extends Composer<_$FlowDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorSchemeName => $composableBuilder(
    column: $table.colorSchemeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdDate =>
      $composableBuilder(
        column: $table.createdDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get deletedDate =>
      $composableBuilder(
        column: $table.deletedDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$TagsTableOrderingComposer extends Composer<_$FlowDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorSchemeName => $composableBuilder(
    column: $table.colorSchemeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedDate => $composableBuilder(
    column: $table.deletedDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$FlowDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get iconCode =>
      $composableBuilder(column: $table.iconCode, builder: (column) => column);

  GeneratedColumn<String> get colorSchemeName => $composableBuilder(
    column: $table.colorSchemeName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdDate =>
      $composableBuilder(
        column: $table.createdDate,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deletedDate =>
      $composableBuilder(
        column: $table.deletedDate,
        builder: (column) => column,
      );
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$FlowDatabase,
          $TagsTable,
          DbTag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (DbTag, BaseReferences<_$FlowDatabase, $TagsTable, DbTag>),
          DbTag,
          PrefetchHooks Function()
        > {
  $$TagsTableTableManager(_$FlowDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> iconCode = const Value.absent(),
                Value<String?> colorSchemeName = const Value.absent(),
                Value<String?> type = const Value.absent(),
                Value<String?> payload = const Value.absent(),
                Value<DateTime> createdDate = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool?> isDeleted = const Value.absent(),
                Value<DateTime?> deletedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                title: title,
                iconCode: iconCode,
                colorSchemeName: colorSchemeName,
                type: type,
                payload: payload,
                createdDate: createdDate,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                deletedDate: deletedDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String title,
                Value<String?> iconCode = const Value.absent(),
                Value<String?> colorSchemeName = const Value.absent(),
                Value<String?> type = const Value.absent(),
                Value<String?> payload = const Value.absent(),
                required DateTime createdDate,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool?> isDeleted = const Value.absent(),
                Value<DateTime?> deletedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                title: title,
                iconCode: iconCode,
                colorSchemeName: colorSchemeName,
                type: type,
                payload: payload,
                createdDate: createdDate,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                deletedDate: deletedDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$FlowDatabase,
      $TagsTable,
      DbTag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (DbTag, BaseReferences<_$FlowDatabase, $TagsTable, DbTag>),
      DbTag,
      PrefetchHooks Function()
    >;
typedef $$TransactionTagsTableCreateCompanionBuilder =
    TransactionTagsCompanion Function({
      Value<String> id,
      required String transactionId,
      required String tagId,
      Value<int> rowid,
    });
typedef $$TransactionTagsTableUpdateCompanionBuilder =
    TransactionTagsCompanion Function({
      Value<String> id,
      Value<String> transactionId,
      Value<String> tagId,
      Value<int> rowid,
    });

class $$TransactionTagsTableFilterComposer
    extends Composer<_$FlowDatabase, $TransactionTagsTable> {
  $$TransactionTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagId => $composableBuilder(
    column: $table.tagId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionTagsTableOrderingComposer
    extends Composer<_$FlowDatabase, $TransactionTagsTable> {
  $$TransactionTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagId => $composableBuilder(
    column: $table.tagId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionTagsTableAnnotationComposer
    extends Composer<_$FlowDatabase, $TransactionTagsTable> {
  $$TransactionTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tagId =>
      $composableBuilder(column: $table.tagId, builder: (column) => column);
}

class $$TransactionTagsTableTableManager
    extends
        RootTableManager<
          _$FlowDatabase,
          $TransactionTagsTable,
          DbTransactionTag,
          $$TransactionTagsTableFilterComposer,
          $$TransactionTagsTableOrderingComposer,
          $$TransactionTagsTableAnnotationComposer,
          $$TransactionTagsTableCreateCompanionBuilder,
          $$TransactionTagsTableUpdateCompanionBuilder,
          (
            DbTransactionTag,
            BaseReferences<
              _$FlowDatabase,
              $TransactionTagsTable,
              DbTransactionTag
            >,
          ),
          DbTransactionTag,
          PrefetchHooks Function()
        > {
  $$TransactionTagsTableTableManager(
    _$FlowDatabase db,
    $TransactionTagsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionTagsCompanion(
                id: id,
                transactionId: transactionId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String transactionId,
                required String tagId,
                Value<int> rowid = const Value.absent(),
              }) => TransactionTagsCompanion.insert(
                id: id,
                transactionId: transactionId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$FlowDatabase,
      $TransactionTagsTable,
      DbTransactionTag,
      $$TransactionTagsTableFilterComposer,
      $$TransactionTagsTableOrderingComposer,
      $$TransactionTagsTableAnnotationComposer,
      $$TransactionTagsTableCreateCompanionBuilder,
      $$TransactionTagsTableUpdateCompanionBuilder,
      (
        DbTransactionTag,
        BaseReferences<_$FlowDatabase, $TransactionTagsTable, DbTransactionTag>,
      ),
      DbTransactionTag,
      PrefetchHooks Function()
    >;
typedef $$BudgetsTableCreateCompanionBuilder =
    BudgetsCompanion Function({
      Value<String> id,
      required String name,
      required String range,
      Value<bool> renewAutomatically,
      required double amount,
      required String currency,
      required DateTime createdDate,
      Value<DateTime?> updatedAt,
      Value<bool?> isDeleted,
      Value<DateTime?> deletedDate,
      Value<int> rowid,
    });
typedef $$BudgetsTableUpdateCompanionBuilder =
    BudgetsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> range,
      Value<bool> renewAutomatically,
      Value<double> amount,
      Value<String> currency,
      Value<DateTime> createdDate,
      Value<DateTime?> updatedAt,
      Value<bool?> isDeleted,
      Value<DateTime?> deletedDate,
      Value<int> rowid,
    });

class $$BudgetsTableFilterComposer
    extends Composer<_$FlowDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get range => $composableBuilder(
    column: $table.range,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get renewAutomatically => $composableBuilder(
    column: $table.renewAutomatically,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdDate =>
      $composableBuilder(
        column: $table.createdDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get deletedDate =>
      $composableBuilder(
        column: $table.deletedDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$FlowDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get range => $composableBuilder(
    column: $table.range,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get renewAutomatically => $composableBuilder(
    column: $table.renewAutomatically,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedDate => $composableBuilder(
    column: $table.deletedDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$FlowDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get range =>
      $composableBuilder(column: $table.range, builder: (column) => column);

  GeneratedColumn<bool> get renewAutomatically => $composableBuilder(
    column: $table.renewAutomatically,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdDate =>
      $composableBuilder(
        column: $table.createdDate,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deletedDate =>
      $composableBuilder(
        column: $table.deletedDate,
        builder: (column) => column,
      );
}

class $$BudgetsTableTableManager
    extends
        RootTableManager<
          _$FlowDatabase,
          $BudgetsTable,
          DbBudget,
          $$BudgetsTableFilterComposer,
          $$BudgetsTableOrderingComposer,
          $$BudgetsTableAnnotationComposer,
          $$BudgetsTableCreateCompanionBuilder,
          $$BudgetsTableUpdateCompanionBuilder,
          (DbBudget, BaseReferences<_$FlowDatabase, $BudgetsTable, DbBudget>),
          DbBudget,
          PrefetchHooks Function()
        > {
  $$BudgetsTableTableManager(_$FlowDatabase db, $BudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> range = const Value.absent(),
                Value<bool> renewAutomatically = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime> createdDate = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool?> isDeleted = const Value.absent(),
                Value<DateTime?> deletedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion(
                id: id,
                name: name,
                range: range,
                renewAutomatically: renewAutomatically,
                amount: amount,
                currency: currency,
                createdDate: createdDate,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                deletedDate: deletedDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                required String range,
                Value<bool> renewAutomatically = const Value.absent(),
                required double amount,
                required String currency,
                required DateTime createdDate,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool?> isDeleted = const Value.absent(),
                Value<DateTime?> deletedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion.insert(
                id: id,
                name: name,
                range: range,
                renewAutomatically: renewAutomatically,
                amount: amount,
                currency: currency,
                createdDate: createdDate,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                deletedDate: deletedDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$FlowDatabase,
      $BudgetsTable,
      DbBudget,
      $$BudgetsTableFilterComposer,
      $$BudgetsTableOrderingComposer,
      $$BudgetsTableAnnotationComposer,
      $$BudgetsTableCreateCompanionBuilder,
      $$BudgetsTableUpdateCompanionBuilder,
      (DbBudget, BaseReferences<_$FlowDatabase, $BudgetsTable, DbBudget>),
      DbBudget,
      PrefetchHooks Function()
    >;
typedef $$GoalsTableCreateCompanionBuilder =
    GoalsCompanion Function({
      Value<String> id,
      required String name,
      Value<String?> range,
      required double targetBalance,
      required String currency,
      Value<String?> iconCode,
      Value<String?> accountId,
      required DateTime createdDate,
      Value<DateTime?> updatedAt,
      Value<bool?> isDeleted,
      Value<DateTime?> deletedDate,
      Value<int> rowid,
    });
typedef $$GoalsTableUpdateCompanionBuilder =
    GoalsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> range,
      Value<double> targetBalance,
      Value<String> currency,
      Value<String?> iconCode,
      Value<String?> accountId,
      Value<DateTime> createdDate,
      Value<DateTime?> updatedAt,
      Value<bool?> isDeleted,
      Value<DateTime?> deletedDate,
      Value<int> rowid,
    });

class $$GoalsTableFilterComposer extends Composer<_$FlowDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get range => $composableBuilder(
    column: $table.range,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetBalance => $composableBuilder(
    column: $table.targetBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdDate =>
      $composableBuilder(
        column: $table.createdDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get deletedDate =>
      $composableBuilder(
        column: $table.deletedDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$GoalsTableOrderingComposer
    extends Composer<_$FlowDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get range => $composableBuilder(
    column: $table.range,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetBalance => $composableBuilder(
    column: $table.targetBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedDate => $composableBuilder(
    column: $table.deletedDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$FlowDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get range =>
      $composableBuilder(column: $table.range, builder: (column) => column);

  GeneratedColumn<double> get targetBalance => $composableBuilder(
    column: $table.targetBalance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get iconCode =>
      $composableBuilder(column: $table.iconCode, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdDate =>
      $composableBuilder(
        column: $table.createdDate,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deletedDate =>
      $composableBuilder(
        column: $table.deletedDate,
        builder: (column) => column,
      );
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$FlowDatabase,
          $GoalsTable,
          DbGoal,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (DbGoal, BaseReferences<_$FlowDatabase, $GoalsTable, DbGoal>),
          DbGoal,
          PrefetchHooks Function()
        > {
  $$GoalsTableTableManager(_$FlowDatabase db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> range = const Value.absent(),
                Value<double> targetBalance = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> iconCode = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<DateTime> createdDate = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool?> isDeleted = const Value.absent(),
                Value<DateTime?> deletedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                name: name,
                range: range,
                targetBalance: targetBalance,
                currency: currency,
                iconCode: iconCode,
                accountId: accountId,
                createdDate: createdDate,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                deletedDate: deletedDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                Value<String?> range = const Value.absent(),
                required double targetBalance,
                required String currency,
                Value<String?> iconCode = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                required DateTime createdDate,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool?> isDeleted = const Value.absent(),
                Value<DateTime?> deletedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion.insert(
                id: id,
                name: name,
                range: range,
                targetBalance: targetBalance,
                currency: currency,
                iconCode: iconCode,
                accountId: accountId,
                createdDate: createdDate,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                deletedDate: deletedDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$FlowDatabase,
      $GoalsTable,
      DbGoal,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (DbGoal, BaseReferences<_$FlowDatabase, $GoalsTable, DbGoal>),
      DbGoal,
      PrefetchHooks Function()
    >;
typedef $$RecurringTransactionsTableCreateCompanionBuilder =
    RecurringTransactionsCompanion Function({
      Value<String> id,
      required String jsonTransactionTemplate,
      Value<String?> transferToAccountId,
      required String range,
      required List<String> rules,
      Value<DateTime?> lastGeneratedTransactionDate,
      Value<bool> disabled,
      required DateTime createdDate,
      Value<DateTime?> updatedAt,
      Value<bool?> isDeleted,
      Value<DateTime?> deletedDate,
      Value<int> rowid,
    });
typedef $$RecurringTransactionsTableUpdateCompanionBuilder =
    RecurringTransactionsCompanion Function({
      Value<String> id,
      Value<String> jsonTransactionTemplate,
      Value<String?> transferToAccountId,
      Value<String> range,
      Value<List<String>> rules,
      Value<DateTime?> lastGeneratedTransactionDate,
      Value<bool> disabled,
      Value<DateTime> createdDate,
      Value<DateTime?> updatedAt,
      Value<bool?> isDeleted,
      Value<DateTime?> deletedDate,
      Value<int> rowid,
    });

class $$RecurringTransactionsTableFilterComposer
    extends Composer<_$FlowDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jsonTransactionTemplate => $composableBuilder(
    column: $table.jsonTransactionTemplate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transferToAccountId => $composableBuilder(
    column: $table.transferToAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get range => $composableBuilder(
    column: $table.range,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get rules => $composableBuilder(
    column: $table.rules,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String>
  get lastGeneratedTransactionDate => $composableBuilder(
    column: $table.lastGeneratedTransactionDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get disabled => $composableBuilder(
    column: $table.disabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdDate =>
      $composableBuilder(
        column: $table.createdDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get deletedDate =>
      $composableBuilder(
        column: $table.deletedDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$RecurringTransactionsTableOrderingComposer
    extends Composer<_$FlowDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jsonTransactionTemplate => $composableBuilder(
    column: $table.jsonTransactionTemplate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transferToAccountId => $composableBuilder(
    column: $table.transferToAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get range => $composableBuilder(
    column: $table.range,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rules => $composableBuilder(
    column: $table.rules,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastGeneratedTransactionDate =>
      $composableBuilder(
        column: $table.lastGeneratedTransactionDate,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<bool> get disabled => $composableBuilder(
    column: $table.disabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedDate => $composableBuilder(
    column: $table.deletedDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecurringTransactionsTableAnnotationComposer
    extends Composer<_$FlowDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get jsonTransactionTemplate => $composableBuilder(
    column: $table.jsonTransactionTemplate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transferToAccountId => $composableBuilder(
    column: $table.transferToAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get range =>
      $composableBuilder(column: $table.range, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get rules =>
      $composableBuilder(column: $table.rules, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String>
  get lastGeneratedTransactionDate => $composableBuilder(
    column: $table.lastGeneratedTransactionDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get disabled =>
      $composableBuilder(column: $table.disabled, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdDate =>
      $composableBuilder(
        column: $table.createdDate,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deletedDate =>
      $composableBuilder(
        column: $table.deletedDate,
        builder: (column) => column,
      );
}

class $$RecurringTransactionsTableTableManager
    extends
        RootTableManager<
          _$FlowDatabase,
          $RecurringTransactionsTable,
          DbRecurringTransaction,
          $$RecurringTransactionsTableFilterComposer,
          $$RecurringTransactionsTableOrderingComposer,
          $$RecurringTransactionsTableAnnotationComposer,
          $$RecurringTransactionsTableCreateCompanionBuilder,
          $$RecurringTransactionsTableUpdateCompanionBuilder,
          (
            DbRecurringTransaction,
            BaseReferences<
              _$FlowDatabase,
              $RecurringTransactionsTable,
              DbRecurringTransaction
            >,
          ),
          DbRecurringTransaction,
          PrefetchHooks Function()
        > {
  $$RecurringTransactionsTableTableManager(
    _$FlowDatabase db,
    $RecurringTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringTransactionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RecurringTransactionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RecurringTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> jsonTransactionTemplate = const Value.absent(),
                Value<String?> transferToAccountId = const Value.absent(),
                Value<String> range = const Value.absent(),
                Value<List<String>> rules = const Value.absent(),
                Value<DateTime?> lastGeneratedTransactionDate =
                    const Value.absent(),
                Value<bool> disabled = const Value.absent(),
                Value<DateTime> createdDate = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool?> isDeleted = const Value.absent(),
                Value<DateTime?> deletedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringTransactionsCompanion(
                id: id,
                jsonTransactionTemplate: jsonTransactionTemplate,
                transferToAccountId: transferToAccountId,
                range: range,
                rules: rules,
                lastGeneratedTransactionDate: lastGeneratedTransactionDate,
                disabled: disabled,
                createdDate: createdDate,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                deletedDate: deletedDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String jsonTransactionTemplate,
                Value<String?> transferToAccountId = const Value.absent(),
                required String range,
                required List<String> rules,
                Value<DateTime?> lastGeneratedTransactionDate =
                    const Value.absent(),
                Value<bool> disabled = const Value.absent(),
                required DateTime createdDate,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool?> isDeleted = const Value.absent(),
                Value<DateTime?> deletedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringTransactionsCompanion.insert(
                id: id,
                jsonTransactionTemplate: jsonTransactionTemplate,
                transferToAccountId: transferToAccountId,
                range: range,
                rules: rules,
                lastGeneratedTransactionDate: lastGeneratedTransactionDate,
                disabled: disabled,
                createdDate: createdDate,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                deletedDate: deletedDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecurringTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$FlowDatabase,
      $RecurringTransactionsTable,
      DbRecurringTransaction,
      $$RecurringTransactionsTableFilterComposer,
      $$RecurringTransactionsTableOrderingComposer,
      $$RecurringTransactionsTableAnnotationComposer,
      $$RecurringTransactionsTableCreateCompanionBuilder,
      $$RecurringTransactionsTableUpdateCompanionBuilder,
      (
        DbRecurringTransaction,
        BaseReferences<
          _$FlowDatabase,
          $RecurringTransactionsTable,
          DbRecurringTransaction
        >,
      ),
      DbRecurringTransaction,
      PrefetchHooks Function()
    >;
typedef $$AttachmentsTableCreateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<String> id,
      Value<String?> name,
      required String filePath,
      required DateTime createdDate,
      Value<DateTime?> updatedAt,
      Value<bool?> isDeleted,
      Value<DateTime?> deletedDate,
      Value<int> rowid,
    });
typedef $$AttachmentsTableUpdateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<String> id,
      Value<String?> name,
      Value<String> filePath,
      Value<DateTime> createdDate,
      Value<DateTime?> updatedAt,
      Value<bool?> isDeleted,
      Value<DateTime?> deletedDate,
      Value<int> rowid,
    });

class $$AttachmentsTableFilterComposer
    extends Composer<_$FlowDatabase, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdDate =>
      $composableBuilder(
        column: $table.createdDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get deletedDate =>
      $composableBuilder(
        column: $table.deletedDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$FlowDatabase, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedDate => $composableBuilder(
    column: $table.deletedDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$FlowDatabase, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdDate =>
      $composableBuilder(
        column: $table.createdDate,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deletedDate =>
      $composableBuilder(
        column: $table.deletedDate,
        builder: (column) => column,
      );
}

class $$AttachmentsTableTableManager
    extends
        RootTableManager<
          _$FlowDatabase,
          $AttachmentsTable,
          DbAttachment,
          $$AttachmentsTableFilterComposer,
          $$AttachmentsTableOrderingComposer,
          $$AttachmentsTableAnnotationComposer,
          $$AttachmentsTableCreateCompanionBuilder,
          $$AttachmentsTableUpdateCompanionBuilder,
          (
            DbAttachment,
            BaseReferences<_$FlowDatabase, $AttachmentsTable, DbAttachment>,
          ),
          DbAttachment,
          PrefetchHooks Function()
        > {
  $$AttachmentsTableTableManager(_$FlowDatabase db, $AttachmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<DateTime> createdDate = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool?> isDeleted = const Value.absent(),
                Value<DateTime?> deletedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion(
                id: id,
                name: name,
                filePath: filePath,
                createdDate: createdDate,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                deletedDate: deletedDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> name = const Value.absent(),
                required String filePath,
                required DateTime createdDate,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool?> isDeleted = const Value.absent(),
                Value<DateTime?> deletedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion.insert(
                id: id,
                name: name,
                filePath: filePath,
                createdDate: createdDate,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                deletedDate: deletedDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$FlowDatabase,
      $AttachmentsTable,
      DbAttachment,
      $$AttachmentsTableFilterComposer,
      $$AttachmentsTableOrderingComposer,
      $$AttachmentsTableAnnotationComposer,
      $$AttachmentsTableCreateCompanionBuilder,
      $$AttachmentsTableUpdateCompanionBuilder,
      (
        DbAttachment,
        BaseReferences<_$FlowDatabase, $AttachmentsTable, DbAttachment>,
      ),
      DbAttachment,
      PrefetchHooks Function()
    >;
typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      Value<String> id,
      required String name,
      required DateTime createdDate,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> createdDate,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$ProfilesTableFilterComposer
    extends Composer<_$FlowDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdDate =>
      $composableBuilder(
        column: $table.createdDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$FlowDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$FlowDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdDate =>
      $composableBuilder(
        column: $table.createdDate,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$FlowDatabase,
          $ProfilesTable,
          DbProfile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (
            DbProfile,
            BaseReferences<_$FlowDatabase, $ProfilesTable, DbProfile>,
          ),
          DbProfile,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$FlowDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdDate = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                name: name,
                createdDate: createdDate,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                required DateTime createdDate,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                name: name,
                createdDate: createdDate,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$FlowDatabase,
      $ProfilesTable,
      DbProfile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (DbProfile, BaseReferences<_$FlowDatabase, $ProfilesTable, DbProfile>),
      DbProfile,
      PrefetchHooks Function()
    >;
typedef $$UserPreferencesTableTableCreateCompanionBuilder =
    UserPreferencesTableCompanion Function({
      Value<String> id,
      Value<bool> combineTransfers,
      Value<bool> excludeTransfersFromFlow,
      Value<int?> trashBinRetentionDays,
      Value<String?> defaultFilterPreset,
      Value<String?> homePendingTransactionsTimeRangeSerialized,
      Value<int?> remindDailyAtRelativeSeconds,
      Value<bool> useCategoryNameForUntitledTransactions,
      Value<bool> transactionListTileShowCategoryName,
      Value<bool> transactionListTileShowAccountForLeading,
      Value<bool> transactionListTileShowExternalSource,
      Value<bool> transactionListTileRelaxedDensity,
      Value<bool> createTransactionsPerItemInScans,
      Value<int?> scansPendingThresholdInHours,
      Value<bool> privacyModeUponLaunch,
      Value<bool> privacyModeUponShaking,
      Value<String?> icuCurrencyFormattingPattern,
      Value<String?> primaryCurrency,
      Value<String?> primaryAccountId,
      Value<int?> autoBackupIntervalInHours,
      Value<bool> enableICloudSync,
      Value<int?> iCloudBackupsToKeep,
      Value<String?> transactionButtonOrderJoined,
      Value<String?> themeName,
      Value<bool> themeChangesAppIcon,
      Value<String?> changeVisuals,
      Value<String?> transactionEntryFlowJson,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$UserPreferencesTableTableUpdateCompanionBuilder =
    UserPreferencesTableCompanion Function({
      Value<String> id,
      Value<bool> combineTransfers,
      Value<bool> excludeTransfersFromFlow,
      Value<int?> trashBinRetentionDays,
      Value<String?> defaultFilterPreset,
      Value<String?> homePendingTransactionsTimeRangeSerialized,
      Value<int?> remindDailyAtRelativeSeconds,
      Value<bool> useCategoryNameForUntitledTransactions,
      Value<bool> transactionListTileShowCategoryName,
      Value<bool> transactionListTileShowAccountForLeading,
      Value<bool> transactionListTileShowExternalSource,
      Value<bool> transactionListTileRelaxedDensity,
      Value<bool> createTransactionsPerItemInScans,
      Value<int?> scansPendingThresholdInHours,
      Value<bool> privacyModeUponLaunch,
      Value<bool> privacyModeUponShaking,
      Value<String?> icuCurrencyFormattingPattern,
      Value<String?> primaryCurrency,
      Value<String?> primaryAccountId,
      Value<int?> autoBackupIntervalInHours,
      Value<bool> enableICloudSync,
      Value<int?> iCloudBackupsToKeep,
      Value<String?> transactionButtonOrderJoined,
      Value<String?> themeName,
      Value<bool> themeChangesAppIcon,
      Value<String?> changeVisuals,
      Value<String?> transactionEntryFlowJson,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$UserPreferencesTableTableFilterComposer
    extends Composer<_$FlowDatabase, $UserPreferencesTableTable> {
  $$UserPreferencesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get combineTransfers => $composableBuilder(
    column: $table.combineTransfers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get excludeTransfersFromFlow => $composableBuilder(
    column: $table.excludeTransfersFromFlow,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trashBinRetentionDays => $composableBuilder(
    column: $table.trashBinRetentionDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultFilterPreset => $composableBuilder(
    column: $table.defaultFilterPreset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homePendingTransactionsTimeRangeSerialized =>
      $composableBuilder(
        column: $table.homePendingTransactionsTimeRangeSerialized,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<int> get remindDailyAtRelativeSeconds => $composableBuilder(
    column: $table.remindDailyAtRelativeSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get useCategoryNameForUntitledTransactions =>
      $composableBuilder(
        column: $table.useCategoryNameForUntitledTransactions,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<bool> get transactionListTileShowCategoryName =>
      $composableBuilder(
        column: $table.transactionListTileShowCategoryName,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<bool> get transactionListTileShowAccountForLeading =>
      $composableBuilder(
        column: $table.transactionListTileShowAccountForLeading,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<bool> get transactionListTileShowExternalSource =>
      $composableBuilder(
        column: $table.transactionListTileShowExternalSource,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<bool> get transactionListTileRelaxedDensity =>
      $composableBuilder(
        column: $table.transactionListTileRelaxedDensity,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<bool> get createTransactionsPerItemInScans =>
      $composableBuilder(
        column: $table.createTransactionsPerItemInScans,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<int> get scansPendingThresholdInHours => $composableBuilder(
    column: $table.scansPendingThresholdInHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get privacyModeUponLaunch => $composableBuilder(
    column: $table.privacyModeUponLaunch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get privacyModeUponShaking => $composableBuilder(
    column: $table.privacyModeUponShaking,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icuCurrencyFormattingPattern => $composableBuilder(
    column: $table.icuCurrencyFormattingPattern,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryCurrency => $composableBuilder(
    column: $table.primaryCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryAccountId => $composableBuilder(
    column: $table.primaryAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get autoBackupIntervalInHours => $composableBuilder(
    column: $table.autoBackupIntervalInHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enableICloudSync => $composableBuilder(
    column: $table.enableICloudSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iCloudBackupsToKeep => $composableBuilder(
    column: $table.iCloudBackupsToKeep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionButtonOrderJoined => $composableBuilder(
    column: $table.transactionButtonOrderJoined,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeName => $composableBuilder(
    column: $table.themeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get themeChangesAppIcon => $composableBuilder(
    column: $table.themeChangesAppIcon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get changeVisuals => $composableBuilder(
    column: $table.changeVisuals,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionEntryFlowJson => $composableBuilder(
    column: $table.transactionEntryFlowJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$UserPreferencesTableTableOrderingComposer
    extends Composer<_$FlowDatabase, $UserPreferencesTableTable> {
  $$UserPreferencesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get combineTransfers => $composableBuilder(
    column: $table.combineTransfers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get excludeTransfersFromFlow => $composableBuilder(
    column: $table.excludeTransfersFromFlow,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trashBinRetentionDays => $composableBuilder(
    column: $table.trashBinRetentionDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultFilterPreset => $composableBuilder(
    column: $table.defaultFilterPreset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homePendingTransactionsTimeRangeSerialized =>
      $composableBuilder(
        column: $table.homePendingTransactionsTimeRangeSerialized,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<int> get remindDailyAtRelativeSeconds => $composableBuilder(
    column: $table.remindDailyAtRelativeSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get useCategoryNameForUntitledTransactions =>
      $composableBuilder(
        column: $table.useCategoryNameForUntitledTransactions,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<bool> get transactionListTileShowCategoryName =>
      $composableBuilder(
        column: $table.transactionListTileShowCategoryName,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<bool> get transactionListTileShowAccountForLeading =>
      $composableBuilder(
        column: $table.transactionListTileShowAccountForLeading,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<bool> get transactionListTileShowExternalSource =>
      $composableBuilder(
        column: $table.transactionListTileShowExternalSource,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<bool> get transactionListTileRelaxedDensity =>
      $composableBuilder(
        column: $table.transactionListTileRelaxedDensity,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<bool> get createTransactionsPerItemInScans =>
      $composableBuilder(
        column: $table.createTransactionsPerItemInScans,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<int> get scansPendingThresholdInHours => $composableBuilder(
    column: $table.scansPendingThresholdInHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get privacyModeUponLaunch => $composableBuilder(
    column: $table.privacyModeUponLaunch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get privacyModeUponShaking => $composableBuilder(
    column: $table.privacyModeUponShaking,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icuCurrencyFormattingPattern =>
      $composableBuilder(
        column: $table.icuCurrencyFormattingPattern,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get primaryCurrency => $composableBuilder(
    column: $table.primaryCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryAccountId => $composableBuilder(
    column: $table.primaryAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get autoBackupIntervalInHours => $composableBuilder(
    column: $table.autoBackupIntervalInHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enableICloudSync => $composableBuilder(
    column: $table.enableICloudSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iCloudBackupsToKeep => $composableBuilder(
    column: $table.iCloudBackupsToKeep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionButtonOrderJoined =>
      $composableBuilder(
        column: $table.transactionButtonOrderJoined,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get themeName => $composableBuilder(
    column: $table.themeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get themeChangesAppIcon => $composableBuilder(
    column: $table.themeChangesAppIcon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changeVisuals => $composableBuilder(
    column: $table.changeVisuals,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionEntryFlowJson => $composableBuilder(
    column: $table.transactionEntryFlowJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserPreferencesTableTableAnnotationComposer
    extends Composer<_$FlowDatabase, $UserPreferencesTableTable> {
  $$UserPreferencesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get combineTransfers => $composableBuilder(
    column: $table.combineTransfers,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get excludeTransfersFromFlow => $composableBuilder(
    column: $table.excludeTransfersFromFlow,
    builder: (column) => column,
  );

  GeneratedColumn<int> get trashBinRetentionDays => $composableBuilder(
    column: $table.trashBinRetentionDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultFilterPreset => $composableBuilder(
    column: $table.defaultFilterPreset,
    builder: (column) => column,
  );

  GeneratedColumn<String> get homePendingTransactionsTimeRangeSerialized =>
      $composableBuilder(
        column: $table.homePendingTransactionsTimeRangeSerialized,
        builder: (column) => column,
      );

  GeneratedColumn<int> get remindDailyAtRelativeSeconds => $composableBuilder(
    column: $table.remindDailyAtRelativeSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get useCategoryNameForUntitledTransactions =>
      $composableBuilder(
        column: $table.useCategoryNameForUntitledTransactions,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get transactionListTileShowCategoryName =>
      $composableBuilder(
        column: $table.transactionListTileShowCategoryName,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get transactionListTileShowAccountForLeading =>
      $composableBuilder(
        column: $table.transactionListTileShowAccountForLeading,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get transactionListTileShowExternalSource =>
      $composableBuilder(
        column: $table.transactionListTileShowExternalSource,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get transactionListTileRelaxedDensity =>
      $composableBuilder(
        column: $table.transactionListTileRelaxedDensity,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get createTransactionsPerItemInScans =>
      $composableBuilder(
        column: $table.createTransactionsPerItemInScans,
        builder: (column) => column,
      );

  GeneratedColumn<int> get scansPendingThresholdInHours => $composableBuilder(
    column: $table.scansPendingThresholdInHours,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get privacyModeUponLaunch => $composableBuilder(
    column: $table.privacyModeUponLaunch,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get privacyModeUponShaking => $composableBuilder(
    column: $table.privacyModeUponShaking,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icuCurrencyFormattingPattern =>
      $composableBuilder(
        column: $table.icuCurrencyFormattingPattern,
        builder: (column) => column,
      );

  GeneratedColumn<String> get primaryCurrency => $composableBuilder(
    column: $table.primaryCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get primaryAccountId => $composableBuilder(
    column: $table.primaryAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get autoBackupIntervalInHours => $composableBuilder(
    column: $table.autoBackupIntervalInHours,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enableICloudSync => $composableBuilder(
    column: $table.enableICloudSync,
    builder: (column) => column,
  );

  GeneratedColumn<int> get iCloudBackupsToKeep => $composableBuilder(
    column: $table.iCloudBackupsToKeep,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transactionButtonOrderJoined =>
      $composableBuilder(
        column: $table.transactionButtonOrderJoined,
        builder: (column) => column,
      );

  GeneratedColumn<String> get themeName =>
      $composableBuilder(column: $table.themeName, builder: (column) => column);

  GeneratedColumn<bool> get themeChangesAppIcon => $composableBuilder(
    column: $table.themeChangesAppIcon,
    builder: (column) => column,
  );

  GeneratedColumn<String> get changeVisuals => $composableBuilder(
    column: $table.changeVisuals,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transactionEntryFlowJson => $composableBuilder(
    column: $table.transactionEntryFlowJson,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime?, String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserPreferencesTableTableTableManager
    extends
        RootTableManager<
          _$FlowDatabase,
          $UserPreferencesTableTable,
          DbUserPreferences,
          $$UserPreferencesTableTableFilterComposer,
          $$UserPreferencesTableTableOrderingComposer,
          $$UserPreferencesTableTableAnnotationComposer,
          $$UserPreferencesTableTableCreateCompanionBuilder,
          $$UserPreferencesTableTableUpdateCompanionBuilder,
          (
            DbUserPreferences,
            BaseReferences<
              _$FlowDatabase,
              $UserPreferencesTableTable,
              DbUserPreferences
            >,
          ),
          DbUserPreferences,
          PrefetchHooks Function()
        > {
  $$UserPreferencesTableTableTableManager(
    _$FlowDatabase db,
    $UserPreferencesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPreferencesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPreferencesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UserPreferencesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<bool> combineTransfers = const Value.absent(),
                Value<bool> excludeTransfersFromFlow = const Value.absent(),
                Value<int?> trashBinRetentionDays = const Value.absent(),
                Value<String?> defaultFilterPreset = const Value.absent(),
                Value<String?> homePendingTransactionsTimeRangeSerialized =
                    const Value.absent(),
                Value<int?> remindDailyAtRelativeSeconds = const Value.absent(),
                Value<bool> useCategoryNameForUntitledTransactions =
                    const Value.absent(),
                Value<bool> transactionListTileShowCategoryName =
                    const Value.absent(),
                Value<bool> transactionListTileShowAccountForLeading =
                    const Value.absent(),
                Value<bool> transactionListTileShowExternalSource =
                    const Value.absent(),
                Value<bool> transactionListTileRelaxedDensity =
                    const Value.absent(),
                Value<bool> createTransactionsPerItemInScans =
                    const Value.absent(),
                Value<int?> scansPendingThresholdInHours = const Value.absent(),
                Value<bool> privacyModeUponLaunch = const Value.absent(),
                Value<bool> privacyModeUponShaking = const Value.absent(),
                Value<String?> icuCurrencyFormattingPattern =
                    const Value.absent(),
                Value<String?> primaryCurrency = const Value.absent(),
                Value<String?> primaryAccountId = const Value.absent(),
                Value<int?> autoBackupIntervalInHours = const Value.absent(),
                Value<bool> enableICloudSync = const Value.absent(),
                Value<int?> iCloudBackupsToKeep = const Value.absent(),
                Value<String?> transactionButtonOrderJoined =
                    const Value.absent(),
                Value<String?> themeName = const Value.absent(),
                Value<bool> themeChangesAppIcon = const Value.absent(),
                Value<String?> changeVisuals = const Value.absent(),
                Value<String?> transactionEntryFlowJson = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserPreferencesTableCompanion(
                id: id,
                combineTransfers: combineTransfers,
                excludeTransfersFromFlow: excludeTransfersFromFlow,
                trashBinRetentionDays: trashBinRetentionDays,
                defaultFilterPreset: defaultFilterPreset,
                homePendingTransactionsTimeRangeSerialized:
                    homePendingTransactionsTimeRangeSerialized,
                remindDailyAtRelativeSeconds: remindDailyAtRelativeSeconds,
                useCategoryNameForUntitledTransactions:
                    useCategoryNameForUntitledTransactions,
                transactionListTileShowCategoryName:
                    transactionListTileShowCategoryName,
                transactionListTileShowAccountForLeading:
                    transactionListTileShowAccountForLeading,
                transactionListTileShowExternalSource:
                    transactionListTileShowExternalSource,
                transactionListTileRelaxedDensity:
                    transactionListTileRelaxedDensity,
                createTransactionsPerItemInScans:
                    createTransactionsPerItemInScans,
                scansPendingThresholdInHours: scansPendingThresholdInHours,
                privacyModeUponLaunch: privacyModeUponLaunch,
                privacyModeUponShaking: privacyModeUponShaking,
                icuCurrencyFormattingPattern: icuCurrencyFormattingPattern,
                primaryCurrency: primaryCurrency,
                primaryAccountId: primaryAccountId,
                autoBackupIntervalInHours: autoBackupIntervalInHours,
                enableICloudSync: enableICloudSync,
                iCloudBackupsToKeep: iCloudBackupsToKeep,
                transactionButtonOrderJoined: transactionButtonOrderJoined,
                themeName: themeName,
                themeChangesAppIcon: themeChangesAppIcon,
                changeVisuals: changeVisuals,
                transactionEntryFlowJson: transactionEntryFlowJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<bool> combineTransfers = const Value.absent(),
                Value<bool> excludeTransfersFromFlow = const Value.absent(),
                Value<int?> trashBinRetentionDays = const Value.absent(),
                Value<String?> defaultFilterPreset = const Value.absent(),
                Value<String?> homePendingTransactionsTimeRangeSerialized =
                    const Value.absent(),
                Value<int?> remindDailyAtRelativeSeconds = const Value.absent(),
                Value<bool> useCategoryNameForUntitledTransactions =
                    const Value.absent(),
                Value<bool> transactionListTileShowCategoryName =
                    const Value.absent(),
                Value<bool> transactionListTileShowAccountForLeading =
                    const Value.absent(),
                Value<bool> transactionListTileShowExternalSource =
                    const Value.absent(),
                Value<bool> transactionListTileRelaxedDensity =
                    const Value.absent(),
                Value<bool> createTransactionsPerItemInScans =
                    const Value.absent(),
                Value<int?> scansPendingThresholdInHours = const Value.absent(),
                Value<bool> privacyModeUponLaunch = const Value.absent(),
                Value<bool> privacyModeUponShaking = const Value.absent(),
                Value<String?> icuCurrencyFormattingPattern =
                    const Value.absent(),
                Value<String?> primaryCurrency = const Value.absent(),
                Value<String?> primaryAccountId = const Value.absent(),
                Value<int?> autoBackupIntervalInHours = const Value.absent(),
                Value<bool> enableICloudSync = const Value.absent(),
                Value<int?> iCloudBackupsToKeep = const Value.absent(),
                Value<String?> transactionButtonOrderJoined =
                    const Value.absent(),
                Value<String?> themeName = const Value.absent(),
                Value<bool> themeChangesAppIcon = const Value.absent(),
                Value<String?> changeVisuals = const Value.absent(),
                Value<String?> transactionEntryFlowJson = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserPreferencesTableCompanion.insert(
                id: id,
                combineTransfers: combineTransfers,
                excludeTransfersFromFlow: excludeTransfersFromFlow,
                trashBinRetentionDays: trashBinRetentionDays,
                defaultFilterPreset: defaultFilterPreset,
                homePendingTransactionsTimeRangeSerialized:
                    homePendingTransactionsTimeRangeSerialized,
                remindDailyAtRelativeSeconds: remindDailyAtRelativeSeconds,
                useCategoryNameForUntitledTransactions:
                    useCategoryNameForUntitledTransactions,
                transactionListTileShowCategoryName:
                    transactionListTileShowCategoryName,
                transactionListTileShowAccountForLeading:
                    transactionListTileShowAccountForLeading,
                transactionListTileShowExternalSource:
                    transactionListTileShowExternalSource,
                transactionListTileRelaxedDensity:
                    transactionListTileRelaxedDensity,
                createTransactionsPerItemInScans:
                    createTransactionsPerItemInScans,
                scansPendingThresholdInHours: scansPendingThresholdInHours,
                privacyModeUponLaunch: privacyModeUponLaunch,
                privacyModeUponShaking: privacyModeUponShaking,
                icuCurrencyFormattingPattern: icuCurrencyFormattingPattern,
                primaryCurrency: primaryCurrency,
                primaryAccountId: primaryAccountId,
                autoBackupIntervalInHours: autoBackupIntervalInHours,
                enableICloudSync: enableICloudSync,
                iCloudBackupsToKeep: iCloudBackupsToKeep,
                transactionButtonOrderJoined: transactionButtonOrderJoined,
                themeName: themeName,
                themeChangesAppIcon: themeChangesAppIcon,
                changeVisuals: changeVisuals,
                transactionEntryFlowJson: transactionEntryFlowJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserPreferencesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$FlowDatabase,
      $UserPreferencesTableTable,
      DbUserPreferences,
      $$UserPreferencesTableTableFilterComposer,
      $$UserPreferencesTableTableOrderingComposer,
      $$UserPreferencesTableTableAnnotationComposer,
      $$UserPreferencesTableTableCreateCompanionBuilder,
      $$UserPreferencesTableTableUpdateCompanionBuilder,
      (
        DbUserPreferences,
        BaseReferences<
          _$FlowDatabase,
          $UserPreferencesTableTable,
          DbUserPreferences
        >,
      ),
      DbUserPreferences,
      PrefetchHooks Function()
    >;
typedef $$TransactionFilterPresetsTableCreateCompanionBuilder =
    TransactionFilterPresetsCompanion Function({
      Value<String> id,
      required String name,
      required String jsonTransactionFilter,
      required DateTime createdDate,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$TransactionFilterPresetsTableUpdateCompanionBuilder =
    TransactionFilterPresetsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> jsonTransactionFilter,
      Value<DateTime> createdDate,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$TransactionFilterPresetsTableFilterComposer
    extends Composer<_$FlowDatabase, $TransactionFilterPresetsTable> {
  $$TransactionFilterPresetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jsonTransactionFilter => $composableBuilder(
    column: $table.jsonTransactionFilter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdDate =>
      $composableBuilder(
        column: $table.createdDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$TransactionFilterPresetsTableOrderingComposer
    extends Composer<_$FlowDatabase, $TransactionFilterPresetsTable> {
  $$TransactionFilterPresetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jsonTransactionFilter => $composableBuilder(
    column: $table.jsonTransactionFilter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionFilterPresetsTableAnnotationComposer
    extends Composer<_$FlowDatabase, $TransactionFilterPresetsTable> {
  $$TransactionFilterPresetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get jsonTransactionFilter => $composableBuilder(
    column: $table.jsonTransactionFilter,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get createdDate =>
      $composableBuilder(
        column: $table.createdDate,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TransactionFilterPresetsTableTableManager
    extends
        RootTableManager<
          _$FlowDatabase,
          $TransactionFilterPresetsTable,
          DbTransactionFilterPreset,
          $$TransactionFilterPresetsTableFilterComposer,
          $$TransactionFilterPresetsTableOrderingComposer,
          $$TransactionFilterPresetsTableAnnotationComposer,
          $$TransactionFilterPresetsTableCreateCompanionBuilder,
          $$TransactionFilterPresetsTableUpdateCompanionBuilder,
          (
            DbTransactionFilterPreset,
            BaseReferences<
              _$FlowDatabase,
              $TransactionFilterPresetsTable,
              DbTransactionFilterPreset
            >,
          ),
          DbTransactionFilterPreset,
          PrefetchHooks Function()
        > {
  $$TransactionFilterPresetsTableTableManager(
    _$FlowDatabase db,
    $TransactionFilterPresetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionFilterPresetsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TransactionFilterPresetsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TransactionFilterPresetsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> jsonTransactionFilter = const Value.absent(),
                Value<DateTime> createdDate = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionFilterPresetsCompanion(
                id: id,
                name: name,
                jsonTransactionFilter: jsonTransactionFilter,
                createdDate: createdDate,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                required String jsonTransactionFilter,
                required DateTime createdDate,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionFilterPresetsCompanion.insert(
                id: id,
                name: name,
                jsonTransactionFilter: jsonTransactionFilter,
                createdDate: createdDate,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionFilterPresetsTableProcessedTableManager =
    ProcessedTableManager<
      _$FlowDatabase,
      $TransactionFilterPresetsTable,
      DbTransactionFilterPreset,
      $$TransactionFilterPresetsTableFilterComposer,
      $$TransactionFilterPresetsTableOrderingComposer,
      $$TransactionFilterPresetsTableAnnotationComposer,
      $$TransactionFilterPresetsTableCreateCompanionBuilder,
      $$TransactionFilterPresetsTableUpdateCompanionBuilder,
      (
        DbTransactionFilterPreset,
        BaseReferences<
          _$FlowDatabase,
          $TransactionFilterPresetsTable,
          DbTransactionFilterPreset
        >,
      ),
      DbTransactionFilterPreset,
      PrefetchHooks Function()
    >;
typedef $$TransactionAttachmentsTableCreateCompanionBuilder =
    TransactionAttachmentsCompanion Function({
      Value<String> id,
      required String transactionId,
      required String attachmentId,
      Value<int> rowid,
    });
typedef $$TransactionAttachmentsTableUpdateCompanionBuilder =
    TransactionAttachmentsCompanion Function({
      Value<String> id,
      Value<String> transactionId,
      Value<String> attachmentId,
      Value<int> rowid,
    });

class $$TransactionAttachmentsTableFilterComposer
    extends Composer<_$FlowDatabase, $TransactionAttachmentsTable> {
  $$TransactionAttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attachmentId => $composableBuilder(
    column: $table.attachmentId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionAttachmentsTableOrderingComposer
    extends Composer<_$FlowDatabase, $TransactionAttachmentsTable> {
  $$TransactionAttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attachmentId => $composableBuilder(
    column: $table.attachmentId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionAttachmentsTableAnnotationComposer
    extends Composer<_$FlowDatabase, $TransactionAttachmentsTable> {
  $$TransactionAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attachmentId => $composableBuilder(
    column: $table.attachmentId,
    builder: (column) => column,
  );
}

class $$TransactionAttachmentsTableTableManager
    extends
        RootTableManager<
          _$FlowDatabase,
          $TransactionAttachmentsTable,
          DbTransactionAttachment,
          $$TransactionAttachmentsTableFilterComposer,
          $$TransactionAttachmentsTableOrderingComposer,
          $$TransactionAttachmentsTableAnnotationComposer,
          $$TransactionAttachmentsTableCreateCompanionBuilder,
          $$TransactionAttachmentsTableUpdateCompanionBuilder,
          (
            DbTransactionAttachment,
            BaseReferences<
              _$FlowDatabase,
              $TransactionAttachmentsTable,
              DbTransactionAttachment
            >,
          ),
          DbTransactionAttachment,
          PrefetchHooks Function()
        > {
  $$TransactionAttachmentsTableTableManager(
    _$FlowDatabase db,
    $TransactionAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionAttachmentsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TransactionAttachmentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TransactionAttachmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<String> attachmentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionAttachmentsCompanion(
                id: id,
                transactionId: transactionId,
                attachmentId: attachmentId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String transactionId,
                required String attachmentId,
                Value<int> rowid = const Value.absent(),
              }) => TransactionAttachmentsCompanion.insert(
                id: id,
                transactionId: transactionId,
                attachmentId: attachmentId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$FlowDatabase,
      $TransactionAttachmentsTable,
      DbTransactionAttachment,
      $$TransactionAttachmentsTableFilterComposer,
      $$TransactionAttachmentsTableOrderingComposer,
      $$TransactionAttachmentsTableAnnotationComposer,
      $$TransactionAttachmentsTableCreateCompanionBuilder,
      $$TransactionAttachmentsTableUpdateCompanionBuilder,
      (
        DbTransactionAttachment,
        BaseReferences<
          _$FlowDatabase,
          $TransactionAttachmentsTable,
          DbTransactionAttachment
        >,
      ),
      DbTransactionAttachment,
      PrefetchHooks Function()
    >;
typedef $$BudgetCategoriesTableCreateCompanionBuilder =
    BudgetCategoriesCompanion Function({
      Value<String> id,
      required String budgetId,
      required String categoryId,
      Value<int> rowid,
    });
typedef $$BudgetCategoriesTableUpdateCompanionBuilder =
    BudgetCategoriesCompanion Function({
      Value<String> id,
      Value<String> budgetId,
      Value<String> categoryId,
      Value<int> rowid,
    });

class $$BudgetCategoriesTableFilterComposer
    extends Composer<_$FlowDatabase, $BudgetCategoriesTable> {
  $$BudgetCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get budgetId => $composableBuilder(
    column: $table.budgetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetCategoriesTableOrderingComposer
    extends Composer<_$FlowDatabase, $BudgetCategoriesTable> {
  $$BudgetCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get budgetId => $composableBuilder(
    column: $table.budgetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetCategoriesTableAnnotationComposer
    extends Composer<_$FlowDatabase, $BudgetCategoriesTable> {
  $$BudgetCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get budgetId =>
      $composableBuilder(column: $table.budgetId, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );
}

class $$BudgetCategoriesTableTableManager
    extends
        RootTableManager<
          _$FlowDatabase,
          $BudgetCategoriesTable,
          DbBudgetCategory,
          $$BudgetCategoriesTableFilterComposer,
          $$BudgetCategoriesTableOrderingComposer,
          $$BudgetCategoriesTableAnnotationComposer,
          $$BudgetCategoriesTableCreateCompanionBuilder,
          $$BudgetCategoriesTableUpdateCompanionBuilder,
          (
            DbBudgetCategory,
            BaseReferences<
              _$FlowDatabase,
              $BudgetCategoriesTable,
              DbBudgetCategory
            >,
          ),
          DbBudgetCategory,
          PrefetchHooks Function()
        > {
  $$BudgetCategoriesTableTableManager(
    _$FlowDatabase db,
    $BudgetCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> budgetId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetCategoriesCompanion(
                id: id,
                budgetId: budgetId,
                categoryId: categoryId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String budgetId,
                required String categoryId,
                Value<int> rowid = const Value.absent(),
              }) => BudgetCategoriesCompanion.insert(
                id: id,
                budgetId: budgetId,
                categoryId: categoryId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$FlowDatabase,
      $BudgetCategoriesTable,
      DbBudgetCategory,
      $$BudgetCategoriesTableFilterComposer,
      $$BudgetCategoriesTableOrderingComposer,
      $$BudgetCategoriesTableAnnotationComposer,
      $$BudgetCategoriesTableCreateCompanionBuilder,
      $$BudgetCategoriesTableUpdateCompanionBuilder,
      (
        DbBudgetCategory,
        BaseReferences<
          _$FlowDatabase,
          $BudgetCategoriesTable,
          DbBudgetCategory
        >,
      ),
      DbBudgetCategory,
      PrefetchHooks Function()
    >;

class $FlowDatabaseManager {
  final _$FlowDatabase _db;
  $FlowDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$TransactionTagsTableTableManager get transactionTags =>
      $$TransactionTagsTableTableManager(_db, _db.transactionTags);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$RecurringTransactionsTableTableManager get recurringTransactions =>
      $$RecurringTransactionsTableTableManager(_db, _db.recurringTransactions);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$UserPreferencesTableTableTableManager get userPreferencesTable =>
      $$UserPreferencesTableTableTableManager(_db, _db.userPreferencesTable);
  $$TransactionFilterPresetsTableTableManager get transactionFilterPresets =>
      $$TransactionFilterPresetsTableTableManager(
        _db,
        _db.transactionFilterPresets,
      );
  $$TransactionAttachmentsTableTableManager get transactionAttachments =>
      $$TransactionAttachmentsTableTableManager(
        _db,
        _db.transactionAttachments,
      );
  $$BudgetCategoriesTableTableManager get budgetCategories =>
      $$BudgetCategoriesTableTableManager(_db, _db.budgetCategories);
}
