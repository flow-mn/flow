import "package:flow/services/transactions.dart";
import "package:flutter/material.dart";

/// Rerenders its subtree when there are changes in the transactions.
///
/// The updates come from database layer, so it includes every change.
class TransactionWatcher extends StatefulWidget {
  final Widget Function(BuildContext context, int updateCount, Widget? child)
      builder;

  /// Cached child for performance, see [ValueListenableBuilder.child]
  final Widget? child;

  const TransactionWatcher({super.key, required this.builder, this.child});

  @override
  State<TransactionWatcher> createState() => _TransactionWatcherState();
}

class _TransactionWatcherState extends State<TransactionWatcher> {
  final ValueNotifier<int> _updateTracker = ValueNotifier(0);

  void _invalidateData() {
    setState(() {
      _updateTracker.value++;
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
    return ValueListenableBuilder<int>(
      valueListenable: _updateTracker,
      builder: widget.builder,
      child: widget.child,
    );
  }
}
