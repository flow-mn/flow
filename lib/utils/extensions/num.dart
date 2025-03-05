import "dart:math";

extension NumberFormatter on num {
  /// Returns string with [decimalPlaces] decimal places.
  ///
  /// Example:
  /// `0.69.toStringAsFixed(2) => "69.00%"`
  String percent([int decimalPlaces = 1]) {
    return "${(this * 100).toStringAsFixed(decimalPlaces)}%";
  }

  /// No decimal places.
  ///
  /// Example:
  /// `0.69.percent2 => "69%"`
  String get percentInt => percent(0);

  /// One decimal places.
  ///
  /// Example:
  /// `0.691.percent2 => "69.1%"`
  String get percent1 => percent(1);

  /// Two decimal places.
  ///
  /// Example:
  /// `0.42.percent2 => "42.00%"`
  String get percent2 => percent(2);

  String get humanReadableBinarySize {
    const log1024 = 6.931471805599453;
    const formats = ["B", "KiB", "MiB", "GiB", "TiB", "PiB", "EiB"];

    final int unitIndex = (log(toDouble()) / log1024).floor();

    return "${(this / pow(1024, unitIndex)).toStringAsFixed(1)} ${formats[unitIndex]}";
  }
}
