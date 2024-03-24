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
}
