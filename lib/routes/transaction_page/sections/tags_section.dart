import "package:flow/entity/transaction/extensions/default/geo.dart";
import "package:flow/entity/transaction_tag.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/providers/transaction_tags_provider.dart";
import "package:flow/routes/transaction_page/section.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/transaction_tag_add_chip.dart";
import "package:flow/widgets/transaction_tag_chip.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:latlong2/latlong.dart";

class TagsSection extends StatelessWidget {
  final List<TransactionTag>? selectedTags;
  final VoidCallback selectTags;
  final ValueChanged<List<TransactionTag>> onTagsChanged;

  /// Used for suggesting nearby tags based on the transaction's location.
  final Geo? location;

  const TagsSection({
    super.key,
    this.selectedTags,
    required this.selectTags,
    required this.onTagsChanged,
    this.location,
  });

  @override
  Widget build(BuildContext context) {
    final List<TransactionTag>? suggestedGeoTags = switch (location
        ?.toLatLngPosition()) {
      LatLng latLng => TransactionTagsProvider.of(
        context,
      ).getCloseGeoTags(latLng, exclusionList: selectedTags),
      _ => null,
    };

    print("suggestedGeoTags: $suggestedGeoTags");
    print("location: $location");

    final bool hasSuggestedGeoTags = suggestedGeoTags?.isNotEmpty == true;

    return Section(
      title: "transaction.tags".t(context),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Frame(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: Column(
                crossAxisAlignment: .start,
                spacing: 8.0,
                children: [
                  Wrap(
                    spacing: 12.0,
                    runSpacing: 8.0,
                    children: [
                      TransactionTagAddChip(
                        onPressed: selectTags,
                        title: "transaction.tags.add".t(context),
                      ),
                      ...?suggestedGeoTags?.map(
                        (tag) => TransactionTagChip(
                          tag: tag,
                          selected: false,
                          isSuggestion: true,
                          onPressed: () {
                            _addTag(context, tag);
                          },
                        ),
                      ),
                      ...?selectedTags?.map(
                        (tag) => IgnorePointer(
                          child: TransactionTagChip(tag: tag, selected: true),
                        ),
                      ),
                    ],
                  ),
                  if (hasSuggestedGeoTags)
                    InfoText(
                      child: Text(
                        "transaction.tags.suggestionGuide".t(context),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        onTap: () {
          if (LocalPreferences().enableHapticFeedback.get()) {
            HapticFeedback.lightImpact();
          }

          selectTags();
        },
      ),
    );
  }

  void _addTag(BuildContext context, TransactionTag tag) {
    if (selectedTags?.contains(tag) == true) return;

    if (LocalPreferences().enableHapticFeedback.get()) {
      HapticFeedback.lightImpact();
    }

    onTagsChanged([...?selectedTags, tag]);
  }
}
