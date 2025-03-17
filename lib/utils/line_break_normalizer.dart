import "dart:convert";

/// Converts all line breaks to [terminator]
class LineBreakNormalizer extends Converter<String, String> {
  static const String terminator = "\n";

  const LineBreakNormalizer();

  @override
  String convert(String input) {
    return input.replaceAll("\r\n", terminator).replaceAll("\r", terminator);
  }

  @override
  Sink<String> startChunkedConversion(Sink<String> sink) {
    return LineBreakNormalizerSink(sink);
  }
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
    _sink.add(
      chunk
          .replaceAll("\r\n", LineBreakNormalizer.terminator)
          .replaceAll("\r", LineBreakNormalizer.terminator),
    );
  }
}
