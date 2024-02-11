import 'dart:io';

import 'package:flow/l10n/extensions.dart';
import 'package:flow/sync/export.dart';
import 'package:flow/sync/export/mode.dart';
import 'package:flow/widgets/export/export_success.dart';
import 'package:flow/widgets/general/spinner.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ExportPage extends StatefulWidget {
  final ExportMode mode;

  const ExportPage(this.mode, {super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  String? filePath;

  dynamic error;
  bool done = false;

  @override
  void initState() {
    super.initState();

    runExport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("sync.export".t(context, widget.mode.name)),
      ),
      body: SafeArea(
        child: buildChild(context),
      ),
    );
  }

  Widget buildChild(BuildContext context) {
    return switch ((done, filePath)) {
      (true, String()) => ExportSuccess(
          mode: widget.mode,
          shareFn: () => showShareSheet(),
          filePath: filePath!,
        ),
      (false, _) => const Spinner.center(),
      (true, null) => Center(
          child: Text(
            error?.toString() ?? "error.sync.exportFailed".t(context),
          ),
        )
    };
  }

  Future<void> runExport() async {
    try {
      final result = await export(
        mode: widget.mode,
        showShareDialog: false,
      );

      filePath = result.filePath;
    } catch (e) {
      error = e;
    } finally {
      if (mounted) {
        setState(() {
          done = true;
        });
      }
    }
  }

  Future<void> showShareSheet() async {
    if (Platform.isLinux) {
      // openUrl(Uri.parse("file://$filePath"));
      Process.runSync("xdg-open", [File(filePath!).parent.path]);
      return;
    }

    final box = context.findRenderObject() as RenderBox?;

    final origin =
        box == null ? Rect.zero : box.localToGlobal(Offset.zero) & box.size;

    await Share.shareXFiles([XFile(filePath!)],
        sharePositionOrigin: origin,
        subject: "sync.export.share".t(context, widget.mode.name));
  }
}
