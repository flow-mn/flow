import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/cupertino.dart";

class InfoCard extends StatelessWidget {
  final String title;
  final String value;

  final bool large;

  const InfoCard(
      {super.key,
      required this.title,
      required this.value,
      this.large = false});

  @override
  Widget build(BuildContext context) {
    return Surface(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      builder: (BuildContext context) => Container(
        width: double.infinity,
        padding: large
            ? const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 24.0,
              )
            : const EdgeInsets.symmetric(
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
            Flexible(
              child: Text(
                value,
                style: context.textTheme.displaySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
