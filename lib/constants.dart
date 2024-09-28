import "package:flutter/foundation.dart";

String appVersion = "0.0.0";
const debugBuild = false;

bool get flowDebugMode => kDebugMode || debugBuild;

final Uri discordInviteLink = Uri.parse("https://discord.gg/Ndh9VDeZa4");
final Uri maintainerKoFiLink = Uri.parse("https://ko-fi.com/sadespresso");
final Uri flowGitHubRepoLink = Uri.parse("https://github.com/flow-mn/flow");
final Uri flowGitHubIssuesLink =
    Uri.parse("https://github.com/flow-mn/flow/issues");
final Uri maintainerGitHubLink = Uri.parse("https://github.com/sadespresso");
