import "dart:developer";

import "package:dashed_border/dashed_border.dart";
import "package:flow/data/flow_button_type.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/services/integrations/eny.dart";
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

  List<FlowButtonType>? _animationData;

  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final List<FlowButtonType> transactionButtonOrder = List.from(
      UserPreferencesService().transactionButtonOrder,
    );

    if (EnyService().apiKey.value?.startsWith("eny") != true) {
      transactionButtonOrder.remove(FlowButtonType.eny);
    }

    final int count = transactionButtonOrder.length;
    final Size size = _calculateTotalSize(count);

    return Scaffold(
      appBar: AppBar(
        title: Text("preferences.transactionButtonOrder".t(context)),
      ),
      body: SingleChildScrollView(
        padding: const .all(16.0),
        child: SafeArea(
          child: Column(
            spacing: 16.0,
            crossAxisAlignment: .start,
            children: [
              InfoText(
                child: Text(
                  "preferences.transactionButtonOrder.guide".t(context),
                ),
              ),
              Center(
                child: SizedBox(
                  width: size.width,
                  height: size.height,
                  child: Stack(
                    alignment: .center,
                    children: [
                      for (int i = 0; i < count; i++)
                        _buildDropZone(
                          context,
                          index: i,
                          count: count,
                          transactionButtonOrder: transactionButtonOrder,
                        ),
                      ...transactionButtonOrder.map(
                        (transactionType) => _buildButton(
                          context,
                          transactionButtonOrder: transactionButtonOrder,
                          transactionType: transactionType,
                          count: count,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InfoText(
                child: Text(
                  "preferences.transactionButtonOrder.widgetDescription".t(
                    context,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculatePadding(int count) => count == 3 ? 16.0 : 6.0;
  double _calculateItemSize(int count) => 56.0 + _calculatePadding(count) * 2;

  Offset _resolvePosition(int index, int count) {
    final double itemSize = _calculateItemSize(count);

    final double x = 8.0 + (index * (itemSize + 16.0));

    final double y = switch ((count, index)) {
      (3, 1) => 2.0,
      (3, _) => 66.0,
      (4, 0 || 3) => 66.0,
      _ => 2.0,
    };

    return Offset(x, y);
  }

  Size _calculateTotalSize(int count) {
    final double itemSize = _calculateItemSize(count);

    final double width = (itemSize + 16.0) * count + 8.0;
    final double height = 72.0 + itemSize;

    return Size(width, height);
  }

  Positioned _buildDropZone(
    BuildContext context, {
    required List<FlowButtonType> transactionButtonOrder,
    required int index,
    required int count,
  }) {
    final FlowButtonType transactionType = transactionButtonOrder[index];
    final Offset position = _resolvePosition(index, count);
    final double size = _calculateItemSize(count);

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: .all(widget.radius),
          border: DashedBorder(
            color: Theme.of(context).dividerColor.withAlpha(0x80),
            width: 4.0,
            borderRadius: BorderRadius.all(widget.radius),
            dashLength: 6.0,
            dashGap: 10.0,
            style: .dashed,
          ),
        ),
        clipBehavior: .none,
        child: SizedBox.square(
          dimension: size,
          child: DragTarget<FlowButtonType>(
            onWillAcceptWithDetails: (details) =>
                details.data != transactionType,
            onAcceptWithDetails: (details) =>
                swap(transactionButtonOrder, details.data, transactionType),
            onMove: (details) => updateAnimationData(
              transactionButtonOrder,
              details.data,
              transactionType,
            ),
            builder:
                (
                  BuildContext context,
                  List<FlowButtonType?> candidateData,
                  List<dynamic> rejectedData,
                ) {
                  return SizedBox.shrink();
                },
          ),
        ),
      ),
    );
  }

  AnimatedPositioned _buildButton(
    BuildContext context, {
    required List<FlowButtonType> transactionButtonOrder,
    required FlowButtonType transactionType,
    required int count,
  }) {
    final int index = transactionButtonOrder.indexOf(transactionType);

    final int? animatedIndex = _dragging
        ? _animationData?.indexOf(transactionType)
        : null;

    final double padding = _calculatePadding(count);
    final Offset position =
        _resolvePosition(animatedIndex ?? index, count) + Offset(2.0, 2.0);

    return AnimatedPositioned(
      left: position.dx,
      top: position.dy,
      key: ValueKey<FlowButtonType>(transactionType),
      duration: const Duration(milliseconds: 120),
      child: IgnorePointer(
        ignoring: _dragging,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Draggable<FlowButtonType>(
            data: transactionType,
            childWhenDragging: TransactionTypeButton(
              type: transactionType,
              opacity: 0.0,
            ),
            onDragStarted: () {
              setState(() {
                _dragging = true;
                _animationData = transactionButtonOrder;
              });
            },
            onDragEnd: (details) {
              setState(() {
                _dragging = false;
                _animationData = null;
              });
            },
            feedback: TransactionTypeButton(type: transactionType),
            child: TransactionTypeButton(
              type: transactionType,
              opacity: 1.0,
              // opacity: candidates.isNotEmpty ? 0.5 : 1.0,
            ),
          ),
        ),
      ),
    );
  }

  void updateAnimationData(
    List<FlowButtonType> order,
    FlowButtonType dragging,
    FlowButtonType target,
  ) {
    if (!_dragging) return;
    if (_animationData == null) return;

    final List<FlowButtonType> copiedOrder = List.from(order);

    final int indexA = copiedOrder.indexOf(dragging);
    final int indexB = copiedOrder.indexOf(target);

    copiedOrder[indexA] = target;
    copiedOrder[indexB] = dragging;

    setState(() {
      _animationData = copiedOrder;
    });
  }

  void swap(
    List<FlowButtonType> order,
    FlowButtonType a,
    FlowButtonType b,
  ) async {
    if (busy) return;

    setState(() {
      busy = true;
    });

    try {
      final List<FlowButtonType> copiedOrder = List.from(order);

      final int indexA = copiedOrder.indexOf(a);
      final int indexB = copiedOrder.indexOf(b);

      copiedOrder[indexA] = b;
      copiedOrder[indexB] = a;

      _animationData = List.from(copiedOrder);

      UserPreferencesService().transactionButtonOrder = copiedOrder;
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
    List<FlowButtonType> transactionButtonOrder,
    int oldIndex,
    int newIndex,
  ) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final FlowButtonType removed = transactionButtonOrder.removeAt(oldIndex);
    transactionButtonOrder.insert(newIndex, removed);

    UserPreferencesService().transactionButtonOrder = transactionButtonOrder;

    if (mounted) {
      setState(() {});
    }
  }
}
