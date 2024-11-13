import "dart:io";

bool isDesktop() {
  return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
}
