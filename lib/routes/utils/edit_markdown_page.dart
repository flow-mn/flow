import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/form_close_button.dart";
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

class _EditMarkdownPageState extends State<EditMarkdownPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
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
        centerTitle: true,
        backgroundColor: context.colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: TextFormField(
          decoration: InputDecoration(
            hintText: "transaction.description".t(context),
            border: OutlineInputBorder(),
            counter: counterOverride,
          ),
          keyboardType: TextInputType.multiline,
          maxLines: null,
          maxLength: widget.maxLength,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.newline,
        ),
      ),
    );
  }

  void save() async {
    context.pop(_controller.text);
  }

  bool hasChanged() {
    return _controller.text != widget.initialValue;
  }
}
