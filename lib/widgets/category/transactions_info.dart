import "package:flow/data/flow_icon.dart";
import "package:flow/data/money.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/money_text_builder.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";

class TransactionsInfo extends StatelessWidget {
  final int? count;
  final Money flow;

  /// When set, becomes the headline, and [flow] moves to the subtitle
  final Money? balance;

  final FlowIconData icon;
  final FlowColorScheme? colorScheme;

  const TransactionsInfo({
    super.key,
    required this.count,
    required this.flow,
    required this.icon,
    this.balance,
    this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Surface(
      builder: (context) {
        var align = Align(
          alignment: AlignmentDirectional.centerStart,
          child: Column(
            crossAxisAlignment: .start,
            children: [
              if (balance case Money balance) ...[
                MoneyText(
                  balance,
                  style: context.textTheme.displaySmall,
                  autoSize: true,
                ),
                MoneyTextBuilder(
                  money: flow,
                  builder: (context, formattedFlow, _) => Text(
                    "$formattedFlow • ${"transactions.count".t(context, count ?? 0)}",
                    style: context.textTheme.bodySmall,
                  ),
                ),
              ] else ...[
                Text(flow.formatted, style: context.textTheme.displaySmall),
                Text(
                  "transactions.count".t(context, count ?? 0),
                  style: context.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        );
        return Row(
          children: [
            FlowIcon(icon, size: 48.0, plated: true, colorScheme: colorScheme),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  12.0,
                  4.0,
                  16.0,
                  4.0,
                ),
                child: align,
              ),
            ),
          ],
        );
      },
    );
  }
}
