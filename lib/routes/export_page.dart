import "package:flow/entity/backup_entry.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/sync/export.dart";
import "package:flow/sync/export/mode.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/export/export_success.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

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

  double progress = 0.0;

  @override
  void initState() {
    super.initState();

    runExport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("sync.export".t(context, widget.mode.name))),
      body: SafeArea(child: buildChild(context)),
    );
  }

  Widget buildChild(BuildContext context) {
    if (!done) {
      return const Spinner.center();
    }

    if (filePath == null) {
      return Center(
        child: Text(error?.toString() ?? "error.sync.exportFailed".t(context)),
      );
    }

    return ExportSuccess(
      mode: widget.mode,
      shareFn: showShareSheet,
      filePath: filePath!,
    );
  }

  Future<void> runExport() async {
    try {
      final result = await export(
        mode: widget.mode,
        showShareDialog: false,
        type: BackupEntryType.manual,
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

  Future<void> showShareSheet(RenderObject? renderObject) async {
    final RenderBox? renderBox =
        renderObject is RenderBox ? renderObject : null;

    await context.showShareSheet(
      subject: "sync.export.save.shareTitle".t(context, {
        "type": widget.mode.name,
        "date": Moment.now().lll,
      }),
      filePath: filePath!,
      renderBox: renderBox,
    );
  }
}
