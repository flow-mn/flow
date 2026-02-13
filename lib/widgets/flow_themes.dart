import "package:flow/services/user_preferences.dart";
import "package:flow/widgets/transaction_list_tile_theme.dart";
import "package:flutter/material.dart";

class FlowThemes extends StatefulWidget {
  final Widget child;

  const FlowThemes({super.key, required this.child});

  @override
  State<FlowThemes> createState() => _FlowThemesState();
}

class _FlowThemesState extends State<FlowThemes> {
  @override
  void initState() {
    super.initState();

    UserPreferencesService().valueNotifier.addListener(_rerender);
  }

  @override
  void dispose() {
    UserPreferencesService().valueNotifier.removeListener(_rerender);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool relaxed =
        UserPreferencesService().transactionListTileRelaxedDensity;

    return TransactionListTileTheme(
      data: TransactionListTileThemeData(
        useCategoryNameForUntitledTransactions:
            UserPreferencesService().useCategoryNameForUntitledTransactions,
        useAccountIconForLeading:
            UserPreferencesService().transactionListTileShowAccountForLeading,
        showExternalSource:
            UserPreferencesService().transactionListTileShowExternalSource,
        showCategory:
            UserPreferencesService().transactionListTileShowCategoryName,
        padding: relaxed
            ? EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0)
            : EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        spacing: relaxed ? 12.0 : 8.0,
        titleSpacing: relaxed ? 2.0 : 0.0,
      ),
      child: widget.child,
    );
  }

  void _rerender() {
    if (mounted) {
      setState(() {});
    }
  }
}
