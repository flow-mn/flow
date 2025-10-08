import "dart:io";

import "package:flow/l10n/extensions.dart";
import "package:flow/main.dart" show mainLogAppender;
import "package:flow/theme/helpers.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/directional_slidable.dart";
import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";
import "package:path/path.dart" as path;

class DebugLogsPage extends StatefulWidget {
  const DebugLogsPage({super.key});

  @override
  State<DebugLogsPage> createState() => _DebugLogsPageState();
}

class _DebugLogsPageState extends State<DebugLogsPage> {
  bool appenderAvailable = false;

  List<File>? files;

  @override
  void initState() {
    super.initState();
    appenderAvailable = mainLogAppender != null;
    files = List<File>.from(mainLogAppender?.getAllLogFiles() ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Debug logs")),
      body: SingleChildScrollView(
        child: files?.isNotEmpty == true
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: files!
                    .map(
                      (file) => DirectionalSlidable(
                        endActions: [
                          SlidableAction(
                            onPressed: (context) =>
                                showDeleteConfirmation(file),
                            icon: Symbols.delete_forever_rounded,
                            backgroundColor: context.flowColors.expense,
                          ),
                        ],
                        child: ListTile(
                          title: Text(path.basename(file.path)),
                          subtitle: Text(
                            [
                              file.lastModifiedSync().toLocal().toMoment().llll,
                              file.statSync().size.humanReadableBinarySize,
                            ].join(" • "),
                          ),
                          onLongPress: () => context.push(
                            "/_debug/logs/view",
                            extra: file.path,
                          ),
                          trailing: Builder(
                            builder: (context) {
                              return IconButton(
                                onPressed: () => showShareSheet(
                                  file.path,
                                  context.findRenderObject(),
                                ),
                                icon: Icon(Symbols.share_rounded),
                              );
                            },
                          ),
                        ),
                      ),
                    )
                    .toList(),
              )
            : Center(child: Text("No log files found")),
      ),
    );
  }

  Future<void> showDeleteConfirmation(File file) async {
    final confirmed = await context.showConfirmationSheet(
      title: "logs.delete".t(context),
      isDeletionConfirmation: true,
      child: Text("logs.delete.confirmation".t(context)),
    );

    if (confirmed == true) {
      await file.delete();

      files?.remove(file);

      if (mounted) {
        context.showToast(text: "logs.deleted".t(context));

        setState(() {});
      }
    }
  }

  Future<void> showShareSheet(String path, RenderObject? renderObject) async {
    await context.showFileShareSheet(
      subject: "Share log files",
      filePath: path,
    );
  }
}
