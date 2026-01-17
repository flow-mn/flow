import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/routes/transaction_page/section.dart";
import "package:flow/routes/utils/edit_markdown_page.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flow/widgets/general/markdown_view.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:simple_icons/simple_icons.dart";

class DescriptionSection extends StatefulWidget {
  final String? value;
  final Function(String)? onChanged;
  final FocusNode? focusNode;

  const DescriptionSection({
    super.key,
    this.value,
    this.onChanged,
    this.focusNode,
  });

  @override
  State<DescriptionSection> createState() => _DescriptionSectionState();
}

class _DescriptionSectionState extends State<DescriptionSection> {
  final bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final bool noContent = widget.value == null || widget.value!.trim().isEmpty;

    return Section(
      titleOverride: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("transaction.description".t(context)),
          const SizedBox(width: 4.0),
          Tooltip(
            message: "transaction.description.markdownSupported".t(context),
            child: Icon(
              SimpleIcons.markdown,
              size: 16.0,
              fill: 0,
              color: context.flowColors.semi,
            ),
          ),
        ],
      ),
      child: noContent
          ? ListTile(
              onTap: () => showEditModal(context),
              title: Text("transaction.description.add".t(context)),
              leading: Icon(Symbols.add_notes_rounded),
              trailing: const DirectionalChevron(),
            )
          : InkWell(
              onTap: () => showEditModal(context),
              child: Container(
                color: _hovering ? context.colorScheme.surfaceDim : null,
                child: MarkdownView(
                  key: ValueKey(widget.value),
                  markdown: widget.value,
                  onChanged: widget.onChanged,
                  focusNode: widget.focusNode,
                ),
              ),
            ),
    );
  }

  void showEditModal(BuildContext context) async {
    final String? result = await context.push<String?>(
      "/utils/editmd",
      extra: EditMarkdownPageProps(
        initialValue: widget.value,
        maxLength: Transaction.maxDescriptionLength,
      ),
    );

    if (result == null) return;

    if (widget.onChanged != null) {
      widget.onChanged!(result);
    }
  }
}
