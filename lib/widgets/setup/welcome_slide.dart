import 'package:flow/l10n/extensions.dart';
import 'package:flow/theme/theme.dart';
import 'package:flutter/material.dart';

class WelcomeSlide extends StatelessWidget {
  const WelcomeSlide({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    late final String logoPath;

    if (width <= 256) {
      logoPath = "assets/images/flow@256.png";
    } else if (width <= 512) {
      logoPath = "assets/images/flow@512.png";
    } else {
      logoPath = "assets/images/flow@1024.png";
    }

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
              child: Image.asset(logoPath),
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
