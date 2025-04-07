import "package:flow/data/github/contributor.dart";
import "package:flow/services/github.dart";
import "package:flow/utils/utils.dart";
import "package:flutter/material.dart";

class ContributorsPage extends StatefulWidget {
  const ContributorsPage({super.key});

  @override
  State<ContributorsPage> createState() => _ContributorsPageState();
}

class _ContributorsPageState extends State<ContributorsPage> {
  late final Future<List<GitHubContributor>?> fetchFuture;

  @override
  void initState() {
    super.initState();

    fetchFuture = GitHubService().fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contributors")),
      body: FutureBuilder(
        future: fetchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final List<GitHubContributor> contributors = snapshot.data!;

          return Wrap(
            children: [
              for (final GitHubContributor contributor in contributors)
                Card(
                  child: Column(
                    children: [
                      Image.network(contributor.avatarUrl),
                      Text(contributor.login),
                      Text("${contributor.contributions} contributions"),
                      TextButton(
                        onPressed: () {
                          openUrl(Uri.parse(contributor.htmlUrl));
                        },
                        child: const Text("View on GitHub"),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
