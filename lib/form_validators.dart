import 'package:flow/l10n/extensions.dart';

String? validateRequiredField(String? input) {
  if (input == null || input.isEmpty || input.trim().isEmpty) {
    return "error.input.mustBeNotEmpty".tr();
  }

  return null;
}
