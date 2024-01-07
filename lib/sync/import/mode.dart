enum ImportMode {
  /// Erases current data, then writes the imported data
  eraseAndWrite,

  /// Merges items with matching `uuid` or `name`, adds everything else
  ///
  /// If `uuid` matches, it uses `name` from the newest object (`createDate`)
  merge,
}
