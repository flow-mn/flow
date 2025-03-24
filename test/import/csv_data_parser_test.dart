import "dart:io";

import "package:flow/sync/model/csv/parsed_data.dart";
import "package:flow/sync/model/csv/parsers.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  test("A valid csv", () async {
    final valid = await CSVParsedData.fromFile(
      File("test/import/valid-1.csv"),
    ).then((v) => v as CSVParsedData?).catchError((e) => null);

    expect(valid, isNotNull);
    expect(valid?.accountNames.length, 3);
    expect(valid?.categoryNames.nonNulls.length, 24);
    expect(valid?.transactions.length, 81);
  });
  test("An invalid csv", () async {
    final invalid = await CSVParsedData.fromFile(
      File("test/import/invalid-1.csv"),
    ).then((e) => e as dynamic).catchError((e) => e);

    expect(invalid, CSVCellParserError.invalidDate);
  });
}
