import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";

class ImportError extends StatelessWidget {
  final dynamic error;

  const ImportError(this.error, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("sync.import".t(context))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            error.toString(),
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.error,
            ),
          ),
        ),
      ),
    );
  }
}
