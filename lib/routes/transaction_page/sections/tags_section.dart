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

  /// Transaction's saved location, used for suggesting nearby tags.
  final Geo? location;

  /// Device's current location, used in addition to [location] so that
  /// suggestions reflect both where the transaction happened and where the
  /// user is now (useful when editing an older transaction in a new place).
  final Geo? deviceLocation;

  const TagsSection({
    super.key,
    this.selectedTags,
    required this.selectTags,
    required this.onTagsChanged,
    this.location,
    this.deviceLocation,
  });

  @override
  Widget build(BuildContext context) {
    final TransactionTagsProvider provider = TransactionTagsProvider.of(
      context,
    );

    final List<LatLng> suggestionOrigins = [
      ?location?.toLatLngPosition(),
      ?deviceLocation?.toLatLngPosition(),
    ];

    final Set<String> seen = {};
    final List<TransactionTag> suggestedGeoTags = suggestionOrigins
        .expand(
          (origin) =>
              provider.getCloseGeoTags(origin, exclusionList: selectedTags),
        )
        .where((tag) => seen.add(tag.uuid))
        .toList();

    final bool hasSuggestedGeoTags = suggestedGeoTags.isNotEmpty;

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
                      ...suggestedGeoTags.map(
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
