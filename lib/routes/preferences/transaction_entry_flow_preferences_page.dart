import "package:flow/entity/user_preferences/transaction_entry_flow.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/general/wavy_divider.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class TransactionEntryFlowPreferencesPage extends StatefulWidget {
  const TransactionEntryFlowPreferencesPage({super.key});

  @override
  State<TransactionEntryFlowPreferencesPage> createState() =>
      _TransactionEntryFlowPreferencesPageState();
}

class _TransactionEntryFlowPreferencesPageState
    extends State<TransactionEntryFlowPreferencesPage> {
  late final List<TransactionEntryAction> _actions;
  bool _abandonUponActionCancelled = false;
  bool _skipSelectedFields = true;

  @override
  void initState() {
    super.initState();

    _actions = List.from(UserPreferencesService().transactionEntryFlow.actions);
    _abandonUponActionCancelled = UserPreferencesService()
        .transactionEntryFlow
        .abandonUponActionCancelled;
    _skipSelectedFields =
        UserPreferencesService().transactionEntryFlow.skipSelectedFields;
  }

  @override
  void dispose() {
    UserPreferencesService().transactionEntryFlow = TransactionEntryFlow(
      actions: _actions,
      abandonUponActionCancelled: _abandonUponActionCancelled,
      skipSelectedFields: _skipSelectedFields,
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: .start,
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
                  "preferences.transactionEntryFlow.skipSelectedFields".t(
                    context,
                  ),
                ),
                value: _skipSelectedFields,
                onChanged: (bool newValue) {
                  _skipSelectedFields = newValue;
                  setState(() {});
                },
              ),
              const SizedBox(height: 16.0),
              SwitchListTile(
                title: Text(
                  "preferences.transactionEntryFlow.abandonUponCancelForm".t(
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
              const WavyDivider(),
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
              ReorderableListView(
                shrinkWrap: true,
                onReorder: onReorder,
                proxyDecorator: proxyDecorator,
                physics: NeverScrollableScrollPhysics(),
                children: _actions
                    .map(
                      (action) => ListTile(
                        leading: Text(
                          (actionOrder++).toString(),
                          style: context.textTheme.labelLarge?.bold,
                        ),
                        key: ValueKey(action.value),
                        title: Text(action.localizedNameContext(context)),
                        subtitle: action == .inputTitle
                            ? Text(
                                "preferences.transactionEntryFlow.actions.lastItem"
                                    .t(context),
                              )
                            : null,
                        trailing: IconButton(
                          onPressed: () {
                            _actions.remove(action);
                            setState(() {});
                          },
                          icon: const Icon(Symbols.delete_forever_rounded),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16.0),
              const WavyDivider(),
              const SizedBox(height: 16.0),
              Column(
                mainAxisSize: .min,
                children: TransactionEntryAction.values
                    .where((action) => !_actions.contains(action))
                    .map((action) {
                      return ListTile(
                        trailing: const Icon(Symbols.add_rounded),
                        title: Text(action.localizedNameContext(context)),
                        onTap: () {
                          _actions.add(action);
                          setState(() {});
                        },
                      );
                    })
                    .toList(),
              ),
            ],
          ),
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

    /// If there's input title, force it to be the last action
    if (_actions.contains(TransactionEntryAction.inputTitle)) {
      _actions.remove(TransactionEntryAction.inputTitle);
      _actions.add(TransactionEntryAction.inputTitle);
    }

    setState(() {});
  }
}
