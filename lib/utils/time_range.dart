import 'package:moment_dart/moment_dart.dart';

typedef TimeRange = ({DateTime from, DateTime to});

TimeRange thisWeek([DateTime? anchor]) {
  final now = anchor ?? DateTime.now();
  final from = now.startOfLocalWeek();
  final to = now.endOfLocalWeek();

  return (from: from, to: to);
}

TimeRange thisMonth([DateTime? anchor]) {
  final now = anchor ?? DateTime.now();
  final from = now.startOfMonth();
  final to = now.endOfMonth();

  return (from: from, to: to);
}
