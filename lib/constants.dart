import "package:flutter/foundation.dart";
import "package:latlong2/latlong.dart";

String? downloadedFrom;

String appVersion = "0.0.0";
const bool debugBuild = true;

bool get flowDebugMode => kDebugMode || debugBuild;

final Uri discordInviteLink = Uri.parse("https://discord.gg/Ndh9VDeZa4");
final Uri maintainerKoFiLink = Uri.parse("https://flow.gege.mn/donate");
final Uri website = Uri.parse("https://flow.gege.mn");
final Uri flowGitHubRepoLink = Uri.parse("https://github.com/flow-mn/flow");
final Uri flowGitHubIssuesLink = Uri.parse(
  "https://github.com/flow-mn/flow/issues",
);
final Uri maintainerGitHubLink = Uri.parse("https://github.com/sadespresso");

const double sukhbaatarSquareCenterLat = 47.918828;
const double sukhbaatarSquareCenterLong = 106.917604;

const String appleAppStoreId = "6477741670";

final Uri csvImportTemplateUrl = Uri.parse(
  "https://docs.google.com/spreadsheets/d/1wxdJ1T8PSvzayxvGs7bVyqQ9Zu0DPQ1YwiBLy1FluqE/edit?usp=sharing",
);

const LatLng sukhbaatarSquareCenter = LatLng(
  sukhbaatarSquareCenterLat,
  sukhbaatarSquareCenterLong,
);
