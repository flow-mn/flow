import "dart:math";

import "package:flow/entity/transaction_filter_preset.dart";
import "package:flow/entity/user_preferences.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flutter/material.dart";

class UserPreferencesService {
  final ValueNotifier<UserPreferences> valueNotiifer = ValueNotifier(
    UserPreferences(),
  );

  UserPreferences get value => valueNotiifer.value;

  bool get combineTransfers => value.combineTransfers;
  set combineTransfers(bool newCombineTransfers) {
    if (value.id == 0) return;

    value.combineTransfers = newCombineTransfers;
    ObjectBox().box<UserPreferences>().put(value);
  }

  int? get trashBinRetentionDays => value.trashBinRetentionDays;
  set trashBinRetentionDays(int? newTrashBinRetentionDays) {
    if (value.id == 0) return;

    if (newTrashBinRetentionDays == null) {
      value.trashBinRetentionDays = null;
    } else {
      value.trashBinRetentionDays = min(max(0, newTrashBinRetentionDays), 365);
    }

    ObjectBox().box<UserPreferences>().put(value);
  }

  bool get excludeTransfersFromFlow => value.excludeTransfersFromFlow;
  set excludeTransfersFromFlow(bool newExcludeTransfersFromFlow) {
    if (value.id == 0) return;

    value.excludeTransfersFromFlow = newExcludeTransfersFromFlow;
    ObjectBox().box<UserPreferences>().put(value);
  }

  String? get defaultFilterPresetUuid => value.defaultFilterPreset;
  set defaultFilterPresetUuid(String? uuid) {
    if (value.id == 0) return;

    value.defaultFilterPreset = uuid;
    ObjectBox().box<UserPreferences>().put(value);
  }

  Duration? get remindDailyAt => value.remindDailyAt;
  set remindDailyAt(Duration? duration) {
    value.remindDailyAt = duration?.abs();
    ObjectBox().box<UserPreferences>().put(value);
  }

  TransactionFilterPreset? get defaultFilterPreset {
    if (defaultFilterPresetUuid == null) {
      return null;
    }

    final Query<TransactionFilterPreset> query =
        ObjectBox()
            .box<TransactionFilterPreset>()
            .query(
              TransactionFilterPreset_.uuid.equals(defaultFilterPresetUuid!),
            )
            .build();

    final TransactionFilterPreset? preset = query.findFirst();

    query.close();

    return preset;
  }

  static UserPreferencesService? _instance;

  factory UserPreferencesService() =>
      _instance ??= UserPreferencesService._internal();

  UserPreferencesService._internal();

  void initialize() {
    ObjectBox()
        .box<UserPreferences>()
        .query()
        .watch(triggerImmediately: true)
        .listen((event) {
          final UserPreferences? userPreferences = event.findFirst();

          if (userPreferences == null) {
            return;
          }

          valueNotiifer.value = userPreferences;
        });
  }
}
