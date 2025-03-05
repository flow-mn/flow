import "package:flow/l10n/flow_localizations.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class AccountCardSkeleton extends StatelessWidget {
  final VoidCallback? onTap;
  final BorderRadius borderRadius;

  const AccountCardSkeleton({
    super.key,
    this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(24.0)),
  });

  @override
  Widget build(BuildContext context) {
    return Surface(
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      builder:
          (context) => InkWell(
            onTap: onTap,
            borderRadius: borderRadius,
            child: SizedBox(
              height: 179.0,
              width: double.infinity,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "account.new".t(context),
                      style: context.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8.0),
                    const Icon(
                      Symbols.add_rounded,
                      size: 40.0,
                      weight: 600.0,
                      opticalSize: 40.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
