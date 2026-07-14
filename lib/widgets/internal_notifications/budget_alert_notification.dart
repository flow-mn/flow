import "package:flow/data/actionable_nofications/actionable_notification.dart";
import "package:flow/data/budget_progress.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/widgets/internal_notifications/internal_notification_list_tile.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";

class BudgetAlertNotification extends StatelessWidget {
  final BudgetAlert notification;
  final VoidCallback? onDismiss;

  const BudgetAlertNotification({
    super.key,
    required this.notification,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final BudgetProgress p = notification.payload;

    final bool over = p.status == BudgetStatus.over;

    return ActionableNotificationListTile(
      onDismiss: onDismiss,
      icon: notification.icon,
      title: over
          ? "budget.alert.over".t(context, {"name": p.budget.name})
          : "budget.alert.near".t(context, {
              "name": p.budget.name,
              "percent": "${p.percent}",
            }),
      subtitle: over
          ? "budget.alert.overBy".t(context, {"amount": p.overBy.formatted})
          : "budget.alert.left".t(context, {"amount": p.remaining.formatted}),
      action: TextButton.icon(
        onPressed: () {
          onDismiss?.call();
          context.push("/budgets/${p.budget.id}");
        },
        label: Text("budget.alert.action".t(context)),
        icon: Icon(Symbols.arrow_forward_rounded),
      ),
    );
  }
}
