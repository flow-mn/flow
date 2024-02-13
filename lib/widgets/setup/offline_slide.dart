import 'package:flow/data/flow_icon.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/general/flow_icon.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class OfflineSlide extends StatelessWidget {
  const OfflineSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Center(
            child: FlowIcon(
              FlowIconData.icon(Symbols.security_rounded),
              size: 160.0,
              plated: true,
            ),
          ),
          const Spacer(),
          Text(
            "setup.slides.offline".t(context),
            style: context.textTheme.displayMedium?.copyWith(
              color: context.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            "setup.slides.offline.description".t(context),
            style: context.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
