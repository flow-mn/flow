import "dart:io";

import "package:path/path.dart" as path;
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:material_symbols_icons/symbols.dart";

class DebugLogPage extends StatefulWidget {
  final String? path;

  const DebugLogPage({super.key, required this.path});

  @override
  State<DebugLogPage> createState() => _DebugLogPageState();
}

class _DebugLogPageState extends State<DebugLogPage> {
  late final Future<String> contents;
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();

    final File file = File(widget.path ?? "~");

    contents = file.readAsString();
    _controller = ScrollController(
      onAttach: (_) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          try {
            _controller.jumpTo(_controller.position.maxScrollExtent);
          } catch (e) {
            // Silent fail
          }
        });
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(path.basename(widget.path ?? "unknown.log"))),
      body: FutureBuilder<String>(
        future: contents,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Symbols.error_rounded),
                  Text(snapshot.error.toString()),
                ],
              ),
            );
          }

          if (snapshot.hasData) {
            return SingleChildScrollView(
              controller: _controller,
              padding: EdgeInsets.all(16.0),
              child: Text(
                snapshot.data ?? "",
                softWrap: true,
                style: TextStyle(
                  fontFamily: "monospace",
                  fontFamilyFallback: ["Poppins"],
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
