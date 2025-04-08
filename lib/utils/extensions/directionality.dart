import "package:flutter/material.dart";

extension ContextDirectionality on BuildContext {
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
  bool get isLtr => Directionality.of(this) == TextDirection.ltr;
}
