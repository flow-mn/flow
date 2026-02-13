import "package:flow/l10n/extensions.dart";
import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";

class ImportedFromSiri extends StatelessWidget {
  const ImportedFromSiri({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: context.textTheme.bodyMedium?.semi(context),
        children: [
          WidgetSpan(
            child: SizedBox.square(
              dimension: 16.0,
              child: Image.asset("assets/images/siri.png"),
            ),
            alignment: .middle,
          ),
          TextSpan(text: " "),
          TextSpan(text: "transaction.external.from".t(context, "Siri")),
        ],
      ),
    );
  }
}
