import "package:flow/entity/user_preferences/transaction_entry_flow.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flutter/material.dart";

class TransactionEntryFlowPreferencesPage extends StatefulWidget {
  const TransactionEntryFlowPreferencesPage({super.key});

  @override
  State<TransactionEntryFlowPreferencesPage> createState() =>
      _TransactionEntryFlowPreferencesPageState();
}

class _TransactionEntryFlowPreferencesPageState
    extends State<TransactionEntryFlowPreferencesPage> {
  late final List<TransactionEntryAction> _actions;
  bool _abandonUponActionCancelled = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _actions = List.from(UserPreferencesService().transactionEntryFlow.actions);
    _abandonUponActionCancelled = UserPreferencesService()
        .transactionEntryFlow
        .abandonUponActionCancelled;
  }

  @override
  void dispose() {
    UserPreferencesService().transactionEntryFlow = TransactionEntryFlow(
      actions: _actions,
      abandonUponActionCancelled: _abandonUponActionCancelled,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int actionOrder = 1;

    return Scaffold(
      appBar: AppBar(
        title: Text("preferences.transactionEntryFlow".t(context)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Frame(
              child: InfoText(
                child: Text(
                  "preferences.transactionEntryFlow.description".t(context),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            SwitchListTile(
              title: Text(
                "preferences.transactions.listTile.showCategoryInList".t(
                  context,
                ),
              ),
              value: _abandonUponActionCancelled,
              onChanged: (bool newValue) {
                _abandonUponActionCancelled = newValue;
                setState(() {});
              },
            ),
            const SizedBox(height: 16.0),
            const Divider(),
            const SizedBox(height: 16.0),
            Frame(
              child: InfoText(
                child: Text(
                  "preferences.transactionEntryFlow.actions.description".t(
                    context,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ReorderableListView(
                onReorder: onReorder,
                proxyDecorator: proxyDecorator,
                children: _actions
                    .map(
                      (action) => ListTile(
                        leading: Text(
                          (actionOrder++).toString(),
                          style: context.textTheme.labelLarge?.bold,
                        ),
                        key: ValueKey(action.value),
                        title: Text(action.localizedNameContext(context)),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Material(elevation: 0, color: Colors.transparent, child: child);
      },
      child: child,
    );
  }

  void onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final removed = _actions.removeAt(oldIndex);
    _actions.insert(newIndex, removed);
    setState(() {});
  }
}
