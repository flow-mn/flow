import "package:flow/constants.dart";
import "package:flutter/widgets.dart";
import "package:lottie/lottie.dart";

class AnimatedEnyLogo extends StatefulWidget {
  final bool noAnimation;

  const AnimatedEnyLogo({super.key, this.noAnimation = false});

  @override
  State<AnimatedEnyLogo> createState() => _AnimatedEnyLogoState();
}

class _AnimatedEnyLogoState extends State<AnimatedEnyLogo> {
  late final Future<LottieComposition> _composition;

  @override
  void initState() {
    super.initState();
    _composition = NetworkLottie(enyLogoLottieAnimationUrl).load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LottieComposition>(
      future: _composition,
      builder: (context, snapshot) {
        if (!widget.noAnimation && snapshot.hasData) {
          return Lottie(composition: snapshot.requireData, repeat: false);
        }

        return _enyLogoBuilder(context);
      },
    );
  }

  Widget _enyLogoBuilder(BuildContext context) {
    return Image.network(enyLogoUrl, width: 192.0, height: 192.0);
  }
}
