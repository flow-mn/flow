import 'package:flow/entity/profile.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/objectbox.g.dart';
import 'package:flow/widgets/profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GreetingsBar extends StatelessWidget {
  QueryBuilder<Profile> qb() => ObjectBox().box<Profile>().query();

  const GreetingsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Query<Profile>>(
        stream: qb().watch(triggerImmediately: true),
        builder: (context, snapshot) {
          final profile = snapshot.data?.findFirst();

          return Row(
            children: [
              Text(
                "tabs.home.greetings".t(context, profile?.name ?? "..."),
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              const SizedBox(width: 12.0),
              ProfilePicture(
                filePath: profile?.imagePath,
                size: 40.0,
                onTap: profile != null
                    ? () => context.push("/profile/${profile.id}")
                    : null,
              ),
            ],
          );
        });
  }
}
