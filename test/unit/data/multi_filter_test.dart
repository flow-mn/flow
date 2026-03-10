import "package:flow/data/multi_filter.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  test("MultiFilter filter method works correctly", () {
    final filter = MultiFilter.whitelist([1, 2, 3]);
    final input = [1, 2, 3, 4, 5];
    final result = filter.filter(input);
    expect(result, [1, 2, 3]);
  });

  test("MultiFilter blacklist works correctly", () {
    final filter = MultiFilter.blacklist([1, 2, 3]);
    final input = [1, 2, 3, 4, 5];
    final result = filter.filter(input);
    expect(result, [4, 5]);
  });

  test("MultiFilter with custom comparer works correctly", () {
    final filter = MultiFilter.whitelist([
      "run",
    ], comparer: (a, b) => a.length == b.length);
    final input = ["cat", "dog", "apple", "banana"];
    final result = filter.filter(input);
    expect(result, ["cat", "dog"]);
  });

  test(
    "MultiFilter with empty items should return all input for whitelist",
    () {
      final filter = MultiFilter.whitelist([]);
      final input = [1, 2, 3];
      final result = filter.filter(input);
      expect(result, []);
    },
  );

  test(
    "MultiFilter with empty items should return all input for blacklist",
    () {
      final filter = MultiFilter.blacklist([]);
      final input = [1, 2, 3];
      final result = filter.filter(input);
      expect(result, [1, 2, 3]);
    },
  );

  test("MultiFilter with all items should return empty for whitelist", () {
    final filter = MultiFilter.whitelist([1, 2, 3]);
    final input = [1, 2, 3];
    final result = filter.filter(input);
    expect(result, [1, 2, 3]);
  });

  test("MultiFilter with all items should return empty for blacklist", () {
    final filter = MultiFilter.blacklist([1, 2, 3]);
    final input = [1, 2, 3];
    final result = filter.filter(input);
    expect(result, []);
  });

  test("MultiFilter with duplicate items in whitelist", () {
    final filter = MultiFilter.whitelist([1, 1, 2, 2, 3]);
    final input = [1, 2, 3, 4, 5];
    final result = filter.filter(input);
    expect(result, [1, 2, 3]);
  });

  test("MultiFilter with duplicate items in blacklist", () {
    final filter = MultiFilter.blacklist([1, 1, 2, 2, 3]);
    final input = [1, 2, 3, 4, 5];
    final result = filter.filter(input);
    expect(result, [4, 5]);
  });

  test("MultiFilter set to keep nothing", () {
    final filter = MultiFilter.keepNothing();
    final input = [1, 2, 3, 4, 5];
    final result = filter.filter(input);
    expect(result, []);
  });

  test("MultiFilter set to keep everything", () {
    final filter = MultiFilter.keepEverything();
    final input = [1, 2, 3, 4, 5];
    final result = filter.filter(input);
    expect(result, [1, 2, 3, 4, 5]);
  });

  test("MultiFilter with empty input list", () {
    final filter = MultiFilter.whitelist([1, 2, 3]);
    final input = <int>[];
    final result = filter.filter(input);
    expect(result, []);
  });

  test("MultiFilter with mixed types in input and whitelist", () {
    final filter = MultiFilter.whitelist([1, "two", 3]);
    final input = [1, "two", 3, 4, "five"];
    final result = filter.filter(input);
    expect(result, [1, "two", 3]);
  });

  test("MultiFilter with mixed types in input and blacklist", () {
    final filter = MultiFilter.blacklist([1, "two", 3]);
    final input = [1, "two", 3, 4, "five"];
    final result = filter.filter(input);
    expect(result, [4, "five"]);
  });
}
