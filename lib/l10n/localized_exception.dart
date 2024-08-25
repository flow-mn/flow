import "package:flow/l10n/extensions.dart";
import "package:flutter/material.dart";

abstract class LocalizedException {
  final String l10nKey;
  final dynamic l10nArgs;

  String localizedString(BuildContext context) => l10nKey.t(context, l10nArgs);

  const LocalizedException({required this.l10nKey, this.l10nArgs});
}
