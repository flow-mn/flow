import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class ICloudFailedErrorBox extends StatefulWidget {
  const ICloudFailedErrorBox({super.key});

  @override
  State<ICloudFailedErrorBox> createState() => _ICloudFailedErrorBoxState();
}

class _ICloudFailedErrorBoxState extends State<ICloudFailedErrorBox> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: openSettings,
      child: Frame.standalone(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Symbols.error_circle_rounded,
              fill: 0,
              color: context.colorScheme.error,
              size: 24.0,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: DefaultTextStyle(
                style: context.textTheme.bodyMedium!
                    .semi(context)
                    .copyWith(color: context.colorScheme.error),
                child: Text(
                  "preferences.sync.iCloud.lastSyncFailed".t(context),
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            Icon(
              Symbols.open_in_new,
              fill: 0,
              size: 24.0,
              color: context.colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }

  void openSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ModalSheet.scrollable(
        title: Text("preferences.sync.iCloud.connectionFailed".t(context)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16.0,
            children: [
              ...List.generate(3, (index) {
                final int no = index + 1;

                return Frame(
                  child: Text(
                    "$no. ${"preferences.sync.iCloud.connectionFailed.tips#$no".t(context)}",
                  ),
                );
              }),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
