import "dart:async";

import "package:flow/data/flow_icon.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/category.dart";
import "package:flow/form_validators.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/services/transactions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/delete_button.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/form_close_button.dart";
import "package:flow/widgets/sheets/select_flow_icon_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class CategoryEditPage extends StatefulWidget {
  final int categoryId;

  bool get isNewCategory => categoryId == 0;

  const CategoryEditPage.create({super.key}) : categoryId = 0;
  const CategoryEditPage({super.key, required this.categoryId});

  @override
  State<CategoryEditPage> createState() => _CategoryEditPageState();
}

class _CategoryEditPageState extends State<CategoryEditPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  late final TextEditingController _nameTextController;

  late FlowIconData? _iconData;

  late final Category? _currentlyEditing;

  String get iconCodeOrError =>
      _iconData?.toString() ??
      FlowIconData.icon(Symbols.category_rounded).toString();

  dynamic error;

  @override
  void initState() {
    super.initState();

    _currentlyEditing =
        widget.isNewCategory
            ? null
            : ObjectBox().box<Category>().get(widget.categoryId);

    if (!widget.isNewCategory && _currentlyEditing == null) {
      error = "Category with id ${widget.categoryId} was not found";
    } else {
      _nameTextController = TextEditingController(
        text: _currentlyEditing?.name,
      );
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
        leadingWidth: 40.0,
        leading: FormCloseButton(canPop: () => !hasChanged()),
        actions: [
          IconButton(
            onPressed: () => save(),
            icon: const Icon(Symbols.check_rounded),
            tooltip: "general.save".t(context),
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
                const SizedBox(height: 8.0),
                TextButton(
                  onPressed: selectIcon,
                  child: Text("flowIcon.change".t(context)),
                ),
                const SizedBox(height: 24.0),
                Padding(
                  padding: contentPadding,
                  child: TextFormField(
                    controller: _nameTextController,
                    maxLength: Category.maxNameLength,
                    decoration: InputDecoration(
                      label: Text("category.name".t(context)),
                      focusColor: context.colorScheme.secondary,
                      counter: const SizedBox.shrink(),
                    ),
                    validator: validateNameField,
                  ),
                ),
                if (_currentlyEditing != null) ...[
                  const SizedBox(height: 36.0),
                  DeleteButton(
                    onTap: _deleteCategory,
                    label: Text("category.delete".t(context)),
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

    _currentlyEditing.name = formattedName;
    _currentlyEditing.iconCode = iconCodeOrError;

    ObjectBox().box<Category>().put(_currentlyEditing, mode: PutMode.update);

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

    unawaited(
      ObjectBox().box<Category>().putAsync(category, mode: PutMode.insert),
    );

    context.pop();
  }

  bool hasChanged() {
    if (_currentlyEditing != null) {
      return _currentlyEditing.name != _nameTextController.text.trim() ||
          _currentlyEditing.iconCode != iconCodeOrError;
    }

    return _nameTextController.text.trim().isNotEmpty || _iconData != null;
  }

  String? validateNameField(String? value) {
    final requiredValidationError = validateRequiredField(value);
    if (requiredValidationError != null) {
      return requiredValidationError.t(context);
    }

    final String trimmed = value!.trim();

    final Query<Category> otherCategoriesWithSameNameQuery =
        ObjectBox()
            .box<Category>()
            .query(
              Category_.name
                  .equals(trimmed)
                  .and(Category_.id.notEquals(_currentlyEditing?.id ?? 0)),
            )
            .build();

    final bool isNameUnique = otherCategoriesWithSameNameQuery.count() == 0;

    otherCategoriesWithSameNameQuery.close();

    if (!isNameUnique) {
      return "error.input.duplicate.accountName".t(context, trimmed);
    }

    return null;
  }

  void _updateIcon(FlowIconData? data) {
    _iconData = data;
    setState(() {});
  }

  Future<void> selectIcon() async {
    final result = await showModalBottomSheet<FlowIconData>(
      context: context,
      builder: (context) => SelectFlowIconSheet(current: _iconData),
      isScrollControlled: true,
    );

    if (result != null) {
      _updateIcon(result);
    }

    if (mounted) setState(() {});
  }

  Future<void> _deleteCategory() async {
    if (_currentlyEditing == null) return;

    final TransactionFilter filter = TransactionFilter(
      categories: [_currentlyEditing.uuid],
    );

    final int txnCount = TransactionsService().countMany(filter);

    final bool? confirmation = await context.showConfirmationSheet(
      isDeletionConfirmation: true,
      title: "general.delete.confirmName".t(context, _currentlyEditing.name),
      child: Text("category.delete.description".t(context, txnCount)),
    );

    if (confirmation == true) {
      ObjectBox().box<Category>().remove(_currentlyEditing.id);

      if (mounted) {
        context.pop();
        GoRouter.of(context).popUntil((route) {
          return route.path != "/category/:id";
        });
      }
    }
  }
}
