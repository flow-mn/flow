import 'package:flow/l10n/extensions.dart';
import 'package:flow/prefs.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/button.dart';
import 'package:flow/widgets/select_currency_sheet.dart';
import 'package:flow/widgets/setup/setup_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class SetupCurrencyPage extends StatefulWidget {
  const SetupCurrencyPage({super.key});

  @override
  State<SetupCurrencyPage> createState() => _SetupCurrencyPageState();
}

class _SetupCurrencyPageState extends State<SetupCurrencyPage> {
  String? _currency;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      selectCurrency();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SetupHeader("setup.primaryCurrency.setup".t(context)),
              // SelectCurrencySheet
              const SizedBox(height: 16.0),
              Text(
                _currency ?? "-",
                style: context.textTheme.displayMedium,
              ),
              const SizedBox(height: 16.0),
              Button(
                child: Text("setup.primaryCurrency.choose".t(context)),
                onTap: () => selectCurrency(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
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
    );
  }

  void selectCurrency() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => const SelectCurrencySheet(),
      isScrollControlled: true,
    );

    setState(() {
      _currency = result ?? _currency;
    });
  }

  void save() {
    LocalPreferences().primaryCurrency.set(_currency!);

    context.push("/setup/accounts");
  }
}
