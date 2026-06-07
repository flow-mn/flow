import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flutter/material.dart";

/// Inline warning shown under analytics content when some amounts or balances
/// couldn't be converted to the primary currency (missing exchange rates).
class MissingRatesNotice extends StatelessWidget {
  final String message;

  const MissingRatesNotice({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Frame(
      child: Text(
        message,
        style: context.textTheme.bodySmall?.copyWith(
          color: context.flowColors.expense,
        ),
      ),
    );
  }
}
