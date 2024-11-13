import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";

class WelcomeSlide extends StatelessWidget {
  const WelcomeSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: Image.asset("assets/images/flow.png"),
            ),
          ),
          const Spacer(),
          Text(
            "appName".t(context),
            style: context.textTheme.displayMedium?.copyWith(
              color: context.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            "appShortDesc".t(context),
            style: context.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
