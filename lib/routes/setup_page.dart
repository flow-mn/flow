import 'package:flow/l10n/extensions.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/button.dart';
import 'package:flow/widgets/setup/foss_slide.dart';
import 'package:flow/widgets/setup/offline_slide.dart';
import 'package:flow/widgets/setup/welcome_slide.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  late final PageController _pageController;

  static const int slideCount = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          children: const [
            WelcomeSlide(),
            FossSlide(),
            OfflineSlide(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            SmoothPageIndicator(
              controller: _pageController, // PageController
              count: slideCount,
              effect: WormEffect(
                dotColor: context.flowColors.semi,
                activeDotColor: context.colorScheme.primary,
                dotWidth: 12.0,
                dotHeight: 12.0,
                radius: 12.0,
                spacing: 6.0,
              ),
              onDotClicked: (index) => _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
              ),
            ),
            const Spacer(),
            Button(
              onTap: next,
              trailing: const Icon(Symbols.chevron_right_rounded),
              child: Text("setup.next".t(context)),
            )
          ],
        ),
      ),
    );
  }

  void next() {
    if (_pageController.page == null) return;

    final int currentPage = _pageController.page!.round();

    if (currentPage < (slideCount - 1)) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    } else {
      context.push("/setup/profile");
    }
  }
}
