import "package:flow/data/flow_icon.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/widgets.dart";

class ImportItemListTile extends StatelessWidget {
  final FlowIconData icon;
  final Widget label;

  const ImportItemListTile({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Surface(
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            FlowIcon(icon, size: 24.0),
            const SizedBox(width: 8.0),
            Flexible(child: label),
            const SizedBox(width: 8.0),
          ],
        ),
      ),
    );
  }
}
