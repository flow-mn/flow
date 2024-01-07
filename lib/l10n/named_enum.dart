import 'package:flow/l10n.dart';
import 'package:flutter/material.dart';

abstract class LocalizedEnum {
  String get localizationEnumValue;
  String get localizationEnumName;
}

extension LocalizedNameEnums on LocalizedEnum {
  String get localizedName =>
      "enum.$localizationEnumName@$localizationEnumValue".tr();
  String localizedNameContext(BuildContext context, [dynamic replace]) =>
      "enum.$localizationEnumName@$localizationEnumValue".t(context, replace);
}
