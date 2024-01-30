import 'dart:developer';
import 'dart:io';

import 'package:flow/entity/profile.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/objectbox.g.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class ProfilePage extends StatefulWidget {
  final int? profileId;

  const ProfilePage({super.key, this.profileId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final Profile? _profile;

  late final TextEditingController _nameController;

  bool busy=false;

  @override
  void initState() {
    super.initState();

    _profile = ObjectBox()
        .box<Profile>()
        .query(
          widget.profileId != null
              ? Profile_.id.equals(widget.profileId!)
              : null,
        )
        .build()
        .findFirst();

    _nameController = TextEditingController(text: _profile?.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _profile == null
            ? const Center(
                child: Text("Impossible state"),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    foregroundImage: switch (_profile!.imagePath) {
                      null => const AssetImage("assets/images/missing.svg"),
                      String imgPath => FileImage(
                          File(path.join(ObjectBox.appDataDirectory, imgPath)),
                        ),
                    } as ImageProvider,
                  ),
                  TextField(
                    controller: _nameController,
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> save() async {
    if (busy) return;

    setState(() {
      busy = true;
    });

    if (_profile == null) {
      throw "This is an impossible state. App setup hasn't been finished correctly";
    }

    try {
      await ObjectBox().box<Profile>().putAsync(_profile!);
    } catch (e) {
      log("[Profile Page] failed to put $_profile due to $e");
    } finally {
      busy = false;

      if (mounted) setState(() {});
    }
  }
}
