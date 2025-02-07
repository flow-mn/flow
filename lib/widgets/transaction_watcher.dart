import "package:flow/services/transactions.dart";
import "package:flutter/material.dart";

/// Rerenders its subtree when there are changes in the transactions.
///
/// The updates come from database layer, so it includes every change.
class TransactionWatcher extends StatefulWidget {
  final Widget child;

  const TransactionWatcher({super.key, required this.child});

  @override
  State<TransactionWatcher> createState() => _TransactionWatcherState();
}

class _TransactionWatcherState extends State<TransactionWatcher> {
  int _updateTracker = 0;

  void _invalidateData() {
    setState(() {
      _updateTracker++;
    });
  }

  @override
  void initState() {
    super.initState();

    TransactionsService().addListener(_invalidateData);
  }

  @override
  void dispose() {
    TransactionsService().removeListener(_invalidateData);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: ValueKey(_updateTracker),
      child: widget.child,
    );
  }
}
