import 'package:flutter/material.dart';

class LegendListTile extends StatelessWidget {
  final bool selected;

  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;

  final Color? color;

  final VoidCallback? onTap;

  const LegendListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.color,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      selected: selected,
      iconColor: color,
    );
  }
}
