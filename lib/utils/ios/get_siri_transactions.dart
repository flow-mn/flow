import "dart:async";
import "dart:convert";
import "dart:io";

import "package:flow/constants.dart";
import "package:flow/data/transaction_programmable_object.dart";
import "package:flutter_app_group_directory/flutter_app_group_directory.dart";

final String _siriFileName = "recorded_transactions.jsonl";

Future<File?> _getAppGroupFile(String filename) async {
  try {
    final Directory? directory =
        await FlutterAppGroupDirectory.getAppGroupDirectory(iOSAppGroupId);

    if (directory == null) {
      throw Exception("App group directory not found");
    }

    final File file = File("${directory.path}/$filename");

    if (!(await file.exists())) {
      throw Exception("File not found");
    } else {
      return file;
    }
  } catch (e) {
    return null;
  }
}

Future<String?> _readAppGroupFile(String filename) async {
  try {
    final File? file = await _getAppGroupFile(filename);

    if (file == null) {
      throw Exception("File not found");
    }

    final String contents = await file.readAsString();
    return contents;
  } catch (e) {
    return null;
  }
}

/// Returns whether the file was successfully deleted or not.
/// If the file doesn't exist, it returns false.
Future<bool> _deleteAppGroupFile(String filename) async {
  try {
    final File? file = await _getAppGroupFile(filename);

    if (file == null) {
      throw Exception("File not found");
    }

    await file.delete();
    return true;
  } catch (e) {
    return false;
  }
}

Future<List<TransactionProgrammableObject>> getSiriTransactions() async {
  final String? fileContent = await _readAppGroupFile(_siriFileName);

  if (fileContent == null) {
    return [];
  }

  try {
    final List<String> lines = fileContent
        .split("\n")
        .where((line) => line.trim().isNotEmpty)
        .toList();

    final List<TransactionProgrammableObject> transactions = [];

    for (final String line in lines) {
      try {
        final TransactionProgrammableObject? transaction =
            TransactionProgrammableObject.fromSiriJson(jsonDecode(line));
        if (transaction != null) {
          transactions.add(transaction);
        }
      } catch (e) {
        // If a line is malformed, skip it and continue processing other lines
      }
    }

    unawaited(
      _deleteAppGroupFile("recorded_transactions.jsonl").catchError((_) {
        // If deletion fails, we can ignore it since it's not critical for the app's functionality
        return false;
      }),
    );

    return transactions;
  } catch (e) {
    return [];
  }
}
