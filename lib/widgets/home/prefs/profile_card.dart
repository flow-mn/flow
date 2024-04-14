import 'package:flow/entity/profile.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/general/profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:objectbox/objectbox.dart';

class ProfileCard extends StatelessWidget {
  QueryBuilder<Profile> qb() => ObjectBox().box<Profile>().query();

  final double size;

  final BorderRadius borderRadius;

  const ProfileCard({
    super.key,
    this.size = 100.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Profile?>(
        stream: qb()
            .watch(triggerImmediately: true)
            .map((event) => event.findFirst()),
        builder: (context, snapshot) {
          final profile = snapshot.data;

          return InkWell(
            borderRadius: borderRadius,
            onTap: () => context.push("/profile/${profile?.id}"),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 4.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Hero(
                    tag: "pfp",
                    child: ProfilePicture(filePath: profile?.imagePath),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    profile?.name ?? "unnamed",
                    style: context.textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          );
        });
  }
}
