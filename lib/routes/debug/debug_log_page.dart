import "dart:convert";
import "dart:io";

import "package:flutter/material.dart";
import "package:path/path.dart" as path;

class DebugLogPage extends StatefulWidget {
  final String path;

  const DebugLogPage({super.key, required this.path});

  @override
  State<DebugLogPage> createState() => _DebugLogPageState();
}

class _DebugLogPageState extends State<DebugLogPage> {
  List<String> _lines = [];

  bool _ready = false;

  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(path.basename(widget.path))),
      body:
          _ready
              ? DefaultTextStyle(
                style: TextStyle(
                  fontFamily: "monospace",
                  fontFamilyFallback: ["Poppins"],
                ),
                child: ListView.builder(
                  itemCount: _lines.length,
                  itemBuilder: (context, i) => Text(_lines[i]),
                  controller: _controller,
                  padding: EdgeInsets.all(16.0),
                ),
              )
              : const Center(child: CircularProgressIndicator()),
    );
  }

  void _load() async {
    _lines = await File(widget.path)
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .toList()
        .then((lines) => lines.reversed.toList());

    _ready = true;
    if (mounted) {
      setState(() {});
    }
  }
}
