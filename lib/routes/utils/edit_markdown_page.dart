import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/form_close_button.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:super_editor/super_editor.dart";
import "package:super_editor_markdown/super_editor_markdown.dart";

class EditMarkdownPageProps {
  final String? initialValue;
  final int? maxLength;

  const EditMarkdownPageProps({
    this.initialValue,
    this.maxLength,
  });
}

class EditMarkdownPage extends StatefulWidget {
  final String? initialValue;
  final int? maxLength;

  const EditMarkdownPage({super.key, this.initialValue, this.maxLength});

  @override
  State<EditMarkdownPage> createState() => _EditMarkdownPageState();
}

class _EditMarkdownPageState extends State<EditMarkdownPage>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();

  late final Editor _editor;
  late final MutableDocument _document;
  late final MutableDocumentComposer _composer;

  bool focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
    focused = _focusNode.hasFocus;

    _document = deserializeMarkdownToDocument(
      widget.initialValue ?? "",
      syntax: MarkdownSyntax.superEditor,
    );

    _composer = MutableDocumentComposer();

    _editor = createDefaultDocumentEditor(
      document: _document,
      composer: _composer,
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40.0,
        leading: FormCloseButton(
          canPop: () => !hasChanged(),
        ),
        actions: [
          IconButton(
            onPressed: () => save(),
            icon: const Icon(Symbols.check_rounded),
            tooltip: "general.save".t(context),
          )
        ],
        centerTitle: true,
        backgroundColor: context.colorScheme.surface,
      ),
      resizeToAvoidBottomInset: false,
      body: Frame.standalone(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: context.colorScheme.secondary,
          ),
          child: SuperEditor(
            editor: _editor,
            focusNode: _focusNode,
            stylesheet: context.superEditorTheme.stylesheet,
            selectionStyle: context.superEditorTheme.selectionStyles,
          ),
        ),
      ),
      // body: SingleChildScrollView(
      //           padding: EdgeInsets.all(16.0),
      //           child: TextFormField(
      //             decoration: InputDecoration(
      //               hintText: "transaction.description".t(context),
      //               border: OutlineInputBorder(),
      //               counter: counterOverride,
      //             ),
      //             focusNode: _focusNode,
      //             keyboardType: TextInputType.multiline,
      //             maxLines: null,
      //             maxLength: widget.maxLength,
      //             maxLengthEnforcement: MaxLengthEnforcement.enforced,
      //             minLines: 10,
      //             controller: _controller,
      //             autofocus: true,
      //             textInputAction: TextInputAction.newline,
      //           ),
      //         ),
    );
  }

  void save() async {
    context.pop(serializeDocumentToMarkdown(_editor.document));
  }

  bool hasChanged() {
    return serializeDocumentToMarkdown(_editor.document) != widget.initialValue;
  }

  _handleFocusChange() {
    setState(() {
      focused = _focusNode.hasFocus;
    });
  }
}
