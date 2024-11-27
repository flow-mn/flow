import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/form_close_button.dart";
import "package:flow/widgets/general/markdown_view.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

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
  late final TextEditingController _controller;
  late final TabController _tabController;
  final FocusNode _focusNode = FocusNode();

  bool focused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _tabController = TabController(length: 2, vsync: this);
    _focusNode.addListener(_handleFocusChange);
    focused = _focusNode.hasFocus;
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    _focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget? counterOverride = (widget.maxLength != null &&
            _controller.text.length < (widget.maxLength! * 0.9))
        ? SizedBox.shrink()
        : null;

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
        bottom: TabBar(
          tabs: [
            Tab(text: "general.edit".t(context)),
            Tab(text: "transaction.description.preview".t(context)),
          ],
          controller: _tabController,
        ),
        centerTitle: true,
        backgroundColor: context.colorScheme.surface,
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "transaction.description".t(context),
                    border: OutlineInputBorder(),
                    counter: counterOverride,
                  ),
                  focusNode: _focusNode,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  maxLength: widget.maxLength,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  minLines: 10,
                  controller: _controller,
                  autofocus: true,
                  textInputAction: TextInputAction.newline,
                ),
              ),
              SingleChildScrollView(
                padding: EdgeInsets.only(top: 16.0),
                child: MarkdownView(
                  controller: _controller,
                ),
              )
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).viewInsets.bottom,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _bold,
                    icon: Icon(Symbols.format_bold_rounded),
                  ),
                  IconButton(
                    onPressed: _italic,
                    icon: Icon(Symbols.format_italic_rounded),
                  ),
                  IconButton(
                    onPressed: _checklist,
                    icon: Icon(Symbols.checklist_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void save() async {
    context.pop(_controller.text);
  }

  bool hasChanged() {
    return _controller.text != widget.initialValue;
  }

  _bold() {
    if (_controller.selection.isCollapsed) {
      _insert("****", -2);
    } else {
      _alterUncollapsed("**", "**");
    }
  }

  _italic() {
    if (_controller.selection.isCollapsed) {
      _insert("**", -1);
    } else {
      _alterUncollapsed("*", "*");
    }
  }

  _checklist() {
    if (_controller.selection.isCollapsed) {
      _insertChecklist();
    } else {
      _alterUncollapsed("\n- [ ] ", "\n");
    }
  }

  _alterUncollapsed(String prefix, String postfix, [int cursorOffset = 0]) {
    try {
      final TextSelection selection = _controller.selection;
      final String text = _controller.text;

      if (!selection.isValid) return;

      // TODO bold the whole line if selection is collapsed
      if (selection.isCollapsed) return;

      _controller.value = TextEditingValue(
        text:
            "${selection.textBefore(text)}$prefix${selection.textInside(text)}$postfix${selection.textAfter(text)}",
        selection: TextSelection.collapsed(
          offset: selection.end + prefix.length + postfix.length + cursorOffset,
          affinity: selection.affinity,
        ),
      );
    } finally {
      _focusNode.requestFocus();
    }
  }

  _insertChecklist() {
    try {
      final TextSelection selection = _controller.selection;
      final String text = _controller.text;

      if (!selection.isValid) return;

      final bool currentlyAtBegginingOfLine =
          selection.start == 0 || text[selection.start - 1] == "\n";

      final String payload =
          currentlyAtBegginingOfLine ? "- [ ] \n" : "\n- [ ] \n";
      final int cursorOffset = -1;

      _controller.value = TextEditingValue(
        text:
            "${selection.textBefore(text)}$payload${selection.textAfter(text)}",
        selection: TextSelection.collapsed(
          offset: selection.end + payload.length + cursorOffset,
          affinity: selection.affinity,
        ),
      );
    } finally {
      _focusNode.requestFocus();
    }
  }

  _insert(String payload, [int cursorOffset = 0]) {
    try {
      final TextSelection selection = _controller.selection;
      final String text = _controller.text;

      if (!selection.isValid) return;

      _controller.value = TextEditingValue(
        text:
            "${selection.textBefore(text)}$payload${selection.textAfter(text)}",
        selection: TextSelection.collapsed(
          offset: selection.end + payload.length + cursorOffset,
          affinity: selection.affinity,
        ),
      );
    } finally {
      _focusNode.requestFocus();
    }
  }

  _handleFocusChange() {
    setState(() {
      focused = _focusNode.hasFocus;
    });
  }
}
