import "dart:async";

import "package:flow/data/setup/default_categories.dart";
import "package:flow/entity/category.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/add_category_card.dart";
import "package:flow/widgets/category_card.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/setup/categories/category_preset_card.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:local_hero/local_hero.dart";
import "package:material_symbols_icons/symbols.dart";

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
            .any((existingCategory) => existingCategory.uuid == category.uuid))
        .toList();

    // Select all in upon loading
    for (final preset in presetCategories) {
      preset.id = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("setup.categories.setup".t(context)),
      ),
      body: SafeArea(
        child: StreamBuilder(
            stream: qb().watch(triggerImmediately: true),
            builder: (context, snapshot) {
              final List<Category> currentCategories =
                  snapshot.data?.find() ?? [];

              final Set<bool> presetSelections =
                  presetCategories.map((preset) => preset.id == 0).toSet();

              final bool? presetSelectedAll =
                  presetSelections.length == 1 ? presetSelections.first : null;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InfoText(
                        child: Text("setup.categories.description".t(context))),
                    if (presetCategories.isNotEmpty) ...[
                      const SizedBox(height: 8.0),
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: selectAll,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("general.select.all".t(context)),
                              const SizedBox(width: 8.0),
                              IgnorePointer(
                                child: Checkbox /*.adaptive*/ (
                                  value: presetSelectedAll,
                                  onChanged: (value) => (),
                                  tristate: true,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16.0),
                    const AddCategoryCard(),
                    const SizedBox(height: 16.0),
                    ...currentCategories.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: CategoryCard(
                          category: e,
                          onTapOverride: const Optional(null),
                          showAmount: false,
                        ),
                      ),
                    ),
                    LocalHeroScope(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: presetCategories
                            .map(
                              (preset) => LocalHero(
                                key: ValueKey(preset.uuid),
                                tag: preset.uuid,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: CategoryPresetCard(
                                    category: preset,
                                    onSelect: (selected) =>
                                        select(preset.uuid, selected),
                                    selected: preset.id == 0,
                                    preexisting: false,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              );
            }),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
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
      ),
    );
  }

  void select(String uuid, bool selected) {
    final Category? preset =
        presetCategories.firstWhereOrNull((element) => element.uuid == uuid);

    if (preset != null) {
      preset.id = selected ? 0 : -1;
    }

    presetCategories.sort((a, b) => b.id.compareTo(a.id));
    setState(() {});
  }

  void selectAll() {
    final bool select = presetCategories.any((element) => element.id == -1);

    for (int i = 0; i < presetCategories.length; i++) {
      presetCategories[i].id = select ? 0 : -1;
    }

    setState(() => {});
  }

  void save() async {
    if (busy) return;

    setState(() {
      busy = true;
    });

    try {
      final List<Category> selectedCategories =
          presetCategories.where((element) => element.id == 0).toList();

      await ObjectBox().box<Category>().putManyAsync(selectedCategories);

      presetCategories.removeWhere((element) =>
          selectedCategories.indexWhere(
            (selected) => element.uuid == selected.uuid,
          ) !=
          -1);

      if (mounted) {
        GoRouter.of(context).popUntil((route) => route.path == "/setup");

        context.pushReplacement("/");
      }

      unawaited(LocalPreferences().completedInitialSetup.set(true));
    } finally {
      busy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }
}
