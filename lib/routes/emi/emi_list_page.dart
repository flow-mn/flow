import "package:flow/entity/emi.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:flow/data/money.dart";

class EmiListPage extends StatefulWidget {
  const EmiListPage({super.key});

  @override
  State<EmiListPage> createState() => _EmiListPageState();
}

class _EmiListPageState extends State<EmiListPage> {
  QueryBuilder<Emi> qb() =>
      ObjectBox().box<Emi>().query().order(Emi_.createdDate, flags: Order.descending);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("emi.tracker".t(context)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push("/emi-tracker/new"),
        child: const Icon(Symbols.add_rounded),
      ),
      body: StreamBuilder<List<Emi>>(
        stream: qb()
            .watch(triggerImmediately: true)
            .map((event) => event.find()),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SafeArea(child: Spinner.center());
          }

          final List<Emi> emis = snapshot.requireData;

          if (emis.isEmpty) {
            return SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Symbols.receipt_long_rounded,
                        size: 64.0,
                        color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        "emi.noEmis".t(context),
                        textAlign: TextAlign.center,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Sort active first, completed at the bottom
          final List<Emi> activeEmis =
              emis.where((element) => element.status == "active").toList();
          final List<Emi> completedEmis =
              emis.where((element) => element.status == "completed").toList();

          final List<Emi> sortedEmis = [...activeEmis, ...completedEmis];

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: sortedEmis.length,
            itemBuilder: (context, index) {
              final emi = sortedEmis[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _EmiCard(
                  emi: emi,
                  onTap: () => context.push("/emi-tracker/${emi.id}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmiCard extends StatelessWidget {
  final Emi emi;
  final VoidCallback onTap;

  const _EmiCard({required this.emi, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final double progress = emi.totalInstallments > 0
        ? (emi.paidInstallments / emi.totalInstallments).clamp(0.0, 1.0)
        : 0.0;

    final currency = emi.account.target?.currency ?? "USD";

    return Surface(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24.0)),
      ),
      builder: (context) => InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(24.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          emi.title,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (emi.description != null && emi.description!.isNotEmpty) ...[
                          const SizedBox(height: 4.0),
                          Text(
                            emi.description!,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),
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
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "emi.remainingAmount".t(context),
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      MoneyText(
                        Money(emi.remainingAmount, currency),
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "emi.installmentAmount".t(context),
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      MoneyText(
                        Money(emi.installmentAmount, currency),
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
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
                  minHeight: 8.0,
                  backgroundColor: context.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(context.colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
