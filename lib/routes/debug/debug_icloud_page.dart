import "package:flow/services/icloud_sync.dart";
import "package:flutter/material.dart";

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
        valueListenable: ICloudSyncService().filesCache,
        builder: (context, value, child) {
          if (!ICloudSyncService.supported) {
            return Center(
              child: Text("iCloud is not supported on this device."),
            );
          }

          if (value.isEmpty) {
            return Center(
              child: Text("No iCloud files found. Try uploading some"),
            );
          }

          return ListView.builder(
            itemCount: value.length,
            itemBuilder: (context, index) {
              final iCloudFile = value[index];

              return ListTile(
                title: Text(iCloudFile.relativePath),
                subtitle: Text(iCloudFile.contentChangeDate.toString()),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await ICloudSyncService().delete(iCloudFile);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
