import 'package:flow/theme/theme.dart';
import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final double size;

  const ProfileCard({
    super.key,
    this.size = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipOval(
          child: Container(
            color: context.colorScheme.secondary,
            child: Image.network(
              "https://github.com/sadespresso.png",
              width: size,
              height: size,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          "Batmend Ganbaatar",
          style: context.textTheme.headlineSmall,
        ),
      ],
    );
  }
}
