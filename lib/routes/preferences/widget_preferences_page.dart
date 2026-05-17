import "dart:async";

import "package:flow/entity/category.dart";
import "package:flow/objectbox.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/widget_summary_sync.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class WidgetPreferencesPage extends StatefulWidget {
  const WidgetPreferencesPage({super.key});

  @override
  State<WidgetPreferencesPage> createState() => _WidgetPreferencesPageState();
}

class _WidgetPreferencesPageState extends State<WidgetPreferencesPage> {
  late String _currentStyle;
  List<Category> _allCategories = [];
  Set<String> _selectedUuids = {};
  bool _showAll = true;

  @override
  void initState() {
    super.initState();

    _currentStyle = LocalPreferences().ynabWidgetStyle.value ?? "flow";

    // Load pinned category UUIDs
    final String? rawUuids =
        LocalPreferences().ynabWidgetCategoryUuids.value;
    if (rawUuids == null || rawUuids.isEmpty) {
      _showAll = true;
      _selectedUuids = {};
    } else {
      _showAll = false;
      _selectedUuids =
          rawUuids.split(",").where((s) => s.isNotEmpty).toSet();
    }

    // Load all categories from ObjectBox
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = ObjectBox().box<Category>().getAll();
    if (mounted) {
      setState(() {
        _allCategories = categories;
        // If show all, select all UUIDs
        if (_showAll) {
          _selectedUuids = categories.map((c) => c.uuid).toSet();
        }
      });
    }
  }

  void _onStyleChanged(String? value) {
    if (value == null) return;
    setState(() {
      _currentStyle = value;
    });
    LocalPreferences().ynabWidgetStyle.set(value);
    _syncWidget();
  }

  void _onCategoryToggled(String uuid, bool selected) {
    setState(() {
      if (selected) {
        _selectedUuids.add(uuid);
      } else {
        _selectedUuids.remove(uuid);
      }
      _showAll = _selectedUuids.length == _allCategories.length;
    });
    _saveCategories();
  }

  void _onSelectAll(bool selectAll) {
    setState(() {
      _showAll = selectAll;
      if (selectAll) {
        _selectedUuids = _allCategories.map((c) => c.uuid).toSet();
      } else {
        _selectedUuids.clear();
      }
    });
    _saveCategories();
  }

  void _saveCategories() {
    if (_showAll) {
      // Empty string = show all (default behavior)
      LocalPreferences().ynabWidgetCategoryUuids.set("");
    } else {
      LocalPreferences().ynabWidgetCategoryUuids.set(
        _selectedUuids.join(","),
      );
    }
    _syncWidget();
  }

  void _syncWidget() {
    unawaited(WidgetSummarySync.syncYnabWidget().catchError((_) {}));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Widget Settings")),
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 8.0),
            const ListHeader("Style"),
            const SizedBox(height: 8.0),
            RadioListTile<String>(
              title: const Text("Flow"),
              value: "flow",
              groupValue: _currentStyle,
              onChanged: _onStyleChanged,
              activeColor: colorScheme.primary,
              secondary: const Icon(Symbols.palette_rounded),
            ),
            RadioListTile<String>(
              title: const Text("AMOLED"),
              value: "amoled",
              groupValue: _currentStyle,
              onChanged: _onStyleChanged,
              activeColor: colorScheme.primary,
              secondary: const Icon(Symbols.dark_mode_rounded),
            ),
            const SizedBox(height: 24.0),
            const ListHeader("Categories"),
            const SizedBox(height: 8.0),
            SwitchListTile(
              title: const Text("Show all categories"),
              subtitle: const Text(
                "When enabled, all categories with activity this month are shown",
              ),
              value: _showAll,
              onChanged: (value) => _onSelectAll(value),
              activeColor: colorScheme.primary,
              secondary: const Icon(Symbols.select_all_rounded),
            ),
            if (!_showAll) ...[
              const Divider(),
              ..._allCategories.map((category) {
                final isSelected = _selectedUuids.contains(category.uuid);
                return CheckboxListTile(
                  title: Text(category.name),
                  value: isSelected,
                  onChanged: (value) =>
                      _onCategoryToggled(category.uuid, value ?? false),
                  activeColor: colorScheme.primary,
                );
              }),
            ],
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
