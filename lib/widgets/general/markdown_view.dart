import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions/toast.dart";
import "package:flow/utils/open_url.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flutter/material.dart";
import "package:flutter_markdown/flutter_markdown.dart";
import "package:logging/logging.dart";

final Logger _log = Logger("MarkdownView");

class MarkdownView extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;

  final Function(String)? onChanged;

  final bool allowTogglingCheckboxes;

  const MarkdownView({
    super.key,
    required this.controller,
    this.focusNode,
    this.onChanged,
    this.allowTogglingCheckboxes = false,
  });

  @override
  Widget build(BuildContext context) {
    int checkboxCounter = 0;

    return Frame(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: context.colorScheme.secondary,
        ),
        child: Markdown(
          data: controller.text,
          selectable: false,
          shrinkWrap: true,
          styleSheet: getStyleSheet(context),
          checkboxBuilder: (value) {
            final int index = checkboxCounter++;

            return Checkbox /*.adaptive*/ (
              value: value,
              onChanged:
                  (newValue) => {tryFlipCheckbox(index, newValue ?? !value)},
            );
          },
          onTapLink:
              (text, href, title) => onTapLink(context, text, href, title),
        ),
      ),
    );
  }

  void tryFlipCheckbox(int index, bool value) {
    if (!allowTogglingCheckboxes) {
      _log.warning("Cannot flip checkbox when toggling is disabled");
      return;
    }

    if (controller.text.contains("```")) {
      _log.warning("Cannot flip checkbox when markdown contains a code block");
      return;
    }

    _log.info("Flipping checkbox at [$index] to $value");

    try {
      final RegExpMatch match = RegExp(
        r"-\s\[(\s|x)\]",
        multiLine: true,
      ).allMatches(controller.text).elementAt(index);

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
      _log.warning("Failed to flip checkbox at [$index]", e);
    }
  }

  void onTapLink(
    BuildContext context,
    String text,
    String? href,
    String title,
  ) {
    _log.warning("Tapped link: $text, $href, $title");

    if (href == null) {
      context.showErrorToast(error: "error.url.cannotOpen".t(context));
      return;
    }

    final Uri? parsed = Uri.tryParse(href);
    if (parsed == null) {
      context.showErrorToast(error: "error.url.cannotOpen".t(context));
      return;
    }

    openUrl(parsed).then((succeeded) {
      if (!succeeded && context.mounted) {
        context.showErrorToast(error: "error.url.cannotOpen".t(context));
      }
    });
  }

  MarkdownStyleSheet getStyleSheet(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle p = textTheme.bodyLarge!;

    return MarkdownStyleSheet(
      h1: textTheme.headlineLarge!.copyWith(
        fontSize: textTheme.headlineLarge!.fontSize! * 1.4,
      ),
      h2: textTheme.headlineLarge!.copyWith(
        fontSize: textTheme.headlineLarge!.fontSize! * 1.28,
      ),
      h3: textTheme.headlineLarge!.copyWith(
        fontSize: textTheme.headlineLarge!.fontSize! * 1.14,
      ),
      h4: textTheme.headlineLarge,
      h5: textTheme.headlineMedium,
      h6: textTheme.headlineSmall,
      p: p,
      a: p.copyWith(color: context.colorScheme.primary),
      strong: p.copyWith(fontWeight: FontWeight.bold),
      em: p.copyWith(fontStyle: FontStyle.italic),
      code: p.copyWith(fontFamily: "monospace"),
      img: p.copyWith(fontStyle: FontStyle.italic),
      checkbox: p.copyWith(fontFamily: "monospace"),
      del: p.copyWith(decoration: TextDecoration.lineThrough),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: context.colorScheme.onSurface.withAlpha(0x80),
            width: 4.0,
          ),
        ),
      ),
      blockquotePadding: const EdgeInsets.only(left: 24.0),
      codeblockDecoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}
