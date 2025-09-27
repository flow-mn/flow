import "package:flow/data/prefs/frecency_group.dart";
import "package:flow/entity/transaction_tag.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/transitive.dart";
import "package:flow/utils/extensions/iterables.dart";
import "package:flow/widgets/transaction_watcher.dart";
import "package:flutter/material.dart";

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

  @override
  Widget build(BuildContext context) => TransactionWatcher(
    builder: (context, _, _) {
      return StreamBuilder<Query<TransactionTag>>(
        stream: _queryBuilder().watch(triggerImmediately: true),
        builder: (context, snapshot) {
          final List<TransactionTag>? tags = snapshot.data?.find();

          if (tags != null) {
            final FrecencyGroup frecencyGroup = FrecencyGroup(
              tags
                  .map(
                    (tag) => TransitiveLocalPreferences().getFrecencyData(
                      "tag",
                      tag.uuid,
                    ),
                  )
                  .nonNulls
                  .toList(),
            );

            tags.sort(
              (a, b) => frecencyGroup
                  .getScore(b.uuid)
                  .compareTo(frecencyGroup.getScore(a.uuid)),
            );
          }

          return TransactionTagsProvider(tags, child: widget.child);
        },
      );
    },
  );
}

class TransactionTagsProvider extends InheritedWidget {
  final List<TransactionTag>? _tags;

  bool get ready => _tags != null;

  List<TransactionTag> get tags => _tags ?? [];

  String? getName(dynamic id) => get(id)?.title;

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
