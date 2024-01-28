import 'package:flow/l10n/extensions.dart';
import 'package:flow/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 96.0),
              Text(
                "appName".t(context),
                style: context.textTheme.displayLarge?.copyWith(
                  color: context.colorScheme.primary,
                ),
              ),
              Text(
                "appShortDesc".t(context),
                style: context.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16.0),
              const Placeholder(),
              const Spacer(),
              const SizedBox(height: 16.0),
              Align(
                alignment: Alignment.topRight,
                child: TextButton.icon(
                  onPressed: () => next(),
                  icon: const Icon(Symbols.chevron_right),
                  label: Text("setup.getStarted".t(context)),
                  style: TextButton.styleFrom(
                    backgroundColor: context.colorScheme.primary,
                    foregroundColor: context.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void next() {
    context.push("/setup/account");
  }
}
