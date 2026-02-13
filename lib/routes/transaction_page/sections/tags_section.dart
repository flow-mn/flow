import "package:flow/entity/transaction_tag.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/routes/transaction_page/section.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/transaction_tag_chip.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:material_symbols_icons/symbols.dart";

class TagsSection extends StatelessWidget {
  final List<TransactionTag>? selectedTags;
  final VoidCallback selectTags;

  const TagsSection({super.key, this.selectedTags, required this.selectTags});

  @override
  Widget build(BuildContext context) {
    return Section(
      title: "transaction.tags".t(context),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: selectedTags?.isNotEmpty == true
            ? Frame(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Align(
                    alignment: AlignmentDirectional.topStart,
                    child: Column(
                      crossAxisAlignment: .start,
                      spacing: 8.0,
                      children: [
                        IgnorePointer(
                          child: Wrap(
                            spacing: 12.0,
                            runSpacing: 8.0,
                            children: selectedTags!
                                .map(
                                  (tag) => TransactionTagChip(
                                    tag: tag,
                                    selected: true,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        InfoText(
                          child: Text("transaction.tags.editGuide".t(context)),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : ListTile(
                leading: Icon(Symbols.style_rounded),
                title: Text("transaction.edit.selectTags".t(context)),
                trailing: LeChevron(),
                onTap: selectTags,
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
}
