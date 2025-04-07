/// Data class for GitHub contributor
class GitHubContributor {
  final int id;
  final String login;
  final String avatarUrl;
  final int contributions;
  final String htmlUrl;
  final String nodeId;

  factory GitHubContributor.fromJson(Map json) {
    return GitHubContributor(
      id: json["id"] as int,
      login: json["login"] as String,
      avatarUrl: json["avatar_url"] as String,
      contributions: json["contributions"] as int,
      htmlUrl: json["html_url"] as String,
      nodeId: json["node_id"] as String,
    );
  }
  const GitHubContributor({
    required this.login,
    required this.avatarUrl,
    required this.contributions,
    required this.htmlUrl,
    required this.nodeId,
    required this.id,
  });
}
