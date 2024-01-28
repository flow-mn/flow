import 'package:flow/theme/theme.dart';
import 'package:flutter/material.dart';

class ListHeader extends StatelessWidget {
  final String title;
  final EdgeInsets padding;

  final TextStyle? style;

  const ListHeader(
    this.title, {
    super.key,
    this.style,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        title,
        style: style ?? context.textTheme.titleSmall,
      ),
    );
  }
}
