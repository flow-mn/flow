import "dart:developer";

import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/routes/new_transaction/section.dart";
import "package:flow/routes/utils/edit_markdown_page.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions/toast.dart";
import "package:flow/utils/open_url.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/markdown_view.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:simple_icons/simple_icons.dart";

class DescriptionSection extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;

  final Function(String)? onChanged;

  const DescriptionSection({
    super.key,
    required this.controller,
    this.focusNode,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool noContent = controller.text.trim().isEmpty;

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
          )
        ],
      ),
      child: noContent
          ? Align(
              alignment: Alignment.topLeft,
              child: Frame(
                child: TextButton(
                  onPressed: () => showEditModal(context),
                  child: Text(
                    "transaction.description.add".t(context),
                  ),
                ),
              ),
            )
          : Stack(
              children: [
                MarkdownView(
                  value: controller.text,
                  onChanged: onChanged,
                  focusNode: focusNode,
                  allowTogglingCheckboxes: true,
                ),
                Positioned(
                  right: 24.0,
                  top: 8.0,
                  child: IconButton(
                    isSelected: true,
                    icon: Icon(Symbols.edit_rounded),
                    onPressed: () => showEditModal(context),
                    tooltip: "general.edit".t(context),
                  ),
                ),
              ],
            ),
    );
  }

  void tryFlipCheckbox(int index, bool value) {
    if (controller.text.contains("```")) {
      log("[Flow] Cannot flip checkbox when markdown contains a code block");
      return;
    }

    log("[Flow] Flipping checkbox at [$index] to $value");

    try {
      final RegExpMatch match = RegExp(r"-\s\[(\s|x)\]", multiLine: true)
          .allMatches(controller.text)
          .elementAt(index);

      final String replacement = value ? "- [x]" : "- [ ]";

      final String newText = controller.text.replaceRange(
        match.start,
        match.end,
        replacement,
      );

      if (newText.length != controller.text.length) {
        throw Exception("Length mismatch");
      }

      controller.text = newText;

      if (onChanged != null) {
        onChanged!(newText);
      }
    } catch (e) {
      log("[Flow] Failed to flip checkbox at [$index]", error: e);
    }
  }

  void showEditModal(BuildContext context) async {
    final String? result = await context.push<String?>(
      "/utils/editmd",
      extra: EditMarkdownPageProps(
        initialValue: controller.text,
        maxLength: Transaction.maxDescriptionLength,
      ),
    );

    if (result == null) return;

    controller.text = result;
  }

  void onTapLink(
      BuildContext context, String text, String? href, String title) {
    log("[Flow] Tapped link: $text, $href, $title");

    if (href == null) {
      context.showErrorToast(
        error: "error.url.cannotOpen".t(context),
      );
      return;
    }

    final Uri? parsed = Uri.tryParse(href);
    if (parsed == null) {
      context.showErrorToast(
        error: "error.url.cannotOpen".t(context),
      );
      return;
    }

    openUrl(parsed).then((succeeded) {
      if (!succeeded && context.mounted) {
        context.showErrorToast(
          error: "error.url.cannotOpen".t(context),
        );
      }
    });
  }
}
