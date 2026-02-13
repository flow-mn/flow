import "package:flow/constants.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/animated_eny_logo.dart";
import "package:flutter/material.dart";

class ImportedFromEny extends StatelessWidget {
  const ImportedFromEny({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        openUrl(enyHomeLink);
      },
      child: RichText(
        text: TextSpan(
          style: context.textTheme.bodyMedium?.semi(context),
          children: [
            WidgetSpan(
              child: SizedBox.square(
                dimension: 16.0,
                child: AnimatedEnyLogo(noAnimation: true),
              ),
              alignment: .middle,
            ),
            TextSpan(text: " "),
            TextSpan(text: "transaction.external.added.from".t(context, "Eny")),
          ],
        ),
      ),
    );
  }
}
