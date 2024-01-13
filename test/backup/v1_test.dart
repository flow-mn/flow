import 'dart:convert';
import 'dart:io';

import 'package:flow/entity/transaction.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/sync/export/export_v1.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'v1_populate.dart';

void main() async {
  group("Sync V1: Full backup and recover cycle", () async {
    const int dummyTransactionCount = 100;

    // Populate fake data
    setUpAll(() async {
      ObjectBox.initialize(
        customDirectory:
            path.join(Directory.current.path, "objectbox_test", "v1"),
        subdirectory: "populate",
      );

      await populateDummyData(dummyTransactionCount);
    });

    test(
      "Backup",
      () async {
        final String rawJsonContent = await generateBackupContentV1();
        final Map<String, dynamic> serialized = jsonDecode(rawJsonContent);

        expect(() => serialized.containsKey("transactions"), equals(true));
        expect(() => serialized.containsKey("accounts"), equals(true));
        expect(() => serialized.containsKey("categories"), equals(true));
        expect(() => serialized["versionCode"], 1);

        for (int i = 0; i < dummyTransactionCount; i++) {
          (serialized["transactions"] as List<Map<String, dynamic>>)
              .map((e) => Transaction.fromJson(e));
        }
      },
    );

    tearDownAll(() async {
      await ObjectBox().wipeDatabase();
    });
  });
}
