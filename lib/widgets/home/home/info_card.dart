import "package:auto_size_text/auto_size_text.dart";
import "package:flow/data/money.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/cupertino.dart";

class InfoCard extends StatelessWidget {
  final String title;

  final Money? money;

  final Widget? trailing;

  final AutoSizeGroup? autoSizeGroup;

  const InfoCard({
    super.key,
    required this.title,
    required this.money,
    this.trailing,
    this.autoSizeGroup,
  });

  @override
  Widget build(BuildContext context) {
    return Surface(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      builder: (BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: context.textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                Flexible(
                  child: MoneyText(
                    money,
                    style: context.textTheme.displaySmall,
                    autoSizeGroup: autoSizeGroup,
                    autoSize: true,
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8.0),
                  trailing!,
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
