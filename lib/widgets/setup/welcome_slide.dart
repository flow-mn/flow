import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";

class WelcomeSlide extends StatelessWidget {
  const WelcomeSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            const Spacer(),
            Center(
              child: ClipRRect(
                borderRadius: .circular(24.0),
                child: Image.asset(
                  "assets/images/flow.png",
                  width: 176.0,
                  height: 176.0,
                ),
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
            Text("appShortDesc".t(context), style: context.textTheme.bodyLarge),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
