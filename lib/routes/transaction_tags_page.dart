import "package:flow/entity/transaction_tag.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class TransactionTagsPage extends StatefulWidget {
  const TransactionTagsPage({super.key});

  @override
  State<TransactionTagsPage> createState() => _TransactionTagsPageState();
}

class _TransactionTagsPageState extends State<TransactionTagsPage> {
  QueryBuilder<TransactionTag> qb() => ObjectBox()
      .box<TransactionTag>()
      .query()
      .order(TransactionTag_.createdDate);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("transaction.tags".t(context))),
      body: SafeArea(
        child: StreamBuilder<List<TransactionTag>>(
          stream: qb()
              .watch(triggerImmediately: true)
              .map((event) => event.find()),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Spinner.center();
            }

            final List<TransactionTag> tags = snapshot.requireData;

            return ListView.builder(
              itemCount: tags.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ListTile(
                    title: Text("transaction.tags.new".t(context)),
                    leading: const Icon(Icons.add),
                    onTap: () => context.push("/transactionTags/new"),
                  );
                }

                final tag = tags[index - 1];
                return ListTile(
                  leading: FlowIcon(tag.icon, colorScheme: tag.colorScheme),
                  title: Text(tag.title),
                  onTap: () => context.push("/transactionTags/${tag.id}"),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
