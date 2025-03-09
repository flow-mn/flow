import "package:flow/l10n/named_enum.dart";

enum ExternalImportProgress implements LocalizedEnum {
  waitingConfirmation,
  validating,
  preparing,
  erasing,
  writing,
  success,
  error;

  @override
  String get localizationEnumValue => name;
  @override
  String get localizationEnumName => "ExternalImportProgress";
}
