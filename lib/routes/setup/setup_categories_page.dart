import 'package:flow/data/setup/default_categories.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/objectbox.g.dart';
import 'package:flow/utils/utils.dart';
import 'package:flow/widgets/add_category_card.dart';
import 'package:flow/widgets/button.dart';
import 'package:flow/widgets/category_card.dart';
import 'package:flow/widgets/info_text.dart';

import 'package:flow/widgets/setup/categories/category_preset_card.dart';
import 'package:flow/widgets/setup/setup_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class SetupCategoriesPage extends StatefulWidget {
  const SetupCategoriesPage({super.key});

  @override
  State<SetupCategoriesPage> createState() => _SetupCategoriesPageState();
}

class _SetupCategoriesPageState extends State<SetupCategoriesPage> {
  QueryBuilder<Category> qb() =>
      ObjectBox().box<Category>().query().order(Category_.createdDate);

  late final List<Category> presetCategories;

  bool busy = false;

  @override
  void initState() {
    super.initState();

    final Query<Category> existingCategoriesQuery = qb().build();

    final List<Category> existingCategories = existingCategoriesQuery.find();

    existingCategoriesQuery.close();

    presetCategories = getCategoryPresets()
        .where((category) => !existingCategories
            .any((existingCategory) => existingCategory.name == category.name))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: StreamBuilder(
            stream: qb().watch(triggerImmediately: true),
            builder: (context, snapshot) {
              final List<Category> currentCategories =
                  snapshot.data?.find() ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SetupHeader("setup.categories.setup".t(context)),
                    const SizedBox(height: 16.0),
                    const AddCategoryCard(),
                    const SizedBox(height: 16.0),
                    ...currentCategories.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: CategoryCard(
                          category: e,
                          onTapOverride: () => {},
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    if (presetCategories.isNotEmpty) ...[
                      InfoText(
                        child: Text(
                          "setup.accounts.preset.description".t(context),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                    ],
                    ...presetCategories.indexed.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: CategoryPresetCard(
                          category: e.$2,
                          onSelect: (selected) => select(e.$1, selected),
                          selected: e.$2.id == 0,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Spacer(),
            Button(
              onTap: busy ? null : save,
              trailing: const Icon(Symbols.chevron_right_rounded),
              child: Text("setup.next".t(context)),
            )
          ],
        ),
      ),
    );
  }

  void select(int index, bool selected) {
    presetCategories[index].id = selected ? 0 : -1;
    setState(() {});
  }

  void save() async {
    if (busy) return;

    try {
      final List<Category> selectedCategories =
          presetCategories.where((element) => element.id == 0).toList();

      await ObjectBox().box<Category>().putManyAsync(selectedCategories);

      if (mounted) {
        GoRouter.of(context).popUntil((route) => route.path == "/setup");

        context.pushReplacement("/");
      }
    } finally {
      busy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }
}
