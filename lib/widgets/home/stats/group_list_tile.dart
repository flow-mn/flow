import "package:flow/data/chart_data.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions/chart_data.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flutter/material.dart";

class GroupListTile extends StatelessWidget {
  final ChartData chartData;
  final double percent;

  /// Bar length, relative to the largest group (0.0 to 1.0)
  final double barFactor;
  final Color color;

  final VoidCallback? onTap;

  const GroupListTile({
    super.key,
    required this.chartData,
    required this.percent,
    required this.barFactor,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final FlowColorScheme? colorScheme = chartData.colorScheme;

    return MergeSemantics(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            spacing: 12.0,
            children: [
              FlowIcon(
                chartData.icon,
                plated: true,
                color: colorScheme?.primary,
                plateColor: colorScheme?.secondary,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: .min,
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      chartData.resolveName(context),
                      style: context.textTheme.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6.0),
                    ClipRRect(
                      borderRadius: .all(Radius.circular(3.0)),
                      child: LinearProgressIndicator(
                        value: barFactor.clamp(0.01, 1.0),
                        minHeight: 5.0,
                        backgroundColor: context.colorScheme.onSurface
                            .withAlpha(0x1a),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: .min,
                crossAxisAlignment: .end,
                children: [
                  MoneyText(
                    chartData.money,
                    displayAbsoluteAmount: true,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    percent < 0.1 ? "<0.1%" : "${percent.toStringAsFixed(1)}%",
                    style: context.textTheme.bodySmall?.semi(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
