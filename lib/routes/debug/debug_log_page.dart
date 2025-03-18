import "dart:io";

import "package:flutter/material.dart";
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
        _controller.jumpTo(_controller.position.maxScrollExtent);
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
      appBar: AppBar(title: Text("Log - ${widget.path}")),
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
