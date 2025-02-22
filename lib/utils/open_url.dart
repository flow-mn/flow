import "package:flow/logging.dart";
import "package:url_launcher/url_launcher.dart";

Future<bool> openUrl(
  Uri uri, [
  LaunchMode mode = LaunchMode.externalApplication,
]) async {
  final canOpen = await canLaunchUrl(uri);
  if (!canOpen) return false;

  try {
    return await launchUrl(uri);
  } catch (e) {
    mainLogger.warning("Failed to launch uri ($uri) due to $e");
    return false;
  }
}
