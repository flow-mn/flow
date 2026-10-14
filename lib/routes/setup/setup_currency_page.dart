import "dart:io";

import "package:flow/l10n/extensions.dart";
import "package:flow/services/currency_registry.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/sheets/select_currency_sheet.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:go_router/go_router.dart";
import "package:intl/intl.dart";
import "package:intl/number_symbols_data.dart";
import "package:logging/logging.dart";
import "package:material_symbols_icons_flow/symbols.dart";

final Logger _log = Logger("SetupCurrencyPage");

class SetupCurrencyPage extends StatefulWidget {
  const SetupCurrencyPage({super.key});

  @override
  State<SetupCurrencyPage> createState() => _SetupCurrencyPageState();
}

class _SetupCurrencyPageState extends State<SetupCurrencyPage> {
  final String? _detectedCurrency = _detectCurrency();

  late final TextEditingController _textController = TextEditingController(
    text: _detectedCurrency ?? "~~~",
  );

  late String? _currency = _detectedCurrency;

  dynamic error;

  @override
  void initState() {
    super.initState();

    if (_detectedCurrency != null) return;

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      selectCurrency();
    });
  }

  @override
  void dispose() {
    _textController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("setup.primaryCurrency.setup".t(context))),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                InfoText(
                  child: Text("setup.primaryCurrency.description".t(context)),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  readOnly: true,
                  controller: _textController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => save(),
                  decoration: const InputDecoration(border: InputBorder.none),
                  textAlign: TextAlign.center,
                  style: _currency == null
                      ? context.textTheme.displaySmall?.semi(context)
                      : context.textTheme.displaySmall,
                ),
                if (error != null) ...[
                  const SizedBox(height: 8.0),
                  Text(
                    error.toString(),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.flowColors.expense,
                    ),
                  ),
                ],
                const SizedBox(height: 16.0),
                Button(
                  child: Text("setup.primaryCurrency.choose".t(context)),
                  onTap: () => selectCurrency(),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Spacer(),
              Button(
                onTap: save,
                trailing: const Icon(Symbols.chevron_right_rounded),
                child: Text("setup.next".t(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void selectCurrency() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SelectCurrencySheet(
        currentlySelected: _currency,
        suggested: [?_detectedCurrency],
      ),
      isScrollControlled: true,
    );

    _textController.text = result ?? _currency ?? "~~~";

    setState(() {
      _currency = result ?? _currency;
    });
  }

  /// Languages spoken in many countries, whose default currency says little
  /// about the user's (e.g., en_MN would otherwise default to USD)
  static const Set<String> _multiRegionLanguages = {
    "ar",
    "de",
    "en",
    "es",
    "fr",
    "nl",
    "pt",
    "ru",
    "zh",
  };

  /// The device locale's currency, if it's a supported one.
  static String? _detectCurrency() {
    try {
      final List<String> parts = Intl.canonicalizedLocale(
        Platform.localeName.split(".").first,
      ).split("_");
      final String language = parts.first;
      final String? region = parts.length > 1 ? parts.last : null;

      final String? locale =
          numberFormatSymbols.keys.firstWhereOrNull(
            (key) => region != null && key.endsWith("_$region"),
          ) ??
          (region == null ||
                  region.toLowerCase() == language ||
                  !_multiRegionLanguages.contains(language)
              ? language
              : null);

      final String? code = numberFormatSymbols[locale]?.DEF_CURRENCY_CODE
          .toUpperCase();

      if (code != null && CurrencyRegistryService().isCurrencyCodeValid(code)) {
        return code;
      }
    } catch (e) {
      _log.fine("Couldn't detect currency for ${Platform.localeName}", e);
    }

    return null;
  }

  void save() async {
    if (_currency == null) {
      error = "error.input.mustBeNotEmpty".t(context);

      setState(() {});

      return;
    }

    UserPreferencesService().primaryCurrency = _currency!;

    if (!mounted) return;

    await context.push("/setup/accounts");
  }
}
