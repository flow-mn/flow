import "package:flow/data/flow_icon.dart";
import "package:flow/data/money.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";

class TransactionsInfo extends StatelessWidget {
  final int? count;
  final Money flow;

  final FlowIconData icon;

  const TransactionsInfo({
    super.key,
    required this.count,
    required this.flow,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Surface(builder: (context) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 4.0),
          FlowIcon(icon, size: 48.0, plated: true),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    flow.formatted,
                    style: context.textTheme.displaySmall,
                  ),
                  Text(
                    "transactions.count".t(context, count ?? 0),
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
