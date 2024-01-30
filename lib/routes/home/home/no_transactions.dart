import 'package:flow/l10n/extensions.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class NoTransactions extends StatelessWidget {
  final bool allTime;

  const NoTransactions({super.key, this.allTime = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              allTime
                  ? "tabs.home.noTransactions.allTime".t(context)
                  : "tabs.home.noTransactions.last7Days".t(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            const Icon(Symbols.family_star_rounded, size: 128.0),
            const SizedBox(height: 8.0),
            Text(
              "tabs.home.noTransactions.addSome".t(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
