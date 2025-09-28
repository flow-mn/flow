import "package:flow/l10n/extensions.dart";
import "package:flutter/material.dart";

mixin LocalizedEnum {
  String get localizationEnumValue;
  String get localizationEnumName;

  String get localizedTextKey =>
      "enum.$localizationEnumName@$localizationEnumValue";
}

extension LocalizedNameEnums on LocalizedEnum {
  String get localizedName => localizedTextKey.tr();
  String localizedNameContext(BuildContext context, [dynamic replace]) =>
      localizedTextKey.t(context, replace);
}
