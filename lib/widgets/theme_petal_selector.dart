import "dart:developer" show log;
import "dart:math" as math;

import "package:flow/prefs.dart";
import "package:flow/theme/color_themes/registry.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/theme_petal_selector/theme_petal_painter.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class ThemePetalSelector extends StatefulWidget {
  final bool playInitialAnimation;

  final double maxSize;

  final Duration animationDuration;
  final Duration animationStartDelay;

  final bool updateOnHover;

  const ThemePetalSelector({
    super.key,
    this.playInitialAnimation = true,
    this.updateOnHover = false,
    this.maxSize = 400.0,
    this.animationStartDelay = const Duration(milliseconds: 250),
    this.animationDuration = const Duration(milliseconds: 1000),
  });

  @override
  State<ThemePetalSelector> createState() => _ThemePetalSelectorState();
}

class _ThemePetalSelectorState extends State<ThemePetalSelector>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<double> flowerAnimation;
  late final Animation<double> opacityAnimation;

  MouseCursor _cursor = MouseCursor.defer;

  int? hoveringIndex;

  bool busy = false;

  static const double petalRadiusProc = 0.05;
  static const double centerSpaceRadiusProc = 0.3;
  static const double angleOffset = math.pi / -2;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    flowerAnimation = CurvedAnimation(
      parent: animationController,
      curve: Interval(
        0,
        0.8,
        curve: Curves.easeIn,
      ),
    );
    opacityAnimation = CurvedAnimation(
      parent: animationController,
      curve: Interval(
        0.8,
        1.0,
        curve: Curves.decelerate,
      ),
    );

    Future.delayed(widget.animationStartDelay).then(
      (_) {
        if (!mounted) return;

        animationController.reset();
        animationController.forward(from: 0.0);
      },
    );
  }

  @override
  void dispose() {
    animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String currentTheme = LocalPreferences().getCurrentTheme();
    final bool isDark = getTheme(currentTheme).isDark;
    final int selectedIndex = isDark
        ? lightDarkThemeMapping.values.toList().indexOf(currentTheme)
        : lightDarkThemeMapping.keys.toList().indexOf(currentTheme);

    return ConstrainedBox(
      constraints: BoxConstraints.tightForFinite(
        width: widget.maxSize,
        height: widget.maxSize,
      ),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double middleButtonSize =
                constraints.maxWidth * petalRadiusProc * 3.0;

            return Stack(
              children: [
                SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: MouseRegion(
                    cursor: _cursor,
                    onHover: (event) {
                      final int? itemIndexAtPointer =
                          getItemAtPointer(event.localPosition, constraints);

                      _cursor = itemIndexAtPointer != null
                          ? SystemMouseCursors.click
                          : MouseCursor.defer;

                      setState(() {
                        hoveringIndex = itemIndexAtPointer;
                      });
                    },
                    onExit: (_) => setState(() => hoveringIndex = null),
                    child: GestureDetector(
                      onPanUpdate: widget.updateOnHover
                          ? ((details) {
                              final int? itemIndexAtPointer = getItemAtPointer(
                                details.localPosition,
                                constraints,
                              );

                              if (itemIndexAtPointer == null) return;

                              setThemeByIndex(itemIndexAtPointer, isDark);
                            })
                          : null,
                      onTapUp: (details) {
                        final int? itemIndexAtPointer = getItemAtPointer(
                          details.localPosition,
                          constraints,
                        );

                        if (itemIndexAtPointer == null) return;

                        setThemeByIndex(itemIndexAtPointer, isDark);
                      },
                      child: AnimatedBuilder(
                        builder: (context, child) => CustomPaint(
                          painter: ThemePetalPainter(
                            animationValue: flowerAnimation.value,
                            colors: (isDark ? darkThemes : lightThemes)
                                .values
                                .map((theme) => theme.primary)
                                .toList(),
                            selectedIndex: selectedIndex,
                            hoveringIndex: hoveringIndex,
                            petalRadiusProc: petalRadiusProc,
                            centerSpaceRadiusProc: centerSpaceRadiusProc,
                            selectedColor: context.colorScheme.onSurface,
                            angleOffset: angleOffset,
                          ),
                        ),
                        animation: animationController,
                      ),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  builder: (context, child) => SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: Opacity(
                      opacity: opacityAnimation.value,
                      child: Center(
                        child: InkWell(
                          onTap: () => switchThemeMode(currentTheme),
                          borderRadius: BorderRadius.circular(999.0),
                          child: Container(
                            width: middleButtonSize,
                            height: middleButtonSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.colorScheme.primary,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              isDark
                                  ? Symbols.dark_mode_rounded
                                  : Symbols.light_mode_rounded,
                              size: middleButtonSize * 0.67,
                              color: context.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  animation: animationController,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void setThemeByIndex(int index, bool dark) async {
    if (busy) return;

    try {
      setState(() {
        busy = true;
      });

      final String themeName = dark
          ? lightDarkThemeMapping.values.elementAt(index)
          : lightDarkThemeMapping.keys.elementAt(index);

      await LocalPreferences().themeName.set(themeName);
    } catch (e) {
      log("[Theme Petal Selector] Something went wrong with the theme petal selector.",
          error: e);
    } finally {
      busy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void switchThemeMode(String currentTheme) async {
    if (busy) return;

    try {
      setState(() {
        busy = true;
      });

      final String? themeName = reverseThemeMode(currentTheme);

      if (themeName == null) {
        return;
      }

      await LocalPreferences().themeName.set(themeName);
    } catch (e) {
      log("[Theme Petal Selector] Something went wrong with the theme petal selector.",
          error: e);
    } finally {
      busy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  int? getItemAtPointer(Offset localPosition, BoxConstraints constraints) {
    final Offset adjustedPosition = localPosition -
        Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
    final double r = adjustedPosition.distance;

    final double innerRadius = constraints.maxWidth * centerSpaceRadiusProc;
    final double outerRadius =
        innerRadius + (constraints.maxWidth * 2 * petalRadiusProc);

    if (r < innerRadius || r > outerRadius) {
      return null;
    }

    final double angle = (math.atan2(adjustedPosition.dy, adjustedPosition.dx) +
            (math.pi * 3) +
            angleOffset) %
        (math.pi * 2);

    return (angle / (math.pi / 8.0)).round();
  }
}
