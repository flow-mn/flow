import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flutter/material.dart";

class Section extends StatelessWidget {
  final String? title;
  final Widget child;
  final Widget? titleOverride;

  const Section({
    super.key,
    this.title,
    this.titleOverride,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: AlignmentDirectional.topStart,
          child: DefaultTextStyle(
            style: context.textTheme.labelMedium!.semi(context),
            child: Frame(child: titleOverride ?? Text(title ?? "A section")),
          ),
        ),
        child,
      ],
    );
  }
}
