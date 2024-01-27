import 'package:flow/data/flow_icon.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/form_validators.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/objectbox.g.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/general/flow_icon.dart';
import 'package:flow/widgets/select_icon_sheet.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class CategoryPage extends StatefulWidget {
  final int categoryId;

  bool get isNewCategory => categoryId == 0;

  const CategoryPage.create({
    super.key,
  }) : categoryId = 0;
  const CategoryPage.edit({super.key, required this.categoryId});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  late final TextEditingController _nameTextController;

  late FlowIconData? _iconData;

  late final Category? _currentlyEditing;

  String get iconCodeOrError =>
      _iconData?.toString() ?? FlowIconData.emoji("T").toString();

  dynamic error;

  @override
  void initState() {
    super.initState();

    _currentlyEditing = widget.isNewCategory
        ? null
        : ObjectBox().box<Category>().get(widget.categoryId);

    if (!widget.isNewCategory && _currentlyEditing == null) {
      error = "Category with id ${widget.categoryId} was not found";
    } else {
      _nameTextController =
          TextEditingController(text: _currentlyEditing?.name);
      _iconData = _currentlyEditing?.icon;
    }
  }

  @override
  Widget build(BuildContext context) {
    const contentPadding = EdgeInsets.symmetric(horizontal: 16.0);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => save(),
            icon: const Icon(
              Symbols.check_rounded,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16.0),
                FlowIcon(
                  _iconData ?? CharacterFlowIcon("T"),
                  size: 80.0,
                  plated: true,
                  onTap: selectIcon,
                ),
                const SizedBox(height: 16.0),
                Padding(
                  padding: contentPadding,
                  child: TextFormField(
                    controller: _nameTextController,
                    decoration: InputDecoration(
                      label: Text(
                        "category.name".t(context),
                      ),
                      focusColor: context.colorScheme.secondary,
                    ),
                    validator: validateNameField,
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> update({required String formattedName}) async {
    if (_currentlyEditing == null) return;

    _currentlyEditing!.name = formattedName;
    _currentlyEditing!.iconCode = iconCodeOrError;

    ObjectBox().box<Category>().put(
          _currentlyEditing!,
          mode: PutMode.update,
        );

    context.pop();
  }

  Future<void> save() async {
    if (_formKey.currentState?.validate() != true) return;

    final String trimmed = _nameTextController.text.trim();

    if (_currentlyEditing != null) {
      return update(formattedName: trimmed);
    }

    final Category category = Category(
      name: trimmed,
      iconCode: iconCodeOrError,
    );

    ObjectBox().box<Category>().putAsync(
          category,
          mode: PutMode.insert,
        );

    context.pop();
  }

  String? validateNameField(String? value) {
    final requiredValidationError = validateRequiredField(value);
    if (requiredValidationError != null) {
      return requiredValidationError.t(context);
    }

    final String trimmed = value!.trim();

    final isNameUnique = ObjectBox()
            .box<Category>()
            .query(
              Category_.name
                  .equals(trimmed)
                  .and(Category_.id.notEquals(_currentlyEditing?.id ?? 0)),
            )
            .build()
            .count() ==
        0;

    if (!isNameUnique) {
      return "error.input.duplicate.accountName".t(context, trimmed);
    }

    return null;
  }

  void _updateIcon(FlowIconData? data) {
    _iconData = data;
  }

  Future<void> selectIcon() async {
    // TODO Figure out ideal UI for emoji/icon selector
    if (!kDebugMode) throw UnimplementedError();

    final result = await showModalBottomSheet<FlowIconData>(
      context: context,
      builder: (context) => SelectIconSheet(
        current: _iconData,
        onChange: (value) => _updateIcon(value),
      ),
    );

    if (result != null) {
      _updateIcon(result);
    }

    if (mounted) setState(() {});
  }
}
