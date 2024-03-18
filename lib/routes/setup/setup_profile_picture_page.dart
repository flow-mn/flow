import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flow/l10n/extensions.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/utils/utils.dart';
import 'package:flow/widgets/general/button.dart';
import 'package:flow/widgets/general/profile_picture.dart';
import 'package:flow/widgets/setup/setup_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' as path;

class SetupProfilePhotoPage extends StatefulWidget {
  final String profileImagePath;

  const SetupProfilePhotoPage({super.key, required this.profileImagePath});

  @override
  State<SetupProfilePhotoPage> createState() => _SetupProfilePhotoPageState();
}

class _SetupProfilePhotoPageState extends State<SetupProfilePhotoPage> {
  bool _selected = false;

  int _profilePictureUpdateCounter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SetupHeader("setup.profile.addPhoto".t(context)),
                const SizedBox(height: 16.0),
                ProfilePicture(
                  key: ValueKey(_profilePictureUpdateCounter),
                  filePath: widget.profileImagePath,
                  onTap: changeProfilePicture,
                  showOverlayUponHover: true,
                  size: MediaQuery.of(context).size.width * 0.5,
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Spacer(),
              Button(
                onTap: save,
                trailing: const Icon(Symbols.chevron_right_rounded),
                child: Text(_selected
                    ? "setup.next".t(context)
                    : "setup.profile.addPhoto.skip".t(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> changeProfilePicture() async {
    final cropped = await pickAndCropSquareImage(context, maxDimension: 512);
    if (cropped == null) {
      // Error toast is handled in `pickAndCropSquareImage`
      return;
    }

    final byteData = await cropped.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData?.buffer.asUint8List();

    if (bytes == null) throw "";

    final dataDirectory = ObjectBox.appDataDirectory;

    final file = File(path.join(
      dataDirectory,
      widget.profileImagePath,
    ));

    try {
      await FileImage(file).evict();
      _profilePictureUpdateCounter++;
    } catch (e) {
      log("[Flow] Setup Profile Photo Page > Failed to evict profile FileImage cache due to:\n$e");
    }

    await file.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);

    _selected = true;

    if (mounted) {
      setState(() {});
    }
  }

  void save() {
    context.push('/setup/currency');
  }
}
