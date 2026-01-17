import "package:flow/widgets/general/spinner.dart";
import "package:flutter/material.dart";

class ImportProgressIndicator extends StatelessWidget {
  final String text;

  const ImportProgressIndicator(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Spinner.center(),
              const SizedBox(height: 8.0),
              Center(child: Text(text, textAlign: TextAlign.center)),
            ],
          ),
        ),
      ),
    );
  }
}
