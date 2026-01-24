import "package:flutter/material.dart";
import "package:flutter_quill/flutter_quill.dart";

class DividerEmbedBuilder extends EmbedBuilder {
  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    return const Divider();
  }

  @override
  String get key => "divider";
}
