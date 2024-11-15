import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/cupertino.dart";

class InfoCard extends StatelessWidget {
  final String title;

  final Widget? moneyText;

  final Widget? trailing;

  const InfoCard({
    super.key,
    required this.title,
    this.trailing,
    this.moneyText,
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
            if (moneyText != null)
              Row(
                children: [
                  moneyText!,
                  if (trailing != null) ...[
                    const SizedBox(width: 8.0),
                    Flexible(child: trailing!),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
