import "dart:async";

import "package:flow/services/external_toasts.dart";
import "package:flow/utils/extensions/toast.dart";
import "package:flutter/widgets.dart";

class ExternalToastsHandler extends StatefulWidget {
  final Widget child;

  const ExternalToastsHandler({super.key, required this.child});

  @override
  State<ExternalToastsHandler> createState() => _ExternalToastsHandlerState();
}

class _ExternalToastsHandlerState extends State<ExternalToastsHandler> {
  StreamSubscription? _toastSubscription;

  @override
  void initState() {
    super.initState();
    _toastSubscription = ExternalToastsService().toastStream.listen((
      toastData,
    ) {
      final message = toastData.$1;
      final type = toastData.$2;

      if (mounted) {
        // Use context to show toast
        // Assuming you have a ToastHelper extension method available
        context.showToast(text: message, type: type);
      }
    });
  }

  @override
  void dispose() {
    _toastSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
