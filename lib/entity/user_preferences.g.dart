// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) =>
    UserPreferences(
        combineTransfers: json['combineTransfers'] as bool? ?? true,
        excludeTransfersFromFlow:
            json['excludeTransfersFromFlow'] as bool? ?? true,
        useCategoryNameForUntitledTransactions:
            json['useCategoryNameForUntitledTransactions'] as bool? ?? false,
        transactionListTileShowCategoryName:
            json['transactionListTileShowCategoryName'] as bool? ?? false,
        transactionListTileShowAccountForLeading:
            json['transactionListTileShowAccountForLeading'] as bool? ?? false,
        transactionListTileShowExternalSource:
            json['transactionListTileShowExternalSource'] as bool? ?? true,
        transactionListTileRelaxedDensity:
            json['transactionListTileRelaxedDensity'] as bool? ?? false,
        createTransactionsPerItemInScans:
            json['createTransactionsPerItemInScans'] as bool? ?? true,
        scansPendingThresholdInHours:
            (json['scansPendingThresholdInHours'] as num?)?.toInt() ?? 6,
        privacyModeUponLaunch: json['privacyModeUponLaunch'] as bool? ?? false,
        privacyModeUponShaking:
            json['privacyModeUponShaking'] as bool? ?? false,
        trashBinRetentionDays:
            (json['trashBinRetentionDays'] as num?)?.toInt() ?? 30,
        defaultFilterPreset: json['defaultFilterPreset'] as String?,
        enableICloudSync: json['enableICloudSync'] as bool? ?? false,
        iCloudBackupsToKeep:
            (json['iCloudBackupsToKeep'] as num?)?.toInt() ?? 10,
        autoBackupIntervalInHours:
            (json['autoBackupIntervalInHours'] as num?)?.toInt() ?? 72,
        icuCurrencyFormattingPattern:
            json['icuCurrencyFormattingPattern'] as String?,
        primaryCurrency: json['primaryCurrency'] as String?,
        primaryAccountUuid: json['primaryAccountUuid'] as String?,
        transactionButtonOrderJoined:
            json['transactionButtonOrderJoined'] as String?,
        remindDailyAtRelativeSeconds:
            (json['remindDailyAtRelativeSeconds'] as num?)?.toInt(),
        themeName: json['themeName'] as String?,
        transactionEntryFlowJson: json['transactionEntryFlowJson'] as String?,
        themeChangesAppIcon: json['themeChangesAppIcon'] as bool? ?? true,
      )
      ..uuid = json['uuid'] as String
      ..changeVisuals = json['changeVisuals'] as String?;

Map<String, dynamic> _$UserPreferencesToJson(
  UserPreferences instance,
) => <String, dynamic>{
  'uuid': instance.uuid,
  'combineTransfers': instance.combineTransfers,
  'excludeTransfersFromFlow': instance.excludeTransfersFromFlow,
  'trashBinRetentionDays': instance.trashBinRetentionDays,
  'defaultFilterPreset': instance.defaultFilterPreset,
  'remindDailyAtRelativeSeconds': instance.remindDailyAtRelativeSeconds,
  'useCategoryNameForUntitledTransactions':
      instance.useCategoryNameForUntitledTransactions,
  'transactionListTileShowCategoryName':
      instance.transactionListTileShowCategoryName,
  'transactionListTileShowAccountForLeading':
      instance.transactionListTileShowAccountForLeading,
  'transactionListTileShowExternalSource':
      instance.transactionListTileShowExternalSource,
  'transactionListTileRelaxedDensity':
      instance.transactionListTileRelaxedDensity,
  'createTransactionsPerItemInScans': instance.createTransactionsPerItemInScans,
  'scansPendingThresholdInHours': instance.scansPendingThresholdInHours,
  'privacyModeUponLaunch': instance.privacyModeUponLaunch,
  'privacyModeUponShaking': instance.privacyModeUponShaking,
  'icuCurrencyFormattingPattern': instance.icuCurrencyFormattingPattern,
  'primaryCurrency': instance.primaryCurrency,
  'primaryAccountUuid': instance.primaryAccountUuid,
  'autoBackupIntervalInHours': instance.autoBackupIntervalInHours,
  'enableICloudSync': instance.enableICloudSync,
  'iCloudBackupsToKeep': instance.iCloudBackupsToKeep,
  'transactionButtonOrderJoined': instance.transactionButtonOrderJoined,
  'themeName': instance.themeName,
  'themeChangesAppIcon': instance.themeChangesAppIcon,
  'changeVisuals': instance.changeVisuals,
  'transactionEntryFlowJson': instance.transactionEntryFlowJson,
};
