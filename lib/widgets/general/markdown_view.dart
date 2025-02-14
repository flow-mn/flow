import "dart:developer";

import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions/toast.dart";
import "package:flow/utils/open_url.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flutter/material.dart";
import "package:super_editor/super_editor.dart";
import "package:super_editor_markdown/super_editor_markdown.dart";

class MarkdownView extends StatefulWidget {
  final String value;
  final FocusNode? focusNode;

  final Function(String)? onChanged;

  final bool allowTogglingCheckboxes;

  final bool shrinkWrap;

  const MarkdownView({
    super.key,
    required this.value,
    this.focusNode,
    this.onChanged,
    this.allowTogglingCheckboxes = false,
    this.shrinkWrap = true,
  });

  @override
  State<MarkdownView> createState() => _MarkdownViewState();
}

class _MarkdownViewState extends State<MarkdownView> {
  late Document _document;

  @override
  void initState() {
    super.initState();

    _document = deserializeMarkdownToDocument(
      widget.value,
    );
  }

  @override
  void didUpdateWidget(MarkdownView oldWidget) {
    if (oldWidget.value != widget.value) {
      _document = deserializeMarkdownToDocument(
        widget.value,
      );
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Frame(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: context.colorScheme.secondary,
        ),
        child: CustomScrollView(
          shrinkWrap: true,
          slivers: [
            SuperReader(
              document: _document,
              shrinkWrap: widget.shrinkWrap,
              stylesheet: context.superEditorTheme.stylesheet,
              selectionStyle: context.superEditorTheme.selectionStyles,
            ),
          ],
        ),
      ),
    );
  }

  void onTapLink(
    BuildContext context,
    String text,
    String? href,
    String title,
  ) {
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
