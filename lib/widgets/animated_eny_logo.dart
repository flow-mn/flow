import "package:flow/constants.dart";
import "package:flutter/widgets.dart";
import "package:lottie/lottie.dart";

class AnimatedEnyLogo extends StatelessWidget {
  final bool noAnimation;

  const AnimatedEnyLogo({super.key, this.noAnimation = false});

  @override
  Widget build(BuildContext context) {
    if (noAnimation) {
      return _enyLogoBuilder(context, null, null);
    }

    return LottieBuilder.network(
      enyLogoLottieAnimationUrl,
      backgroundLoading: true,
      errorBuilder: _enyLogoBuilder,
      frameBuilder: (context, child, composition) {
        if (composition == null) {
          return _enyLogoBuilder(context, null, null);
        }

        return child;
      },
      repeat: false,
    );
  }

  Widget _enyLogoBuilder(BuildContext context, _, _) {
    return Image.network(enyLogoUrl, width: 192.0, height: 192.0);
  }
}
