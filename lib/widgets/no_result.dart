import 'package:flow/l10n/extensions.dart';
import 'package:flow/theme/theme.dart';
import 'package:flutter/material.dart';

class NoResult extends StatelessWidget {
  const NoResult({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "transactions.query.noResult".t(context),
              textAlign: TextAlign.center,
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8.0),
            Text(
              "transactions.query.noResult.description".t(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
