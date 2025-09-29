import "dart:async";
import "dart:math";

import "package:flow/data/flow_notification_payload.dart";
import "package:flow/data/prefs/change_visuals.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/transaction/type.dart";
import "package:flow/entity/transaction_filter_preset.dart";
import "package:flow/entity/user_preferences.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/services/currency_registry.dart";
import "package:flow/services/notifications.dart";
import "package:flow/services/sync.dart";
import "package:flow/theme/color_themes/registry.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";

class UserPreferencesService {
  final ValueNotifier<UserPreferences> valueNotifier = ValueNotifier(
    UserPreferences(),
  );

  UserPreferences get value => valueNotifier.value;

  bool get combineTransfers => value.combineTransfers;
  set combineTransfers(bool newCombineTransfers) {
    value.combineTransfers = newCombineTransfers;
    ObjectBox().box<UserPreferences>().put(value);
  }

  bool get enableICloudSync => value.enableICloudSync;
  set enableICloudSync(bool newEnableICloudSync) {
    value.enableICloudSync = newEnableICloudSync;
    ObjectBox().box<UserPreferences>().put(value);
  }

  bool get themeChangesAppIcon => value.themeChangesAppIcon;
  set themeChangesAppIcon(bool newThemeChangesAppIcon) {
    value.themeChangesAppIcon = newThemeChangesAppIcon;
    ObjectBox().box<UserPreferences>().put(value);
  }

  String get themeName {
    final String? savedThemeName = value.themeName;

    if (validateThemeName(savedThemeName)) {
      return savedThemeName!;
    }

    return flowLights.schemes.first.name;
  }

  String? get themeNameRaw => value.themeName;

  set themeName(String? newThemeName) {
    if (validateThemeName(newThemeName)) {
      value.themeName = newThemeName;
      ObjectBox().box<UserPreferences>().put(value);
    }
  }

  ChangeVisuals get changeVisuals {
    final ChangeVisuals? parsed = ChangeVisuals.tryParse(value.changeVisuals);

    return parsed ?? ChangeVisuals.defaults;
  }

  set changeVisuals(ChangeVisuals newChangeVisuals) {
    value.changeVisuals = newChangeVisuals.serialize();
    ObjectBox().box<UserPreferences>().put(value);
  }

  int? get trashBinRetentionDays => value.trashBinRetentionDays;
  set trashBinRetentionDays(int? newTrashBinRetentionDays) {
    if (newTrashBinRetentionDays == null) {
      value.trashBinRetentionDays = null;
    } else {
      value.trashBinRetentionDays = min(max(0, newTrashBinRetentionDays), 365);
    }

    ObjectBox().box<UserPreferences>().put(value);
  }

  int? get iCloudBackupsToKeep => value.iCloudBackupsToKeep;
  set iCloudBackupsToKeep(int? newICloudBackupsToKeep) {
    if (newICloudBackupsToKeep == null) return;

    value.trashBinRetentionDays = newICloudBackupsToKeep;

    ObjectBox().box<UserPreferences>().put(value);
  }

  int? get autoBackupIntervalInHours => value.autoBackupIntervalInHours;
  set autoBackupIntervalInHours(int? newAutobackupIntervalInHours) {
    if (newAutobackupIntervalInHours == null) {
      value.autoBackupIntervalInHours = null;
    } else {
      value.autoBackupIntervalInHours = min(
        max(0, newAutobackupIntervalInHours),
        8760,
      );
    }

    ObjectBox().box<UserPreferences>().put(value);

    SyncService().triggerAutoBackup();
  }

  bool get excludeTransfersFromFlow => value.excludeTransfersFromFlow;
  set excludeTransfersFromFlow(bool newExcludeTransfersFromFlow) {
    value.excludeTransfersFromFlow = newExcludeTransfersFromFlow;
    ObjectBox().box<UserPreferences>().put(value);
  }

  bool get useCategoryNameForUntitledTransactions =>
      value.useCategoryNameForUntitledTransactions;
  set useCategoryNameForUntitledTransactions(
    bool newUseCategoryNameForUntitledTransactions,
  ) {
    value.useCategoryNameForUntitledTransactions =
        newUseCategoryNameForUntitledTransactions;
    ObjectBox().box<UserPreferences>().put(value);
  }

  bool get transactionListTileShowCategoryName =>
      value.transactionListTileShowCategoryName;
  set transactionListTileShowCategoryName(
    bool newTransactionListTileShowCategoryName,
  ) {
    value.transactionListTileShowCategoryName =
        newTransactionListTileShowCategoryName;
    ObjectBox().box<UserPreferences>().put(value);
  }

  bool get transactionListTileRelaxedDensity =>
      value.transactionListTileRelaxedDensity;
  set transactionListTileRelaxedDensity(
    bool newTransactionListTileRelaxedDensity,
  ) {
    value.transactionListTileRelaxedDensity =
        newTransactionListTileRelaxedDensity;
    ObjectBox().box<UserPreferences>().put(value);
  }

  bool get transactionListTileShowAccountForLeading =>
      value.transactionListTileShowAccountForLeading;
  set transactionListTileShowAccountForLeading(
    bool newTransactionListTileShowAccountForLeading,
  ) {
    value.transactionListTileShowAccountForLeading =
        newTransactionListTileShowAccountForLeading;
    ObjectBox().box<UserPreferences>().put(value);
  }

  String? get defaultFilterPresetUuid => value.defaultFilterPreset;
  set defaultFilterPresetUuid(String? uuid) {
    value.defaultFilterPreset = uuid;
    ObjectBox().box<UserPreferences>().put(value);
  }

  String get primaryCurrency {
    if (value.primaryCurrency != null) {
      return value.primaryCurrency!;
    }

    late final String? firstAccountCurency;

    try {
      final Query<Account> firstAccountQuery = ObjectBox()
          .box<Account>()
          .query()
          .order(Account_.createdDate)
          .build();

      firstAccountCurency = firstAccountQuery.findFirst()?.currency;

      firstAccountQuery.close();
    } catch (e) {
      firstAccountCurency = null;
    }

    if (firstAccountCurency != null) {
      return primaryCurrency = firstAccountCurency;
    }

    // Generally, primary currency will be set up when the user first
    // opens the app. When recovering from a backup, backup logic should
    // handle setting this value.
    return primaryCurrency =
        NumberFormat.currency(
          locale: Intl.defaultLocale ?? "en_US",
        ).currencyName ??
        "USD";
  }

  set primaryCurrency(String? newPrimaryCurrency) {
    if (newPrimaryCurrency == null ||
        !CurrencyRegistryService().isCurrencyCodeValid(newPrimaryCurrency)) {
      throw ArgumentError("Invalid currency code: $newPrimaryCurrency");
    }

    value.primaryCurrency = newPrimaryCurrency;
    ObjectBox().box<UserPreferences>().put(value);
  }

  String? get icuCurrencyFormattingPattern =>
      value.icuCurrencyFormattingPattern;
  set icuCurrencyFormattingPattern(String? newIcuCurrencyFormattingPattern) {
    value.icuCurrencyFormattingPattern = newIcuCurrencyFormattingPattern;
    ObjectBox().box<UserPreferences>().put(value);
  }

  List<TransactionType> get transactionButtonOrder =>
      value.transactionButtonOrder;
  set transactionButtonOrder(List<TransactionType> order) {
    value.transactionButtonOrder = order;
    ObjectBox().box<UserPreferences>().put(value);
  }

  Duration? get remindDailyAt => value.remindDailyAt;
  set remindDailyAt(Duration? duration) {
    value.remindDailyAt = duration?.abs();
    ObjectBox().box<UserPreferences>().put(value);
    if (duration == null) {
      NotificationsService().clearByType(
        FlowNotificationPayloadItemType.reminder,
      );
    } else {
      NotificationsService().scheduleDailyReminders(duration);
    }
  }

  TransactionFilterPreset? get defaultFilterPreset {
    if (defaultFilterPresetUuid == null) {
      return null;
    }

    final Query<TransactionFilterPreset> query = ObjectBox()
        .box<TransactionFilterPreset>()
        .query(TransactionFilterPreset_.uuid.equals(defaultFilterPresetUuid!))
        .build();

    final TransactionFilterPreset? preset = query.findFirst();

    query.close();

    return preset;
  }

  static UserPreferencesService? _instance;

  factory UserPreferencesService() =>
      _instance ??= UserPreferencesService._internal();

  UserPreferencesService._internal();

  Future<void> initialize() async {
    final Completer<void> completer = Completer();

    ObjectBox()
        .box<UserPreferences>()
        .query()
        .watch(triggerImmediately: true)
        .listen((event) {
          try {
            final UserPreferences? userPreferences = event.findFirst();

            if (userPreferences == null) {
              return;
            }

            valueNotifier.value = userPreferences;
          } finally {
            if (!completer.isCompleted) {
              completer.complete();
            }
          }
        });

    return completer.future;
  }
}
