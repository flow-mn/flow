import "dart:io";

import "package:flow/main.dart" show mainLogAppender;
import "package:flow/utils/extensions/custom_popups.dart";
import "package:flow/utils/extensions/num.dart";
import "package:flutter/material.dart";
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
    files = mainLogAppender?.getAllLogFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Debug logs")),
      body: SingleChildScrollView(
        child:
            files?.isNotEmpty == true
                ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      files!
                          .map(
                            (file) => ListTile(
                              title: Text(path.basename(file.path)),
                              subtitle: Text(
                                [
                                  file
                                      .lastModifiedSync()
                                      .toLocal()
                                      .toMoment()
                                      .llll,
                                  file.statSync().size.humanReadableBinarySize,
                                ].join(" • "),
                              ),
                              onLongPress:
                                  () => context.push(
                                    "/_debug/logs/view",
                                    extra: file.path,
                                  ),
                              trailing: Builder(
                                builder: (context) {
                                  return IconButton(
                                    onPressed:
                                        () => showShareSheet(
                                          file.path,
                                          context.findRenderObject(),
                                        ),
                                    icon: Icon(Symbols.share_rounded),
                                  );
                                },
                              ),
                            ),
                          )
                          .toList(),
                )
                : Center(child: Text("No log files found")),
      ),
    );
  }

  Future<void> showShareSheet(String path, RenderObject? renderObject) async {
    await context.showFileShareSheet(
      subject: "Share log files",
      filePath: path,
    );
  }
}
