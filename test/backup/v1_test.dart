import 'dart:convert';

import 'package:flow/entity/transaction.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/sync/export/export_v1.dart';
import 'package:flutter_test/flutter_test.dart';

import '../database_test.dart';
import '../objectbox_erase.dart';
import 'v1_populate.dart';

void main() async {
  group("Sync V1: Full backup and recover cycle", () {
    const int dummyTransactionCount = 100;

    final String customDirectory = objectboxTestRootDir().path;

    // Populate fake data
    setUpAll(() async {
      await ObjectBox.initialize(
        customDirectory: customDirectory,
        subdirectory: "sync/v1",
      );

      await populateDummyData(dummyTransactionCount);
    });

    test(
      "Backup",
      () async {
        final String rawJsonContent = await generateBackupContentV1();
        final Map<String, dynamic> serialized = jsonDecode(rawJsonContent);

        expect(serialized.containsKey("transactions"), equals(true));
        expect(serialized.containsKey("accounts"), equals(true));
        expect(serialized.containsKey("categories"), equals(true));
        expect(serialized["versionCode"], 1);

        for (int i = 0; i < dummyTransactionCount; i++) {
          (serialized["transactions"] as List)
              .map((e) => Transaction.fromJson(e));
        }
      },
    );

    tearDownAll(() async {
      await testCleanupObject(
        instance: ObjectBox(),
        directory: ObjectBox.appDataDirectory,
        cleanUp: true,
      );
    });
  });
}
