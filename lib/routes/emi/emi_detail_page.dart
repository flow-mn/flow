import "package:flow/entity/emi.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/services/emi.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flow/utils/extensions/toast.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:intl/intl.dart";
import "package:flow/data/money.dart";

class EmiDetailPage extends StatefulWidget {
  final int emiId;

  const EmiDetailPage({super.key, required this.emiId});

  @override
  State<EmiDetailPage> createState() => _EmiDetailPageState();
}

class _EmiDetailPageState extends State<EmiDetailPage> {
  QueryBuilder<Transaction> transactionQuery(String emiUuid) => ObjectBox()
      .box<Transaction>()
      .query(Transaction_.extra.contains(emiUuid))
      .order(Transaction_.transactionDate, flags: Order.descending);

  Future<void> confirmDelete(Emi emi) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("emi.delete".t(context)),
        content: Text("emi.delete.confirm".t(context)),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text("general.cancel".t(context)),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            style: TextButton.styleFrom(
              foregroundColor: context.colorScheme.error,
            ),
            child: Text("general.delete".t(context)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await EmiService().deleteOne(emi.id);
      if (mounted) {
        context.pop();
      }
    }
  }

  Future<void> payInstallment(Emi emi) async {
    try {
      await EmiService().payInstallment(emi);
      if (mounted) {
        context.showToast(text: "emi.pay.success".t(context));
      }
    } catch (e) {
      if (mounted) {
        context.showToast(text: "Failed to pay installment: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final emiBox = ObjectBox().box<Emi>();

    return StreamBuilder<Emi?>(
      stream: emiBox
          .query(Emi_.id.equals(widget.emiId))
          .watch(triggerImmediately: true)
          .map((event) => event.findFirst()),
      builder: (context, emiSnapshot) {
        if (!emiSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: Spinner.center()),
          );
        }

        final Emi? emi = emiSnapshot.data;

        if (emi == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text("EMI tracker not found")),
          );
        }

        final double progress = emi.totalInstallments > 0
            ? (emi.paidInstallments / emi.totalInstallments).clamp(0.0, 1.0)
            : 0.0;

        final currency = emi.account.target?.currency ?? "USD";

        return Scaffold(
          appBar: AppBar(
            title: Text("emi.details".t(context)),
            actions: [
              IconButton(
                onPressed: () => context.push("/emi-tracker/${emi.id}/edit"),
                icon: const Icon(Symbols.edit_rounded),
              ),
              IconButton(
                onPressed: () => confirmDelete(emi),
                icon: Icon(Symbols.delete_rounded, color: context.colorScheme.error),
              ),
            ],
          ),
          body: StreamBuilder<List<Transaction>>(
            stream: transactionQuery(emi.uuid)
                .watch(triggerImmediately: true)
                .map((event) => event.find()),
            builder: (context, txSnapshot) {
              final transactions = txSnapshot.data ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emi.title,
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (emi.description != null && emi.description!.isNotEmpty) ...[
                      const SizedBox(height: 8.0),
                      Text(
                        emi.description!,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24.0),
                    Surface(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24.0)),
                      ),
                      builder: (context) => Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("emi.status".t(context)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: emi.status == "completed"
                                        ? context.colorScheme.primaryContainer
                                        : context.colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    emi.status == "completed"
                                        ? "emi.status.completed".t(context)
                                        : "emi.status.active".t(context),
                                    style: context.textTheme.labelSmall?.copyWith(
                                      color: emi.status == "completed"
                                          ? context.colorScheme.onPrimaryContainer
                                          : context.colorScheme.onSecondaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24.0),
                            _detailRow("emi.totalAmount".t(context), Money(emi.totalAmount, currency)),
                            _detailRow("emi.installmentAmount".t(context), Money(emi.installmentAmount, currency)),
                            _detailRow("emi.paidAmount".t(context), Money(emi.paidAmount, currency)),
                            _detailRow("emi.remainingAmount".t(context), Money(emi.remainingAmount, currency)),
                            const Divider(height: 24.0),
                            _textDetailRow("emi.totalInstallments".t(context), emi.totalInstallments.toString()),
                            _textDetailRow("emi.paidInstallments".t(context), emi.paidInstallments.toString()),
                            _textDetailRow("emi.remainingInstallments".t(context), emi.remainingInstallments.toString()),
                            const Divider(height: 24.0),
                            _textDetailRow("emi.startDate".t(context), DateFormat.yMMMMd().format(emi.startDate)),
                            if (emi.nextDueDate != null)
                              _textDetailRow("emi.nextDueDate".t(context), DateFormat.yMMMMd().format(emi.nextDueDate!)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${emi.paidInstallments} / ${emi.totalInstallments} ${"emi.paidInstallments".t(context).toLowerCase()}",
                          style: context.textTheme.bodySmall,
                        ),
                        Text(
                          "${(progress * 100).toStringAsFixed(0)}%",
                          style: context.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 12.0,
                        backgroundColor: context.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(context.colorScheme.primary),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    if (emi.status != "completed")
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => payInstallment(emi),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colorScheme.primary,
                            foregroundColor: context.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                          icon: const Icon(Symbols.payment_rounded),
                          label: Text("emi.payInstallment".t(context)),
                        ),
                      ),
                    const SizedBox(height: 32.0),
                    Text(
                      "emi.paymentsHistory".t(context),
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    if (transactions.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: Text(
                            "No payments logged yet.",
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final tx = transactions[index];
                          final int installmentNum = transactions.length - index;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Surface(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              builder: (context) => ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: context.colorScheme.secondaryContainer,
                                  child: Text(
                                    "#$installmentNum",
                                    style: context.textTheme.labelMedium?.copyWith(
                                      color: context.colorScheme.onSecondaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(tx.title ?? "Installment Payment"),
                                subtitle: Text(DateFormat.yMMMMd().format(tx.transactionDate)),
                                trailing: MoneyText(
                                  tx.money,
                                  style: context.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: context.flowColors.expense,
                                  ),
                                ),
                                onTap: () => context.push("/transaction/${tx.id}"),
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 32.0),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, Money value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textTheme.bodyMedium),
          MoneyText(
            value,
            style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _textDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textTheme.bodyMedium),
          Text(
            value,
            style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
