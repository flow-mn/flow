import 'package:flow/data/flow_icon.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/button.dart';
import 'package:flow/widgets/general/flow_icon.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class ImportSuccess extends StatelessWidget {
  const ImportSuccess({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Spacer(),
          FlowIcon(
            FlowIconData.icon(Symbols.check_circle_outline_rounded),
            size: 80.0,
            color: context.flowColors.income,
          ),
          const SizedBox(height: 16.0),
          Text(
            "sync.import.success".t(context),
            style: context.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          const SizedBox(height: 16.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Symbols.info_rounded,
                fill: 0,
                color: context.flowColors.semi,
                size: 16.0,
              ),
              const SizedBox(width: 8.0),
              Flexible(
                child: Text(
                  "sync.import.emergencyBackup.successful".t(context),
                  style: context.textTheme.bodySmall?.semi(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          Button(
            onTap: () => context.pop(),
            leading: const Icon(Symbols.check_rounded),
            child: Text(
              "general.done".t(context),
            ),
          )
        ],
      ),
    );
  }
}
