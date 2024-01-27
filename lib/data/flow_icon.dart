import 'package:flutter/material.dart';

/// An icon, emoji, or image used for [Account] or [Category]
abstract class FlowIconData {
  const FlowIconData();

  factory FlowIconData.icon(IconData iconData) => IconFlowIcon(iconData);
  factory FlowIconData.emoji(String char) => CharacterFlowIcon(char);
  factory FlowIconData.image(String path) => ImageFlowIcon(path);

  static FlowIconData parse(String serialized) {
    final String? type = serialized.split(":").firstOrNull;

    return switch (type) {
      "IconFlowIcon" => IconFlowIcon.parse(serialized),
      "ImageFlowIcon" => ImageFlowIcon.parse(serialized),
      "CharacterFlowIcon" => CharacterFlowIcon.parse(serialized),
      _ => throw UnimplementedError()
    };
  }

  static FlowIconData? tryParse(String serialized) {
    try {
      return parse(serialized);
    } catch (e) {
      return null;
    }
  }
}

/// Single character [FlowIconData]
///
/// Ideally, an emoji or a letter
class CharacterFlowIcon extends FlowIconData {
  final String character;

  CharacterFlowIcon._constructor(this.character)
      : assert(character.characters.length == 1);

  /// Will throw [StateError] if the string is empty
  factory CharacterFlowIcon(String character) {
    return CharacterFlowIcon._constructor(
      character.characters.first.toString(),
    );
  }

  @override
  String toString() => "CharacterFlowIcon:$character";

  static FlowIconData parse(String serialized) =>
      FlowIconData.emoji(serialized.split(":").last);

  static FlowIconData? tryParse(String serialized) {
    try {
      return parse(serialized);
    } catch (e) {
      return null;
    }
  }
}

class IconFlowIcon extends FlowIconData {
  final IconData iconData;

  const IconFlowIcon(this.iconData);

  @override
  String toString() {
    return "IconFlowIcon:${iconData.fontFamily},${iconData.fontPackage},${iconData.codePoint.toRadixString(16)}";
  }

  static FlowIconData parse(String serialized) {
    final payload = serialized.split(":")[1];

    final [fontFamily, fontPackage, codePointHex] = payload.split(",");

    return FlowIconData.icon(IconData(
      int.parse(codePointHex, radix: 16),
      fontFamily: fontFamily,
      fontPackage: fontPackage,
    ));
  }

  static FlowIconData? tryParse(String serialized) {
    try {
      return parse(serialized);
    } catch (e) {
      return null;
    }
  }
}

class ImageFlowIcon extends FlowIconData {
  /// Ideally, image is stored in data direcotry of the app.
  ///
  /// i.e., `~/.local/share/mn.flow.flow/` for Linux-based systems
  final String imagePath;

  const ImageFlowIcon(this.imagePath);

  @override
  String toString() => "ImageFlowIcon:$imagePath";

  static FlowIconData parse(String serialized) {
    final [_, path] = serialized.split(":");
    return FlowIconData.image(path);
  }

  static FlowIconData? tryParse(String serialized) {
    try {
      return parse(serialized);
    } catch (e) {
      return null;
    }
  }
}
