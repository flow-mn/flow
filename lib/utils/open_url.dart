import "package:flow/logging.dart";
import "package:url_launcher/url_launcher.dart";

Future<bool> openUrl(
  Uri uri, [
  LaunchMode mode = LaunchMode.externalApplication,
]) async {
  try {
    return await launchUrl(uri, mode: mode);
  } catch (e) {
    mainLogger.warning("Failed to launch ${uri.scheme} uri due to $e");
    return false;
  }
}
