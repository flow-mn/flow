import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flutter/material.dart";
import "package:flutter_typeahead/flutter_typeahead.dart";

class TitleInput extends StatelessWidget {
  final FocusNode focusNode;
  final TextEditingController controller;

  final int? selectedAccountId;
  final int? selectedCategoryId;
  final TransactionType transactionType;

  final double? amount;
  final String? currency;
  final DateTime? transactionDate;

  final String fallbackTitle;

  final Function(String) onSubmitted;

  const TitleInput({
    super.key,
    required this.focusNode,
    required this.controller,
    this.selectedAccountId,
    this.selectedCategoryId,
    this.amount,
    this.currency,
    this.transactionDate,
    required this.transactionType,
    required this.fallbackTitle,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Frame(
      child: TypeAheadField<RelevanceScoredTitle>(
        focusNode: focusNode,
        controller: controller,
        itemBuilder: (context, value) => ListTile(title: Text(value.title)),
        // TODO fix loading indicator appearing everytime i type
        debounceDuration: const Duration(milliseconds: 180),
        decorationBuilder:
            (context, child) => Material(
              clipBehavior: Clip.hardEdge,
              elevation: 1.0,
              borderRadius: BorderRadius.circular(16.0),
              child: child,
            ),
        onSelected: (option) => controller.text = option.title,
        suggestionsCallback: (query) => getAutocompleteOptions(query),
        builder: (context, controller, focusNode) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            style: context.textTheme.headlineMedium,
            textAlign: TextAlign.center,
            maxLength: Transaction.maxTitleLength,
            onSubmitted: onSubmitted,
            autocorrect: false,
            decoration: InputDecoration(
              hintText: fallbackTitle,
              counter: const SizedBox.shrink(),
            ),
          );
        },
        hideOnEmpty: true,
      ),
    );
  }

  Future<List<RelevanceScoredTitle>> getAutocompleteOptions(String query) =>
      ObjectBox()
          .transactionTitleSuggestions(
            currentInput: query,
            accountId: selectedAccountId,
            categoryId: selectedCategoryId,
            type: transactionType,
            amount: amount,
            currency: currency,
            transactionDate: transactionDate,
            limit: 5,
          )
          .then(
            (results) =>
                results
                    .where(
                      (item) => item.title != "transaction.fallbackTitle".tr(),
                    )
                    .toList(),
          );
}
