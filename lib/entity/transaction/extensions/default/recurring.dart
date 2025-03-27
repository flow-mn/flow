import "package:flow/entity/transaction/extensions/base.dart";
import "package:flow/utils/utils.dart";
import "package:json_annotation/json_annotation.dart";

part "recurring.g.dart";

/// By weekdays - mo, tu, we, th, fr, sa, su
/// By monthdays - 1 - 31 (clamped to 28-31)
/// Every n days
class Recurring extends TransactionExtension implements Jasonable {
  static const String name = "@flow/recurring";

  @override
  final String? relatedTransactionUuid;

  /// [moment_dart](https://pub.dev/packages/moment_dart) compatible TimeRange string
  ///
  /// If null, same as [Moment.minValue] to [Moment.maxValue]
  ///
  /// This is inclusive on both ends
  final String? range;

  final List<String> rules;

  @override
  @JsonKey(includeToJson: true)
  final String key = Recurring.name;

  factory Recurring.fromJson(Map<String, dynamic> json) =>
      _$RecurringFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$RecurringToJson(this);
}
