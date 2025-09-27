import "dart:ui";

extension ColorExtensions on Color {
  int get rgb => toARGB32() & 0x00FFFFFF;
}
