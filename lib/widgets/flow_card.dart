import 'package:auto_size_text/auto_size_text.dart';
import 'package:flow/entity/transaction.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/general/surface.dart';
import 'package:flutter/material.dart';

class FlowCard extends StatelessWidget {
  final TransactionType type;
  final double flow;

  const FlowCard({super.key, required this.flow, required this.type});

  @override
  Widget build(BuildContext context) {
    return Surface(builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: AutoSizeText(
          flow.money,
          style: context.textTheme.displaySmall?.copyWith(
            color: type.color(context),
          ),
          maxLines: 1,
        ),
      );
    });
  }
}
