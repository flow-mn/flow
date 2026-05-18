import "dart:convert";
import "dart:io";
import "dart:typed_data";
import "package:charset/charset.dart";
import "package:csv/csv.dart";
import "package:flow/utils/line_break_normalizer.dart";
import "package:logging/logging.dart";

final Logger _log = Logger("CsvParser");

Future<List<List>> parseCsvFromFile(File file) async {
  final Uint8List bytes = file.readAsBytesSync();

  String? parsed;

  // Each decoder is tried in turn; logged at `fine` because non-matching
  // encodings are expected to throw — only the failure of all four is
  // user-visible (the throw at the bottom of this function).
  try {
    parsed = utf8.decode(bytes);
  } catch (e) {
    _log.fine("utf8 decode failed, trying next encoding", e);
  }

  if (parsed == null) {
    try {
      parsed = utf16.decode(bytes);
    } catch (e) {
      _log.fine("utf16 decode failed, trying next encoding", e);
    }
  }

  if (parsed == null) {
    try {
      parsed = utf32.decode(bytes);
    } catch (e) {
      _log.fine("utf32 decode failed, trying next encoding", e);
    }
  }

  if (parsed == null) {
    try {
      parsed = latin1.decode(bytes);
    } catch (e) {
      _log.fine("latin1 decode failed", e);
    }
  }

  if (parsed == null) {
    throw Exception(
      "Unsupported text encoding. Please provide a CSV with one of following encodings: ascii, utf8, utf16, utf32, latin1",
    );
  }

  final String lineBreaksNormalized = LineBreakNormalizer.normalize(parsed);

  return CsvToListConverter(
    eol: LineBreakNormalizer.terminator,
  ).convert(lineBreaksNormalized);
}
