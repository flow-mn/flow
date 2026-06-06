import "dart:developer";

import "package:flow/services/sync/icloud_syncer.dart";
import "package:flow/services/sync/syncer.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/directional_slidable.dart";
import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:share_plus/share_plus.dart";

class DebugICloudPage extends StatefulWidget {
  const DebugICloudPage({super.key});

  @override
  State<DebugICloudPage> createState() => _DebugICloudPageState();
}

class _DebugICloudPageState extends State<DebugICloudPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("iCloud debug")),
      body: ValueListenableBuilder(
        valueListenable: ICloudSyncer().filesCache,
        builder: (context, value, child) {
          if (!ICloudSyncer.supported) {
            return Center(
              child: Text("iCloud is not supported on this device."),
            );
          }

          if (value.isEmpty) {
            return Center(
              child: Text("No iCloud files found. Try uploading some"),
            );
          }

          return SlidableAutoCloseBehavior(
            child: ListView.builder(
              itemCount: value.length,
              itemBuilder: (context, index) {
                final iCloudFile = value[index];

                return DirectionalSlidable(
                  endActions: [
                    SlidableAction(
                      icon: Symbols.delete_forever_rounded,
                      backgroundColor: context.flowColors.expense,
                      onPressed: (context) =>
                          ICloudSyncer().debugDelete(iCloudFile.relativePath),
                    ),
                  ],
                  startActions: [
                    SlidableAction(
                      icon: Symbols.cloud_download_rounded,
                      backgroundColor: context.flowColors.income,
                      onPressed: (context) => ICloudSyncer()
                          .download(
                            SyncerItem(
                              path: iCloudFile.relativePath,
                              updatedAt: iCloudFile.contentChangeDate,
                            ),
                          )
                          .then((file) {
                            log(
                              "file @ ${file?.path} (${file?.statSync().size})",
                            );
                            if (file != null) {
                              SharePlus.instance.share(
                                ShareParams(files: [XFile(file.path)]),
                              );
                            }
                          }),
                    ),
                  ],
                  child: ListTile(
                    title: Text(iCloudFile.relativePath),
                    subtitle: Text(iCloudFile.contentChangeDate.toString()),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
