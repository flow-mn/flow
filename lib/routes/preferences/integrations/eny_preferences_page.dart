import "package:flow/constants.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/services/integrations/eny.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/utils/open_url.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/general/wavy_divider.dart";
import "package:flow/widgets/integrations/eny_page/eny_privacy_notice.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class EnyPreferencesPage extends StatefulWidget {
  const EnyPreferencesPage({super.key});

  @override
  State<EnyPreferencesPage> createState() => _EnyPreferencesPageState();
}

class _EnyPreferencesPageState extends State<EnyPreferencesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Eny")),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              EnyPrivacyNotice(),
              const SizedBox(height: 24.0),
              const WavyDivider(),
              const SizedBox(height: 24.0),
              Frame(
                child: InfoText(
                  child: Text(
                    "integrations.eny.dashboard.description".t(context),
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              ListTile(
                leading: Icon(Symbols.space_dashboard_rounded),
                title: Text("integrations.eny.dashboard".t(context)),
                trailing: const DirectionalChevron(),
                onTap: () {
                  openUrl(enyDashboardLink);
                },
              ),
              ValueListenableBuilder(
                valueListenable: EnyService().apiKey,
                builder: (context, apiKey, child) {
                  final bool connected = apiKey != null;

                  return Column(
                    mainAxisSize: .min,
                    children: [
                      ListTile(
                        leading: Icon(
                          connected
                              ? Symbols.link_rounded
                              : Symbols.link_off_rounded,
                        ),
                        title: Text(
                          "integrations.eny.connected#$connected".t(context),
                        ),
                        subtitle: EnyService().email != null
                            ? Text(
                                EnyService().email!,
                                style: context.textTheme.bodyMedium?.semi(
                                  context,
                                ),
                              )
                            : null,

                        /// OCD :))))
                        trailing: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Icon(
                            Symbols.fiber_manual_record_rounded,
                            size: 12.0,
                            color: connected
                                ? context.flowColors.income
                                : context.flowColors.expense,
                          ),
                        ),
                      ),

                      if (connected)
                        ValueListenableBuilder(
                          valueListenable: EnyService().remainingCredits,
                          builder: (context, remainingCredits, child) {
                            return ListTile(
                              leading: Icon(Symbols.paid_rounded),
                              title: Text(
                                "integrations.eny.creditsRemaining".t(context),
                              ),
                              trailing: Text(
                                remainingCredits != null
                                    ? remainingCredits.toString()
                                    : "—",
                                style: context.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onTap: () {
                                EnyService().checkCredits();
                              },
                            );
                          },
                        ),
                      if (connected)
                        ListTile(
                          leading: Icon(Symbols.logout_rounded),
                          title: Text("integrations.eny.disconnect".t(context)),
                          trailing: const DirectionalChevron(),
                          onTap: () async {
                            // TODO @sadespresso confirmation sheet
                            await EnyService().disconnect();
                            if (mounted) {
                              setState(() {});
                            }
                          },
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
}
