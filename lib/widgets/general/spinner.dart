import "package:flutter/material.dart";

/// Indefinite waiting indicator
class Spinner extends StatelessWidget {
  final bool center;

  const Spinner({super.key, this.center = false});
  const Spinner.center({super.key}) : center = true;

  @override
  Widget build(BuildContext context) {
    const child = CircularProgressIndicator /*.adaptive*/ ();

    if (center) {
      return const Center(child: child);
    }

    return child;
  }
}
