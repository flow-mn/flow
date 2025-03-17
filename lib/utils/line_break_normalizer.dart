import "dart:convert";

/// Converts all line breaks to [terminator], and get rid of empty lines.
class LineBreakNormalizer extends Converter<String, String> {
  static const String terminator = "\n";

  const LineBreakNormalizer();

  @override
  String convert(String input) => _normalize(input);

  @override
  Sink<String> startChunkedConversion(Sink<String> sink) {
    return LineBreakNormalizerSink(sink);
  }

  static String _normalize(String input) => input
      .replaceAll("\r\n", terminator)
      .replaceAll("\r", terminator)
      .replaceAll(RegExp(r"\s+$", multiLine: true), "");
}

class LineBreakNormalizerSink implements ChunkedConversionSink<String> {
  final Sink<String> _sink;

  LineBreakNormalizerSink(this._sink);

  @override
  void close() {
    _sink.close();
  }

  @override
  void add(String chunk) {
    _sink.add(LineBreakNormalizer._normalize(chunk));
  }
}
