import "dart:io";
import "dart:typed_data";
import "dart:ui" as ui;

import "package:cross_file/cross_file.dart";
import "package:flow/objectbox.dart";
import "package:flutter/material.dart";
import "package:path/path.dart" as path;
import "package:uuid/uuid.dart";

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
      _ => throw UnimplementedError(),
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

    return FlowIconData.icon(
      IconData(
        int.parse(codePointHex, radix: 16),
        fontFamily: fontFamily,
        fontPackage: fontPackage,
      ),
    );
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

  static Future<ImageFlowIcon?> tryFromData(dynamic data) async {
    try {
      final String? objectPath = await ImageFlowIcon.putImage(data);
      if (objectPath == null) return null;
      return ImageFlowIcon(objectPath);
    } catch (e) {
      return null;
    }
  }

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

  /// Returns the path for [ImageFlowIcon]
  static Future<String?> putImage(dynamic data) async {
    try {
      final Uint8List bytes = switch (data) {
        Uint8List b => b,
        XFile x => await x.readAsBytes(),
        File f => await f.readAsBytes(),
        ui.Image img =>
          await img
              .toByteData(format: ui.ImageByteFormat.png)
              .then((data) => data!.buffer.asUint8List()),
        _ => throw UnimplementedError(),
      };

      final String fileName = "${const Uuid().v4()}.png";
      final File file = File(path.join(ObjectBox.imagesDirectory, fileName));
      await file.create(recursive: true);
      await file.writeAsBytes(bytes, flush: true);

      return "${ObjectBox.imagesDirectoryName}/$fileName";
    } catch (e) {
      return null;
    }
  }
}
