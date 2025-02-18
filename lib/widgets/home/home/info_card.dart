import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/cupertino.dart";

class InfoCard extends StatelessWidget {
  final String title;

  final Widget? moneyText;
  final Widget? delta;

  final Widget? icon;

  const InfoCard({
    super.key,
    required this.title,
    this.icon,
    this.moneyText,
    this.delta,
  });

  @override
  Widget build(BuildContext context) {
    return Surface(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      builder:
          (BuildContext context) => Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: context.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (icon != null) ...[
                      const SizedBox(width: 4.0),
                      IconTheme(data: IconThemeData(size: 20.0), child: icon!),
                    ],
                  ],
                ),
                if (moneyText != null) moneyText!,
                if (delta != null) delta!,
              ],
            ),
          ),
    );
  }
}
