import "dart:async";

import "package:flow/entity/category.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/utils/extensions/iterables.dart";
import "package:flutter/material.dart";

class CategoriesProviderScope extends StatefulWidget {
  final Widget child;

  const CategoriesProviderScope({super.key, required this.child});

  @override
  State<CategoriesProviderScope> createState() =>
      _CategoriesProviderScopeState();
}

class _CategoriesProviderScopeState extends State<CategoriesProviderScope> {
  QueryBuilder<Category> _queryBuilder() => ObjectBox().box<Category>().query();
  late final StreamSubscription _subscription;

  List<Category>? _categories;

  @override
  void initState() {
    super.initState();
    _subscription = _queryBuilder()
        .watch(triggerImmediately: true)
        .listen(onData);
  }

  void onData(Query<Category> query) {
    setState(() {
      _categories = query.find();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      CategoriesProvider(_categories, child: widget.child);
}

class CategoriesProvider extends InheritedWidget {
  final List<Category>? _categories;

  bool get ready => _categories != null;

  List<Category> get categories => _categories ?? [];

  List<String> get uuids =>
      categories.map((category) => category.uuid).toList();

  String? getName(dynamic id) => get(id)?.name;

  Category? get(dynamic id) => switch (id) {
    String uuid => _categories?.firstWhereOrNull(
      (category) => category.uuid == uuid,
    ),
    int id => _categories?.firstWhereOrNull((category) => category.id == id),
    Category category => _categories?.firstWhereOrNull(
      (element) => element.id == category.id,
    ),
    _ => null,
  };

  const CategoriesProvider(this._categories, {super.key, required super.child});

  static CategoriesProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CategoriesProvider>()!;

  @override
  bool updateShouldNotify(CategoriesProvider oldWidget) =>
      !identical(_categories, oldWidget._categories);
}
