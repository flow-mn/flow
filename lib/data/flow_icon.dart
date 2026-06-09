import "dart:io";
import "dart:typed_data";
import "dart:ui" as ui;

import "package:cross_file/cross_file.dart";
import "package:flow/objectbox.dart";
import "package:flutter/material.dart";
import "package:path/path.dart" as path;
import "package:simple_icons_flow/simple_icons_flow.dart";
import "package:uuid/uuid.dart";

/// An icon, emoji, or image used for [Account] or [Category]
abstract class FlowIconData {
  const FlowIconData();

  factory FlowIconData.icon(IconData iconData) => IconFlowIcon(iconData);
  factory FlowIconData.simpleIcon(String slug) => SimpleIconFlowIcon(slug);
  factory FlowIconData.emoji(String char) => CharacterFlowIcon(char);
  factory FlowIconData.image(String path) => ImageFlowIcon(path);

  static FlowIconData parse(String serialized) {
    final String? type = serialized.split(":").firstOrNull;

    return switch (type) {
      "IconFlowIcon" => IconFlowIcon.parse(serialized),
      "SimpleIconFlowIcon" => SimpleIconFlowIcon.parse(serialized),
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

  /// Legacy [IconData.fontPackage] values that predate Flow's own forks of
  /// the icon packages. Icons saved before the rename still carry the
  /// original package name, so we remap on parse to keep their glyphs
  /// resolvable. The font families and code points are unchanged.
  ///
  /// Note: `simple_icons` brand icons are migrated to [SimpleIconFlowIcon]
  /// (slug-based) by `migrateSimpleIconsToSlug`; the entry below is only a
  /// best-effort fallback for any un-migrated legacy/backup data.
  static const Map<String, String> _fontPackageMigration = {
    "material_symbols_icons": "material_symbols_icons_flow",
    "simple_icons": "simple_icons_flow",
  };

  @override
  String toString() {
    return "IconFlowIcon:${iconData.fontFamily},${iconData.fontPackage},${iconData.codePoint.toRadixString(16)}";
  }

  static FlowIconData parse(String serialized) {
    final payload = serialized.split(":")[1];

    final [fontFamily, fontPackage, codePointHex] = payload.split(",");

    return FlowIconData.icon(
      IconData(
        // ignore: non_const_argument_for_const_parameter
        int.parse(codePointHex, radix: 16),
        // ignore: non_const_argument_for_const_parameter
        fontFamily: fontFamily,
        // ignore: non_const_argument_for_const_parameter
        fontPackage: _fontPackageMigration[fontPackage] ?? fontPackage,
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

/// A Simple Icons brand glyph, stored by its **slug** (the stable key in
/// [SimpleIcons.values], e.g. `paypal`) rather than a code point.
///
/// Simple Icons reassigns code points sequentially every release, so a stored
/// code point silently points at a different brand after a package bump. The
/// slug is stable across releases, so we persist that and resolve the glyph at
/// render time.
class SimpleIconFlowIcon extends FlowIconData {
  final String slug;

  const SimpleIconFlowIcon(this.slug);

  /// The resolved glyph, or `null` when the slug is no longer present in the
  /// bundled Simple Icons version (removed or renamed upstream).
  IconData? get iconData => SimpleIcons.values[slug];

  @override
  String toString() => "SimpleIconFlowIcon:$slug";

  static FlowIconData parse(String serialized) =>
      FlowIconData.simpleIcon(serialized.split(":").last);

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
