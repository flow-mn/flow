import "package:flow/l10n/flow_localizations.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/utils/extensions/quill_theme.dart";
import "package:flow/widgets/general/form_close_button.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flutter/material.dart";
import "package:flutter_quill/flutter_quill.dart";
import "package:go_router/go_router.dart";
import "package:markdown/markdown.dart" as md;
import "package:markdown_quill/markdown_quill.dart";
import "package:material_symbols_icons/symbols.dart";

class EditMarkdownPageProps {
  final String? initialValue;
  final int? maxLength;

  const EditMarkdownPageProps({this.initialValue, this.maxLength});
}

class EditMarkdownPage extends StatefulWidget {
  final String? initialValue;
  final int? maxLength;

  const EditMarkdownPage({super.key, this.initialValue, this.maxLength});
  EditMarkdownPage.fromProps({super.key, required EditMarkdownPageProps props})
    : initialValue = props.initialValue,
      maxLength = props.maxLength;

  @override
  State<EditMarkdownPage> createState() => _EditMarkdownPageState();
}

class _EditMarkdownPageState extends State<EditMarkdownPage> {
  late final QuillController _controller;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic(
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(
          enableExternalRichPaste: true,
          onRichTextPaste: (delta, isExternal) async {
            return MarkdownToDelta(
              markdownDocument: md.Document(encodeHtml: false),
            ).convert(DeltaToMarkdown().convert(delta));
          },
          onImagePaste: (imageBytes) async {
            return null;
          },
          onGifPaste: (imageBytes) async {
            return null;
          },
        ),
      ),
    );

    final bool hasInitialValue =
        widget.initialValue != null && widget.initialValue!.trim().isNotEmpty;

    _controller.document = hasInitialValue
        ? Document.fromDelta(
            MarkdownToDelta(
              markdownDocument: md.Document(encodeHtml: false),
            ).convert(widget.initialValue!),
          )
        : Document();
  }

  @override
  void dispose() {
    _controller.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 40.0,
          leading: FormCloseButton(canPop: () => !hasChanged()),
          actions: [
            IconButton(
              onPressed: save,
              icon: const Icon(Symbols.check_rounded),
              tooltip: "general.save".t(context),
            ),
          ],
          centerTitle: true,
          backgroundColor: context.colorScheme.surface,
        ),
        body: SafeArea(
          child: Column(
            children: [
              QuillSimpleToolbar(
                controller: _controller,
                config: _defaultQuillToolbarConfig,
              ),
              Expanded(
                child: Frame.standalone(
                  child: QuillEditor(
                    focusNode: _editorFocusNode,
                    scrollController: _editorScrollController,
                    controller: _controller,
                    config: QuillEditorConfig(
                      enableScribble: true,
                      customStyles: context.quillDefaultStyles,
                      placeholder: "transaction.description.placeholder".t(
                        context,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> save() async {
    final markdown = DeltaToMarkdown().convert(_controller.document.toDelta());
    context.pop<String>(markdown);
  }

  bool hasChanged() {
    try {
      final String currentMarkdown = DeltaToMarkdown()
          .convert(_controller.document.toDelta())
          .trim();

      if ((widget.initialValue?.trim() ?? "").isEmpty &&
          currentMarkdown.isEmpty) {
        return false;
      }

      final String initialMarkdown = DeltaToMarkdown()
          .convert(
            MarkdownToDelta(
              markdownDocument: md.Document(encodeHtml: false),
            ).convert(widget.initialValue?.trim() ?? ""),
          )
          .trim();

      return currentMarkdown != initialMarkdown;
    } catch (e) {
      return false;
    }
  }
}

const QuillSimpleToolbarConfig _defaultQuillToolbarConfig =
    QuillSimpleToolbarConfig(
      multiRowsDisplay: true,
      showDividers: true,
      showFontFamily: false,
      showFontSize: false,
      showBoldButton: true,
      showItalicButton: true,
      showSmallButton: false,
      showUnderLineButton: true,
      showLineHeightButton: false,
      showStrikeThrough: true,
      showInlineCode: true,
      showColorButton: false,
      showBackgroundColorButton: false,
      showClearFormat: true,
      showAlignmentButtons: false,
      showLeftAlignment: false,
      showCenterAlignment: false,
      showRightAlignment: false,
      showJustifyAlignment: false,
      showHeaderStyle: true,
      showListNumbers: true,
      showListBullets: true,
      showListCheck: true,
      showCodeBlock: true,
      showQuote: true,
      showIndent: false,
      showLink: true,
      showUndo: true,
      showRedo: true,
      showDirection: false,
      showSearchButton: true,
      showSubscript: false,
      showSuperscript: false,
      showClipboardCut: false,
      showClipboardCopy: false,
      showClipboardPaste: false,
      linkStyleType: LinkStyleType.original,
      headerStyleType: HeaderStyleType.original,
    );
