import "dart:math";

import "package:flow/data/flow_button_type.dart";
import "package:flow/entity/user_preferences.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/services/integrations/eny.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/navbar_theme.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions/directionality.dart";
import "package:flow/widgets/sheets/select_flow_button_type_sheet.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart" hide Flow;
import "package:logging/logging.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:pie_menu/pie_menu.dart";

final Logger _log = Logger("NewTransactionButton");

class NewTransactionButton extends StatefulWidget {
  final Function(FlowButtonType type) onActionTap;

  const NewTransactionButton({super.key, required this.onActionTap});

  @override
  State<NewTransactionButton> createState() => _NewTransactionButtonState();
}

class _NewTransactionButtonState extends State<NewTransactionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final _bounceAnimation = Tween(begin: 0.0, end: (45.0 / 180) * pi)
      .animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOut,
          reverseCurve: Curves.easeIn,
        ),
      );

  bool _sheetOpen = false;
  bool _menuOpen = false;
  bool _pointerDownDelivered = false;
  bool? _accessibleNavigation;

  @override
  void initState() {
    super.initState();
    GestureBinding.instance.pointerRouter.addGlobalRoute(_observePointerDown);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final bool accessibleNavigation = MediaQuery.accessibleNavigationOf(
      context,
    );
    if (_accessibleNavigation == accessibleNavigation) return;

    _accessibleNavigation = accessibleNavigation;
    _log.fine("Button ready: accessibleNavigation=$accessibleNavigation");
  }

  @override
  void dispose() {
    GestureBinding.instance.pointerRouter.removeGlobalRoute(
      _observePointerDown,
    );
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NavbarTheme navbarTheme = Theme.of(context).extension<NavbarTheme>()!;
    final double touchSlop = max(
      kTouchSlop,
      MediaQuery.gestureSettingsOf(context).touchSlop ?? kTouchSlop,
    );

    return AnimatedBuilder(
      animation: Listenable.merge([
        UserPreferencesService().valueNotifier,
        EnyService().apiKey,
      ]),
      builder: (context, _) {
        final UserPreferences userPreferences = UserPreferencesService().value;
        final bool enyConnected = EnyService().apiKey.value?.isNotEmpty == true;

        final List<FlowButtonType> buttonOrder = switch ((
          context.isLtr,
          enyConnected,
        )) {
          (true, true) => userPreferences.transactionButtonOrder,
          (true, false) =>
            userPreferences.transactionButtonOrder
                .where((type) => type != FlowButtonType.eny)
                .toList(),
          (false, true) =>
            userPreferences.transactionButtonOrder.reversed.toList(),
          (false, false) =>
            userPreferences.transactionButtonOrder.reversed
                .where((type) => type != FlowButtonType.eny)
                .toList(),
        };

        return PieMenu(
          // [PieMenu] skips the radial menu under accessible navigation, and
          // only calls [onPressed]. Without it, the button does nothing.
          onPressed: MediaQuery.accessibleNavigationOf(context)
              ? () => _showSheet(buttonOrder)
              : null,
          theme: context.pieTheme.copyWith(
            // [PieMenu] closes the menu once the pointer moves further than
            // `pointerSize / 2`, so keep it at least as big as touch slop.
            pointerSize: touchSlop * 2,
            customAngle: 90.0,
            customAngleDiff: 48.0,
            radius: 108.0,
            customAngleAnchor: PieAnchor.center,
            leftClickShowsMenu: true,
            rightClickShowsMenu: true,
            regularPressShowsMenu: true,
            childBounceEnabled: false,
            pieBounceDuration: .zero,
            longPressDuration: .zero,
            longPressShowsMenu: true,
          ),
          onToggle: onToggle,
          actions: buttonOrder
              .map(
                (transactionType) => PieAction(
                  tooltip: Text(transactionType.localizedNameContext(context)),
                  semanticsLabel: transactionType.localizedNameContext(context),
                  onSelect: () => onSelect(transactionType),
                  child: Icon(transactionType.icon, weight: 800.0),
                  buttonTheme: PieButtonTheme(
                    backgroundColor: transactionType.actionBackgroundColor(
                      context,
                    ),
                    iconColor: transactionType.actionColor(context),
                  ),
                ),
              )
              .toList(),
          child: Listener(
            onPointerDown: _logPointerEvent,
            onPointerUp: _logPointerEvent,
            onPointerCancel: _logPointerEvent,
            child: Material(
              color: navbarTheme.transactionButtonBackgroundColor,
              shape: RoundedRectangleBorder(borderRadius: .circular(32.0)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: AnimatedBuilder(
                  animation: _bounceAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _bounceAnimation.value,
                      child: child,
                    );
                  },
                  child: Icon(
                    Symbols.add_rounded,
                    semanticLabel: "transaction.new".t(context),
                    fill: 0.0,
                    color: navbarTheme.transactionButtonForegroundColor,
                    weight: 600.0,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void onToggle(bool toggled) {
    _menuOpen = toggled;
    _log.fine("Radial menu ${toggled ? "opened" : "closed"}");

    if (toggled) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void onSelect(FlowButtonType type) {
    _log.fine("Selected transaction action: ${type.name}");
    widget.onActionTap(type);
  }

  void _showSheet(List<FlowButtonType> buttonOrder) async {
    if (_sheetOpen) return;

    _sheetOpen = true;
    _log.fine("Opening accessible transaction picker");

    try {
      final FlowButtonType? type = await showModalBottomSheet<FlowButtonType>(
        context: context,
        builder: (context) => SelectFlowButtonTypeSheet(types: buttonOrder),
        isScrollControlled: true,
      );

      if (!mounted || type == null) return;

      onSelect(type);
    } finally {
      _sheetOpen = false;
    }
  }

  void _logPointerEvent(PointerEvent event) {
    if (event is PointerDownEvent) {
      _pointerDownDelivered = true;
    }

    final MediaQueryData media = MediaQuery.of(context);

    _log.fine(
      "${event.runtimeType}: pointer=${event.pointer}, "
      "kind=${event.kind.name}, buttons=${event.buttons}, "
      "local=${event.localPosition}, time=${event.timeStamp.inMicroseconds}, "
      "accessibleNavigation=${media.accessibleNavigation}, "
      "touchSlop=${media.gestureSettings.touchSlop}, "
      "pixelRatio=${media.devicePixelRatio}, "
      "padding=${media.viewPadding}, gestures=${media.systemGestureInsets}",
    );
  }

  /// Global routes see every pointer down, even the ones an overlay or
  /// [IgnorePointer] kept from reaching this button's [Listener].
  void _observePointerDown(PointerEvent event) {
    if (event is! PointerDownEvent) return;

    final bool delivered = _pointerDownDelivered;
    _pointerDownDelivered = false;

    if (!mounted || delivered || _menuOpen) return;
    if (ModalRoute.of(context)?.isCurrent == false) return;
    if (!TickerMode.valuesOf(context).enabled) return;
    if (event.viewId != View.of(context).viewId) return;

    final RenderObject? box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return;

    final Offset local = box.globalToLocal(event.position);
    if (!box.size.contains(local)) return;

    _log.warning(
      "Touch reached Flutter inside transaction button bounds but missed "
      "the button hit test: pointer=${event.pointer}, local=$local, "
      "accessibleNavigation=$_accessibleNavigation",
    );
  }
}
