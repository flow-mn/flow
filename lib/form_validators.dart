String? validateRequiredField(String? input) {
  if (input == null || input.isEmpty || input.trim().isEmpty) {
    return "error.input.mustBeNotEmpty";
  }

  return null;
}
