import "package:flutter/foundation.dart";
import "package:latlong2/latlong.dart";

String? downloadedFrom;

String appVersion = "0.0.0";
const bool debugBuild = false;

bool get flowDebugMode => kDebugMode || debugBuild;

final Uri discordInviteLink = Uri.parse("https://discord.gg/Ndh9VDeZa4");
final Uri maintainerKoFiLink = Uri.parse("https://flow.gege.mn/donate");
final Uri website = Uri.parse("https://flow.gege.mn");
final Uri guideUrl = Uri.parse("https://flow.gege.mn/docs");
final Uri flowGitHubRepoLink = Uri.parse("https://github.com/flow-mn/flow");
final Uri flowGitHubIssuesLink = Uri.parse(
  "https://github.com/flow-mn/flow/issues",
);
final Uri maintainerGitHubLink = Uri.parse("https://github.com/sadespresso");
final Uri enyHomeLink = Uri.parse("https://eny.gege.mn");
final Uri enyDashboardLink = Uri.parse("https://eny.gege.mn/dash");
final String enyLogoUrl =
    "https://cdn.gege.mn/eny/2026-01-21/07983467-1954-4496-a3f2-59e94aeb35f5/logo@192.png";
final String enyLogoLottieAnimationUrl =
    "https://cdn.gege.mn/eny/2025-12-22/db1b8661-c50d-45fb-ac62-9657b0143bed/eny-animation.json";

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

const String iOSAppGroupId = "group.mn.flow.flow";
