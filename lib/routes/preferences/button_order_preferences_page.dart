import "dart:developer";

import "package:dotted_border/dotted_border.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/home/preferences/button_order_preferences/transaction_type_button.dart";
import "package:flutter/material.dart";

class ButtonOrderPreferencesPage extends StatefulWidget {
  final Radius radius;

  const ButtonOrderPreferencesPage({
    super.key,
    this.radius = const Radius.circular(16.0),
  });

  @override
  State<ButtonOrderPreferencesPage> createState() =>
      ButtonOrderPreferencesPageState();
}

class ButtonOrderPreferencesPageState
    extends State<ButtonOrderPreferencesPage> {
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    final List<TransactionType> transactionButtonOrder =
        UserPreferencesService().transactionButtonOrder;

    return Scaffold(
      appBar: AppBar(
        title: Text("preferences.transactionButtonOrder".t(context)),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16.0),
                InfoText(
                  child: Text(
                    "preferences.transactionButtonOrder.guide".t(context),
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: transactionButtonOrder
                      .map(
                        (transactionType) => Container(
                          margin: EdgeInsets.only(
                            left: 8.0,
                            right: 8.0,
                            top:
                                transactionButtonOrder.indexOf(
                                      transactionType,
                                    ) !=
                                    1
                                ? 72.0
                                : 0.0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(widget.radius),
                          ),
                          clipBehavior: Clip.none,
                          child: DottedBorder(
                            options: RoundedRectDottedBorderOptions(
                              color: Theme.of(
                                context,
                              ).dividerColor.withAlpha(0x80),
                              strokeWidth: 4.0,
                              radius: widget.radius,
                              strokeCap: StrokeCap.round,
                              dashPattern: const [6.0, 10.0],
                            ),
                            child: DragTarget<TransactionType>(
                              onWillAcceptWithDetails: (details) =>
                                  details.data != transactionType,
                              onAcceptWithDetails: (details) => swap(
                                transactionButtonOrder,
                                details.data,
                                transactionType,
                              ),
                              builder: (context, candidateData, rejectedData) {
                                final List<TransactionType> candidates =
                                    candidateData.nonNulls.toList();

                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Draggable<TransactionType>(
                                    data: transactionType,
                                    childWhenDragging: TransactionTypeButton(
                                      type: transactionType,
                                      opacity: 0.25,
                                    ),
                                    feedback: TransactionTypeButton(
                                      type: transactionType,
                                    ),
                                    child: TransactionTypeButton(
                                      type: transactionType,
                                      opacity: candidates.isNotEmpty
                                          ? 0.5
                                          : 1.0,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void swap(
    List<TransactionType> order,
    TransactionType a,
    TransactionType b,
  ) async {
    if (busy) return;

    setState(() {
      busy = true;
    });

    try {
      final int indexA = order.indexOf(a);
      final int indexB = order.indexOf(b);

      order[indexA] = b;
      order[indexB] = a;

      UserPreferencesService().transactionButtonOrder = order;
    } catch (e) {
      log("An error was occured while swapping transaction button order: $e");
    } finally {
      busy = false;

      if (mounted) {
        setState(() {});
      }
    }
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

    UserPreferencesService().transactionButtonOrder = transactionButtonOrder;

    if (mounted) {
      setState(() {});
    }
  }
}
