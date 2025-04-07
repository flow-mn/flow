import "package:flow/data/flow_icon.dart";
import "package:flow/data/github/contributor.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/services/github.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/community/contributors/contributor_card.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class ContributorsPage extends StatefulWidget {
  const ContributorsPage({super.key});

  @override
  State<ContributorsPage> createState() => _ContributorsPageState();
}

class _ContributorsPageState extends State<ContributorsPage> {
  late Future<List<GitHubContributor>?> fetchFuture;

  @override
  void initState() {
    super.initState();

    fetchFuture = GitHubService().fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("contributors".t(context))),
      body: FutureBuilder(
        future: fetchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return Center(
              child: InkWell(
                onTap: () {
                  setState(() {
                    fetchFuture = GitHubService().fetchAll();
                  });
                },
                borderRadius: BorderRadius.circular(16.0),
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 16.0,
                    children: [
                      FlowIcon(
                        FlowIconData.icon(Symbols.wifi_off_rounded),
                        size: 80.0,
                        color: context.colorScheme.primary,
                      ),
                      Text("error.noConnection".t(context)),
                    ],
                  ),
                ),
              ),
            );
          }

          final List<GitHubContributor> contributors = snapshot.data!;

          return Align(
            alignment: Alignment.topCenter,
            child: Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children:
                  contributors
                      .map(
                        (contributor) =>
                            ContributorCard(contributor: contributor),
                      )
                      .toList(),
            ),
          );
        },
      ),
    );
  }
}
