import "package:flow/utils/extensions/quill_theme.dart";
import "package:flow/utils/flutter_quill/divider_embed_builder.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flutter/material.dart";
import "package:flutter_quill/flutter_quill.dart";
import "package:markdown/markdown.dart" as md;
import "package:markdown_quill/markdown_quill.dart";

class MarkdownView extends StatefulWidget {
  final String? markdown;
  final FocusNode? focusNode;

  final Function(String)? onChanged;

  const MarkdownView({
    super.key,
    required this.markdown,
    this.focusNode,
    this.onChanged,
  });

  @override
  State<MarkdownView> createState() => _MarkdownViewState();
}

class _MarkdownViewState extends State<MarkdownView> {
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  late final QuillController quillController;

  @override
  void initState() {
    super.initState();
    quillController = QuillController.basic(
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(enableExternalRichPaste: false),
      ),
    );
    final bool hasInitialValue =
        widget.markdown != null && widget.markdown!.trim().isNotEmpty;

    quillController.document = hasInitialValue
        ? Document.fromDelta(
            MarkdownToDelta(
              markdownDocument: md.Document(encodeHtml: false),
            ).convert(widget.markdown!),
          )
        : Document();
    quillController.readOnly = true;
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Frame(
        child: QuillEditor(
          focusNode: focusNode,
          scrollController: scrollController,
          controller: quillController,
          config: QuillEditorConfig(
            customStyles: context.quillDefaultStyles,
            embedBuilders: [DividerEmbedBuilder()],
          ),
        ),
      ),
    );
  }
}
