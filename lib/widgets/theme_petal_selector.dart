import "dart:math" as math;

import "package:flow/data/flow_icon.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/theme/flow_theme_group.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/theme_petal_selector/theme_petal_painter.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";

final Logger _log = Logger("ThemePetalSelector");

class ThemePetalSelector extends StatefulWidget {
  final bool playInitialAnimation;

  final double maxSize;

  final Duration animationDuration;
  final Duration animationStartDelay;

  final bool updateOnHover;

  final List<FlowThemeGroup> groups;

  const ThemePetalSelector({
    super.key,
    this.playInitialAnimation = true,
    this.updateOnHover = false,
    this.maxSize = 400.0,
    this.animationStartDelay = const Duration(milliseconds: 250),
    this.animationDuration = const Duration(milliseconds: 1000),
    required this.groups,
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

  int selectedGroupIndex = 0;

  bool busy = false;

  late bool oled;

  static const double petalRadiusProc = 0.1;
  static const double centerSpaceRadiusProc = 0.6;
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
      curve: Interval(0, 0.8, curve: Curves.easeIn),
    );
    opacityAnimation = CurvedAnimation(
      parent: animationController,
      curve: Interval(0.8, 1.0, curve: Curves.decelerate),
    );

    Future.delayed(widget.animationStartDelay).then((_) {
      if (!mounted) return;

      animationController.reset();
      animationController.forward(from: 0.0);
    });
  }

  @override
  void dispose() {
    animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String currentTheme = LocalPreferences().getCurrentTheme();
    int groupIndex = 0;
    int themeIndex = -1;

    for (int i = 0; i < widget.groups.length; i++) {
      final index = widget.groups[i].schemes.indexWhere(
        (scheme) => scheme.name == currentTheme,
      );
      if (index != -1) {
        groupIndex = i;
        themeIndex = index;
        break;
      }
    }

    if (themeIndex < 0) {
      groupIndex = selectedGroupIndex;
    }

    final int itemCount = widget.groups[groupIndex].schemes.length;

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
                constraints.maxWidth * petalRadiusProc * 1.5;

            return Stack(
              children: [
                SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: MouseRegion(
                    cursor: _cursor,
                    onHover: (event) {
                      final int? itemIndexAtPointer = getItemAtPointer(
                        event.localPosition,
                        constraints,
                        itemCount,
                      );

                      _cursor =
                          itemIndexAtPointer != null
                              ? SystemMouseCursors.click
                              : MouseCursor.defer;

                      setState(() {
                        hoveringIndex = itemIndexAtPointer;
                      });
                    },
                    onExit: (_) => setState(() => hoveringIndex = null),
                    child: GestureDetector(
                      onPanUpdate:
                          widget.updateOnHover
                              ? ((details) {
                                final int? itemIndexAtPointer =
                                    getItemAtPointer(
                                      details.localPosition,
                                      constraints,
                                      itemCount,
                                    );

                                if (itemIndexAtPointer == null) return;

                                setThemeByIndex(itemIndexAtPointer, groupIndex);
                              })
                              : null,
                      onTapUp: (details) {
                        final int? itemIndexAtPointer = getItemAtPointer(
                          details.localPosition,
                          constraints,
                          itemCount,
                        );

                        if (itemIndexAtPointer == null) return;

                        setThemeByIndex(itemIndexAtPointer, groupIndex);
                      },
                      child: AnimatedBuilder(
                        builder:
                            (context, child) => CustomPaint(
                              painter: ThemePetalPainter(
                                animationValue: flowerAnimation.value,
                                colors:
                                    widget.groups[groupIndex].schemes
                                        .map((theme) => theme.primary)
                                        .toList(),
                                selectedIndex: themeIndex,
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
                if (widget.groups.length > 1)
                  AnimatedBuilder(
                    builder:
                        (context, child) => SizedBox(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          child: Opacity(
                            opacity: opacityAnimation.value,
                            child: Center(
                              child: InkWell(
                                onTap: () {
                                  if (themeIndex >= 0) {
                                    setThemeByIndex(
                                      themeIndex,
                                      (groupIndex + 1),
                                    );
                                  } else {
                                    setState(() {
                                      selectedGroupIndex =
                                          (selectedGroupIndex + 1) %
                                          widget.groups.length;
                                    });
                                  }
                                },
                                borderRadius: BorderRadius.circular(999.0),
                                child: Container(
                                  width: middleButtonSize,
                                  height: middleButtonSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: context.colorScheme.primary,
                                  ),
                                  alignment: Alignment.center,
                                  child: FlowIcon(
                                    widget.groups[groupIndex].icon ??
                                        FlowIconData.emoji(
                                          groupIndex.toString(),
                                        ),
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

  void setThemeByIndex(int themeIndex, int groupIndex) async {
    if (busy) return;

    try {
      setState(() {
        busy = true;
      });

      final String themeName =
          widget
              .groups[(groupIndex % widget.groups.length)]
              .schemes[themeIndex]
              .name;

      await LocalPreferences().theme.themeName.set(themeName);
    } catch (e) {
      _log.warning("Something went wrong with the theme petal selector.", e);
    } finally {
      busy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  int? getItemAtPointer(
    Offset localPosition,
    BoxConstraints constraints,
    int itemCount,
  ) {
    final Offset adjustedPosition =
        localPosition -
        Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
    final double r = adjustedPosition.distance;

    final double totalR = constraints.maxWidth * 0.5;

    final double innerRadius = totalR * centerSpaceRadiusProc;
    final double outerRadius = innerRadius + (totalR * petalRadiusProc * 2);

    if (r < innerRadius || r > outerRadius) {
      return null;
    }

    final double angle =
        (math.atan2(adjustedPosition.dy, adjustedPosition.dx) +
            (math.pi * 3) +
            angleOffset) %
        (math.pi * 2);

    final double halfItemAngle = math.tan(
      (totalR * petalRadiusProc) / innerRadius,
    );
    final double sectorAngle = math.pi * 2 / itemCount;

    final double allowedError = halfItemAngle;

    final int closestIndex = ((angle / sectorAngle).round()) % itemCount;

    final double closestAngle =
        ((math.pi * 2) + (closestIndex * (math.pi * 2 / itemCount))) %
        (math.pi * 2);

    final double delta = (angle - (closestAngle)).abs();

    if (delta < allowedError) return closestIndex;
    if (math.pi * 2 - delta < allowedError) return closestIndex;

    return null;
  }
}
