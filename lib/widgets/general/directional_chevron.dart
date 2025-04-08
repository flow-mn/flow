import "package:flow/widgets/general/rtl_flipper.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class DirectionalChevron extends StatelessWidget {
  const DirectionalChevron({super.key});

  @override
  Widget build(BuildContext context) {
    return const RTLFlipper(child: Icon(Symbols.chevron_right_rounded));
  }
}
