import "package:flutter/foundation.dart";
import "package:latlong2/latlong.dart";

String? downloadedFrom;

String appVersion = "0.0.0";
const bool debugBuild = false;

bool get flowDebugMode => kDebugMode || debugBuild;

final Uri discordInviteLink = Uri.parse("https://discord.gg/Ndh9VDeZa4");
final Uri maintainerKoFiLink = Uri.parse("https://flow.gege.mn/donate");
final Uri flowGitHubRepoLink = Uri.parse("https://github.com/flow-mn/flow");
final Uri flowGitHubIssuesLink = Uri.parse(
  "https://github.com/flow-mn/flow/issues",
);
final Uri maintainerGitHubLink = Uri.parse("https://github.com/sadespresso");

const double sukhbaatarSquareCenterLat = 47.918828;
const double sukhbaatarSquareCenterLong = 106.917604;

const LatLng sukhbaatarSquareCenter = LatLng(
  sukhbaatarSquareCenterLat,
  sukhbaatarSquareCenterLong,
);
