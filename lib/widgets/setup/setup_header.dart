import 'package:flow/theme/theme.dart';
import 'package:flutter/material.dart';

class SetupHeader extends StatelessWidget {
  final String text;

  const SetupHeader(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: Text(
        text,
        style: context.textTheme.headlineSmall,
      ),
    );
  }
}
