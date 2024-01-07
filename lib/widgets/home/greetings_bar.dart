import 'package:flutter/material.dart';

class GreetingsBar extends StatelessWidget {
  const GreetingsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "Hello, sadespresso!",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Spacer(),
        const SizedBox(width: 12.0),
        const CircleAvatar(
          foregroundImage: NetworkImage(
            "https://github.com/sadespresso.png",
          ),
          radius: 20.0,
        ),
      ],
    );
  }
}
