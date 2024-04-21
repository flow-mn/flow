import 'package:flow/entity/transaction.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/l10n/named_enum.dart';
import 'package:flow/prefs.dart';
import 'package:flow/theme/theme.dart';
import 'package:flutter/material.dart';

class ButtonOrderPreferencesPage extends StatefulWidget {
  const ButtonOrderPreferencesPage({super.key});

  @override
  State<ButtonOrderPreferencesPage> createState() =>
      ButtonOrderPreferencesPageState();
}

class ButtonOrderPreferencesPageState
    extends State<ButtonOrderPreferencesPage> {
  @override
  Widget build(BuildContext context) {
    final List<TransactionType> transactionButtonOrder = getButtonOrder();

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              SizedBox(
                height: 300.0,
                child: ReorderableListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (context, index) => ListTile(
                    key: ValueKey(transactionButtonOrder[index].value),
                    leading: Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: transactionButtonOrder[index]
                            .actionBackgroundColor(context),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        transactionButtonOrder[index].icon,
                        color:
                            transactionButtonOrder[index].actionColor(context),
                      ),
                    ),
                    title: Text(
                      transactionButtonOrder[index].localizedTextKey.t(context),
                    ),
                  ),
                  itemCount: transactionButtonOrder.length,
                  onReorder: (oldIndex, newIndex) =>
                      onReorder(transactionButtonOrder, oldIndex, newIndex),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onReorder(
    List<TransactionType> transactionButtonOrder,
    int oldIndex,
    int newIndex,
  ) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final TransactionType removed = transactionButtonOrder.removeAt(oldIndex);
    transactionButtonOrder.insert(newIndex, removed);

    await LocalPreferences().transactionButtonOrder.set(transactionButtonOrder);

    if (mounted) {
      setState(() {});
    }
  }

  List<TransactionType> getButtonOrder() {
    final value = LocalPreferences().transactionButtonOrder.get();

    if (value == null || value.length < 3) {
      // await
      LocalPreferences().transactionButtonOrder.set(TransactionType.values);

      return TransactionType.values;
    }

    return value;
  }
}
