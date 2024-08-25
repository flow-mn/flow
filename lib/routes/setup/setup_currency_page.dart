import "package:flow/l10n/extensions.dart";
import "package:flow/prefs.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/select_currency_sheet.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class SetupCurrencyPage extends StatefulWidget {
  const SetupCurrencyPage({super.key});

  @override
  State<SetupCurrencyPage> createState() => _SetupCurrencyPageState();
}

class _SetupCurrencyPageState extends State<SetupCurrencyPage> {
  final TextEditingController _textController =
      TextEditingController(text: "~~~");

  String? _currency;

  dynamic error;

  @override
  void initState() {
    super.initState();

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              InfoText(
                child: Text(
                  "setup.primaryCurrency.description".t(context),
                ),
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
                  style: context.textTheme.bodyMedium
                      ?.copyWith(color: context.flowColors.expense),
                )
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
              )
            ],
          ),
        ),
      ),
    );
  }

  void selectCurrency() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => const SelectCurrencySheet(),
      isScrollControlled: true,
    );

    _textController.text = result ?? _currency ?? "~~~";

    setState(() {
      _currency = result ?? _currency;
    });
  }

  void save() {
    if (_currency == null) {
      error = "error.input.mustBeNotEmpty".t(context);

      setState(() {});

      return;
    }

    LocalPreferences().primaryCurrency.set(_currency!);

    context.push("/setup/accounts");
  }
}
