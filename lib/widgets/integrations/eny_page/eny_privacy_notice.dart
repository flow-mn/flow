import "package:flow/constants.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/animated_eny_logo.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class EnyPrivacyNotice extends StatelessWidget {
  const EnyPrivacyNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        const Center(
          child: Padding(
            padding: .all(24.0),
            child: SizedBox(
              width: 96.0,
              height: 96.0,
              child: AnimatedEnyLogo(),
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        ListHeader("integrations.eny.privacyNotice".t(context)),
        const SizedBox(height: 8.0),
        Frame(
          child: Text(
            "integrations.eny.privacyNotice.description".t(context),
            style: context.textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 16.0),
        Frame(
          child: RichText(
            text: TextSpan(
              style: context.textTheme.bodyMedium?.copyWith(height: 1.8),
              children: [
                TextSpan(
                  text: "integrations.eny.privacyNotice.dataSharing".t(context),
                ),
                TextSpan(text: "\n"),
                TextSpan(
                  style: context.textTheme.bodyMedium?.copyWith(
                    height: 1.8,
                    color: context.colorScheme.primary,
                  ),
                  children: [
                    TextSpan(
                      text:
                          "\u2022 ${"integrations.eny.privacyNotice.dataSharing#eny".t(context)}",
                    ),
                    WidgetSpan(child: const SizedBox(width: 4.0)),
                    WidgetSpan(
                      child: Icon(
                        Symbols.arrow_outward_rounded,
                        size: 16.0,
                        color: context.colorScheme.primary,
                      ),
                    ),
                    TextSpan(text: "\n"),
                  ],
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // Open Eny website
                      openUrl(enyHomeLink);
                    },
                ),
                TextSpan(
                  style: context.textTheme.bodyMedium?.copyWith(height: 1.8),
                  text:
                      "\u2022 ${"integrations.eny.privacyNotice.dataSharing#google".t(context)}\n",
                ),
                TextSpan(
                  text:
                      "\n${"integrations.eny.privacyNotice.legal".t(context)}",
                  style: TextStyle(
                    fontSize: 9.0,
                    color: context.flowColors.semi,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
