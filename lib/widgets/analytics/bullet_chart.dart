import "dart:math" as math;

import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";

/// A compact bullet chart for budget-vs-actual style comparisons.
///
/// The track spans exactly `0 → [target]`, so the filled proportion always
/// agrees with the percentage shown next to it. A [value] past [target] fills
/// the track and recolors rather than rescaling it — an overrun is a state to
/// read off the color, not a longer bar.
///
/// Two optional layers sit on top:
/// * [pending] draws the not-yet-confirmed slice of [value] as a lighter
///   "ghost" tail, so committed-but-uncleared money is visible without looking
///   like it has already left the account.
/// * [paceRatio] draws a reference tick — for a budget, how much of the period
///   has elapsed. Fill past the tick means spending faster than time is
///   passing.
class BulletChart extends StatelessWidget {
  final double value;
  final double target;

  /// The portion of [value] that is still pending. Drawn as a ghost tail
  /// between the confirmed fill and [value].
  final double pending;

  /// Where to put the reference tick along the track, `0..1`. Null — or either
  /// extreme, where it carries nothing — hides it.
  final double? paceRatio;

  /// Bar color; defaults to a sensible "over/under target" choice.
  final Color? barColor;

  final double height;

  const BulletChart({
    super.key,
    required this.value,
    required this.target,
    this.pending = 0.0,
    this.paceRatio,
    this.barColor,
    this.height = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool over = value > target;

    final Color bar =
        barColor ??
        (over ? context.flowColors.expense : context.flowColors.income);
    final Color track = context.colorScheme.onSurface.withAlpha(0x1f);

    final double confirmed = math.max(0.0, value - pending);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;

        // A sliver a fraction of a pixel wide reads as "nothing spent", which
        // is a different thing entirely — give anything non-zero at least a
        // dot, the way the home-screen widget bars do.
        double bandWidth(double amount) {
          if (amount <= 0.0 || target <= 0.0) return 0.0;
          final double raw = (amount / target).clamp(0.0, 1.0) * width;
          return math.min(width, math.max(raw, height));
        }

        final double totalWidth = bandWidth(value);
        final double confirmedWidth = bandWidth(confirmed);

        final double? pace = paceRatio;
        final bool showPace = pace != null && pace > 0.0 && pace < 1.0;

        return SizedBox(
          height: height,
          width: width,
          child: Stack(
            children: [
              // Full track.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: track,
                    borderRadius: BorderRadius.all(Radius.circular(height / 2)),
                  ),
                ),
              ),
              // Ghost. Drawn as the *whole* bar rather than just the tail, so
              // the confirmed fill can land on top of it — that way the seam
              // between the two is a rounded cap nested inside a rounded cap,
              // instead of two pills butting into each other.
              if (totalWidth > confirmedWidth)
                Positioned(
                  left: 0.0,
                  top: 0.0,
                  bottom: 0.0,
                  child: Container(
                    width: totalWidth,
                    decoration: BoxDecoration(
                      color: bar.withAlpha(0x59),
                      borderRadius: BorderRadius.all(
                        Radius.circular(height / 2),
                      ),
                    ),
                  ),
                ),
              // Full track height, so it nests inside the track's rounded caps
              // instead of sitting flush against them.
              if (confirmedWidth > 0.0)
                Positioned(
                  left: 0.0,
                  top: 0.0,
                  bottom: 0.0,
                  child: Container(
                    width: confirmedWidth,
                    decoration: BoxDecoration(
                      color: bar,
                      borderRadius: BorderRadius.all(
                        Radius.circular(height / 2),
                      ),
                    ),
                  ),
                ),
              // Pace tick. Neutral rather than `primary`: `primary` follows the
              // user's accent color, and on a green accent that made this the
              // same hue as a healthy bar.
              if (showPace)
                Positioned(
                  left: math.max(
                    0.0,
                    math.min(width - 2.0, pace * width - 1.0),
                  ),
                  top: 0.0,
                  bottom: 0.0,
                  child: Container(
                    width: 2.0,
                    decoration: BoxDecoration(
                      color: context.colorScheme.onSurface.withAlpha(0x8a),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(1.0),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
