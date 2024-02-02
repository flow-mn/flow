import 'dart:developer';

import 'package:flow/data/flow_icon.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/entity/transaction.dart';
import 'package:flow/form_validators.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/objectbox.g.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/utils/utils.dart';
import 'package:flow/widgets/delete_button.dart';
import 'package:flow/widgets/general/flow_icon.dart';
import 'package:flow/widgets/select_icon_sheet.dart';
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
      _iconData?.toString() ?? FlowIconData.emoji("❌").toString();

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
  void dispose() {
    _nameTextController.dispose();
    super.dispose();
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
                if (_currentlyEditing != null) ...[
                  const SizedBox(height: 96.0),
                  DeleteButton(
                    onTap: _deleteCategory,
                  ),
                  const SizedBox(height: 16.0),
                ],
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
    log("_updateIcon_updateIcon_updateIcon_updateIcon");
    _iconData = data;
    setState(() {});
  }

  Future<void> selectIcon() async {
    onChange(FlowIconData? data) => _updateIcon(data);

    final result = await showModalBottomSheet<FlowIconData>(
      context: context,
      builder: (context) => SelectIconSheet(
        current: _iconData,
        onChange: onChange,
      ),
    );

    if (result != null) {
      _updateIcon(result);
    }

    if (mounted) setState(() {});
  }

  Future<void> _deleteCategory() async {
    if (_currentlyEditing == null) return;

    final associatedTransactionsQuery = ObjectBox()
        .box<Transaction>()
        .query(Transaction_.category.equals(_currentlyEditing!.id));

    final txnCount = associatedTransactionsQuery.build().count();

    final confirmation = await context.showConfirmDialog(
      isDeletionConfirmation: true,
      title: "general.delete.confirmName".t(context, _currentlyEditing!.name),
      child: Text(
        "category.delete.warning".t(context, txnCount),
      ),
    );

    if (confirmation == true) {
      ObjectBox().box<Category>().remove(_currentlyEditing!.id);

      if (mounted) {
        context.pop();
      }
    }
  }
}
