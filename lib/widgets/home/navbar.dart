import 'package:flow/l10n.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/home/navbar/navbar_button.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class Navbar extends StatelessWidget {
  final Function(int i) onTap;

  final int activeIndex;

  const Navbar({
    super.key,
    required this.onTap,
    this.activeIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(999.9),
        color: context.colorScheme.secondary,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          NavbarButton(
            index: 0,
            tooltip: "tabs.home".t(context),
            icon: Symbols.circle_rounded,
            onTap: onTap,
            activeIndex: activeIndex,
          ),
          NavbarButton(
            index: 1,
            tooltip: "tabs.stats".t(context),
            icon: Symbols.bar_chart_rounded,
            onTap: onTap,
            activeIndex: activeIndex,
          ),
          const SizedBox(
            width: 64.0 + 12.0 + 12.0,
          ),
          NavbarButton(
            index: 2,
            tooltip: "tabs.accounts".t(context),
            icon: Symbols.wallet_rounded,
            onTap: onTap,
            activeIndex: activeIndex,
          ),
          NavbarButton(
            index: 3,
            tooltip: "tabs.profile".t(context),
            icon: Symbols.person_rounded,
            onTap: onTap,
            activeIndex: activeIndex,
          ),
        ],
      ),
    );
  }
}
