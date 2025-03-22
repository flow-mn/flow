import "package:flow/data/flow_icon.dart";

abstract class InternalNotification<T> {
  FlowIconData get icon;

  T get payload;

  /// Higher priority notifications will be shown first
  int get priority;
}
