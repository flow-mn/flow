import "dart:async";

import "package:flow/data/prefs/frecency_group.dart";
import "package:flow/entity/transaction_tag.dart";
import "package:flow/entity/transaction_type/payload.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/transitive.dart";
import "package:flow/utils/extensions/iterables.dart";
import "package:flutter/material.dart";
import "package:latlong2/latlong.dart";

class TransactionTagsProviderScope extends StatefulWidget {
  final Widget child;

  const TransactionTagsProviderScope({super.key, required this.child});

  @override
  State<TransactionTagsProviderScope> createState() =>
      _TransactionTagsProviderScopeState();
}

class _TransactionTagsProviderScopeState
    extends State<TransactionTagsProviderScope> {
  QueryBuilder<TransactionTag> _queryBuilder() =>
      ObjectBox().box<TransactionTag>().query();
  late final StreamSubscription _subscription;

  List<TransactionTag>? _tags;

  @override
  void initState() {
    super.initState();
    _subscription = _queryBuilder()
        .watch(triggerImmediately: true)
        .listen(onData);
  }

  void onData(Query<TransactionTag> query) {
    setState(() {
      _tags = query.find();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      TransactionTagsProvider(_tags, child: widget.child);
}

class TransactionTagsProvider extends InheritedWidget {
  final List<TransactionTag>? _tags;

  bool get ready => _tags != null;

  /// Tags sorted by frecency
  List<TransactionTag> get tags {
    final List<TransactionTag> list = _tags ?? const [];
    if (list.isEmpty) return list;

    final FrecencyGroup frecencyGroup = FrecencyGroup(
      list
          .map(
            (tag) =>
                TransitiveLocalPreferences().getFrecencyData("tag", tag.uuid),
          )
          .nonNulls
          .toList(),
    );

    return [...list]..sort(
      (a, b) => frecencyGroup
          .getScore(b.uuid)
          .compareTo(frecencyGroup.getScore(a.uuid)),
    );
  }

  String? getName(dynamic id) => get(id)?.title;

  List<TransactionTag> getCloseGeoTags(
    LatLng latLng, {
    double thresholdInMeters = 50,
    List<TransactionTag>? exclusionList,
  }) {
    final Distance distance = const Distance();

    final List<(TransactionTag tag, double distanceInMeters)> tagsByDistance =
        tags
            .map((tag) {
              if (exclusionList?.any(
                    (excludedTag) => excludedTag.uuid == tag.uuid,
                  ) ==
                  true) {
                return (null, double.infinity);
              }
              if (tag.parsedPayload?.location
                  case TransactionTagLocationPayload locationPayload) {
                final double distanceInMeters = distance.as(
                  LengthUnit.Meter,
                  latLng,
                  locationPayload.latLng,
                );

                return (tag, distanceInMeters);
              }
              return (null, double.infinity);
            })
            .where(
              (tagAndDistance) =>
                  tagAndDistance.$1 != null &&
                  tagAndDistance.$2 <= thresholdInMeters,
            )
            .cast<(TransactionTag tag, double distanceInMeters)>()
            .toList();

    tagsByDistance.sort((a, b) => a.$2.compareTo(b.$2));

    return tagsByDistance.map((e) => e.$1).toList();
  }

  TransactionTag? get(dynamic id) => switch (id) {
    String uuid => _tags?.firstWhereOrNull((tag) => tag.uuid == uuid),
    int id => _tags?.firstWhereOrNull((tag) => tag.id == id),
    TransactionTag tag => _tags?.firstWhereOrNull(
      (element) => element.id == tag.id,
    ),
    _ => null,
  };

  const TransactionTagsProvider(this._tags, {super.key, required super.child});

  static TransactionTagsProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TransactionTagsProvider>()!;

  @override
  bool updateShouldNotify(TransactionTagsProvider oldWidget) =>
      !identical(_tags, oldWidget._tags);
}
