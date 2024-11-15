import "package:flow/prefs.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class PrivacyToggler extends StatelessWidget {
  const PrivacyToggler({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: LocalPreferences().sessionPrivacyMode.valueNotifier,
      builder: (context, snapshot, _) {
        final bool obscure = snapshot == true;

        return IconButton(
          onPressed: () => LocalPreferences().sessionPrivacyMode.set(!obscure),
          icon: Icon(obscure
              ? Symbols.visibility_rounded
              : Symbols.visibility_off_rounded),
        );
      },
    );
  }
}
