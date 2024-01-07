import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class IconCode {
  static String fromIconDataAndIdentifier(IconData data, String identifier) {
    return "$identifier:0x${data.codePoint.toRadixString(16)}";
  }

  static String fromMaterialSymbols(IconData data) =>
      IconCode.fromIconDataAndIdentifier(
        data,
        _identifierMaterialSymbolsFontFamily,
      );

  static IconData getIcon(String code) {
    final segments = code.split(":");

    if (segments.length < 2) {
      throw ArgumentError(
        "Argument 'code' must be valid icon code. e.g., Material Symbols:0xe8b6",
      );
    }

    final int? codePoint = int.tryParse(segments[1].substring(2), radix: 16);

    if (codePoint == null) {
      throw StateError(
          "Cannot parse the code point part. e.g., Material Symbols:0xe8b6 -> 0xe8b6 is the codepoint part, containing hex integer");
    }

    switch (segments.first) {
      case _identifierMaterialSymbolsFontFamily:
        return IconData(
          codePoint,
          fontFamily: _identifierMaterialSymbolsFontFamily,
          fontPackage: _identifierMaterialSymbolsPackage,
        );
      case "_identifierSimpleIconsFontFamily":
        return IconData(
          codePoint,
          fontFamily: _identifierSimpleIconsFontFamily,
          fontPackage: _identifierSimpleIconsPackage,
        );
      default:
        throw "Identifier ${segments.first} didn't have any matches";
    }
  }

  static const _identifierMaterialSymbolsFontFamily = 'MaterialSymbolsRounded';
  static const _identifierMaterialSymbolsPackage = 'material_symbols_icons';
  static const _identifierSimpleIconsFontFamily = 'SimpleIcons';
  static const _identifierSimpleIconsPackage = 'simple_icons';
}
