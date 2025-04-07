import "dart:convert";

import "package:flow/data/github/contributor.dart";
import "package:http/http.dart" as http;
import "package:logging/logging.dart";

final Logger _log = Logger("GitHubService");

class GitHubService {
  final Map<int, List<GitHubContributor>> _cache = {};

  int? sessionKnownMaxPageContributors;

  static GitHubService? _instance;

  factory GitHubService() => _instance ??= GitHubService._internal();

  GitHubService._internal() {
    // Constructor
  }

  Future<List<GitHubContributor>> _fetchPageRaw([int page = 1]) async {
    assert(page > 0, "Page must be greater than 0");

    if (sessionKnownMaxPageContributors != null &&
        page > sessionKnownMaxPageContributors!) {
      _log.info(
        "Skipping fetch for page $page as it is known to be empty for this session. To reset, close the app and reopen.",
      );
      return [];
    }

    final Uri uri = Uri.parse(
      "https://api.github.com/repos/flow-mn/flow/contributors?per_page=100&page=$page",
    );

    final http.Response response = await http.get(
      uri,
      headers: {
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
      },
    );

    if (response.statusCode != 200) {
      _log.warning(
        "Failed to fetch contributors (page $page): ${response.statusCode}",
      );
      throw Exception("Failed to fetch contributors (page $page)");
    }

    final List data = jsonDecode(response.body);

    if (data.isEmpty) {
      sessionKnownMaxPageContributors = page - 1;
      _log.info(
        "No more contributors found at page $page. Flow will no longer fetch contributors for page $page and above.",
      );
    }

    return data.map((item) => GitHubContributor.fromJson(item as Map)).toList()
      ..sort((a, b) => b.contributions.compareTo(a.contributions));
  }

  Future<List<GitHubContributor>?> fetchPage([int page = 1]) async {
    assert(page > 0, "Page must be greater than 0");

    if (_cache[page] != null) {
      return _cache[page]!;
    }

    try {
      final List<GitHubContributor> contributors = await _fetchPageRaw(page);
      _cache[page] = contributors;

      return contributors;
    } catch (e, stackTrace) {
      _log.warning("Failed to fetch contributors (page $page)", e, stackTrace);

      return null;
    }
  }

  Future<List<GitHubContributor>?> fetchAll() async {
    final List<GitHubContributor> allContributors = [];

    for (int page = 1; page <= 5; page++) {
      final List<GitHubContributor>? contributors = await fetchPage(page);

      if (contributors == null) {
        continue;
      }

      allContributors.addAll(contributors);
    }

    return allContributors;
  }
}
