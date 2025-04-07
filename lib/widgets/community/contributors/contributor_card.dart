import "package:flow/data/github/contributor.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/utils/open_url.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flutter/material.dart";

class ContributorCard extends StatelessWidget {
  final GitHubContributor contributor;

  const ContributorCard({super.key, required this.contributor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => openUrl(Uri.parse(contributor.htmlUrl)),
      borderRadius: BorderRadius.circular(8.0),
      child: Material(
        type: MaterialType.transparency,
        shape: StadiumBorder(),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          width: 96.0,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: Container(
                  width: 64.0,
                  height: 64.0,
                  color: context.colorScheme.primary,
                  child: Image.network(
                    contributor.avatarUrl,
                    width: 64.0,
                    fit: BoxFit.cover,
                    loadingBuilder:
                        (context, child, loadingProgress) =>
                            loadingProgress == null ? child : Spinner(),
                  ),
                ),
              ),
              SizedBox(height: 4.0),
              Text(contributor.login, maxLines: 1, overflow: TextOverflow.fade),
            ],
          ),
        ),
      ),
    );
  }
}
