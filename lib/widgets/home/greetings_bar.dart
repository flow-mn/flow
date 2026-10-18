import "package:auto_size_text/auto_size_text.dart";
import "package:flow/entity/profile.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/widgets/general/profile_picture.dart";
import "package:flow/widgets/home/privacy_toggler.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class GreetingsBar extends StatelessWidget {
  QueryBuilder<Profile> qb() => ObjectBox().box<Profile>().query();

  const GreetingsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Profile?>(
      stream: qb()
          .watch(triggerImmediately: true)
          .map((event) => event.findFirst()),
      builder: (context, snapshot) {
        final profile = snapshot.data;

        return Row(
          children: [
            ProfilePicture(
              filePath: profile?.imagePath,
              size: 36.0,
              onTap: profile != null
                  ? () => context.push("/profile/${profile.id}")
                  : null,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: AutoSizeText(
                switch (profile?.name.trim()) {
                  "" => "tabs.home.greetings.anonymous".t(context),
                  String name => "tabs.home.greetings".t(context, name),
                  null => "tabs.home.greetings".t(context, "..."),
                },
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12.0),
            const PrivacyToggler(),
          ],
        );
      },
    );
  }
}
