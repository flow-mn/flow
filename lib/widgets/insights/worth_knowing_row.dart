import "package:flow/theme/theme.dart";
import "package:flow/widgets/insights/insight_icon_badge.dart";
import "package:flow/widgets/insights/insight_summary.dart";
import "package:flow/widgets/stats/emphasized_text.dart";
import "package:flow/widgets/stats/wrapped/mini_bars.dart";
import "package:flutter/material.dart";

/// One insight in the Worth knowing card: a sentence, a line of context, and
/// a tiny history when there is one.
class WorthKnowingRow extends StatelessWidget {
  final InsightSummary summary;
  final VoidCallback onTap;

  /// Shown under the text, e.g. "Track as recurring".
  final Widget? action;

  const WorthKnowingRow({
    super.key,
    required this.summary,
    required this.onTap,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final List<double>? spark = summary.spark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: .start,
          children: [
            InsightIconBadge(icon: summary.icon),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  DefaultTextStyle.merge(
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                    child: EmphasizedText(
                      template: summary.template,
                      value: summary.value,
                      valueStyle: TextStyle(
                        color: summary.valueColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    summary.detail,
                    style: context.textTheme.labelMedium?.semi(context),
                  ),
                  if (action != null) ...[const SizedBox(height: 8.0), action!],
                ],
              ),
            ),
            if (spark != null && spark.length > 1) ...[
              const SizedBox(width: 12.0),
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: SizedBox(
                  width: 44.0,
                  child: ExcludeSemantics(
                    child: MiniBars(
                      values: spark,
                      highlightColor: context.colorScheme.primary,
                      height: 28.0,
                      spacing: 2.0,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
