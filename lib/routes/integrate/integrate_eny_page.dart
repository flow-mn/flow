import "dart:math" as math;

import "package:flow/l10n/extensions.dart";
import "package:flow/services/integrations/eny.dart";
import "package:flow/utils/extensions.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/wavy_divider.dart";
import "package:flow/widgets/integrations/eny_page/eny_privacy_notice.dart";
import "package:flow/widgets/scaffold_actions.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class IntegrateEnyPage extends StatefulWidget {
  final String apiKey;
  final String? email;

  const IntegrateEnyPage({super.key, required this.apiKey, this.email});

  @override
  State<IntegrateEnyPage> createState() => _IntegrateEnyPageState();
}

class _IntegrateEnyPageState extends State<IntegrateEnyPage> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("integrations.eny.connect".t(context))),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisSize: .min,
            children: [
              EnyPrivacyNotice(),
              const SizedBox(height: 24.0),
              const WavyDivider(),
              const SizedBox(height: 24.0),
              ListTile(
                leading: const Icon(Symbols.key_rounded),
                title: Text(
                  "${widget.apiKey.substring(0, math.min(widget.apiKey.length - 1, 12))}•••••••••••••••••••••",
                ),
              ),
              if (widget.email != null)
                ListTile(
                  leading: const Icon(Symbols.email_rounded),
                  title: Text(widget.email!),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ScaffoldActions(
        children: [
          Align(
            alignment: Alignment.center,
            child: Button(
              onTap: _busy ? null : _link,
              leading: const Icon(Symbols.link_rounded),
              child: Text("integrations.eny.connect".t(context)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _link() async {
    setState(() {
      _busy = true;
    });
    try {
      final bool success = await EnyService().connect(
        apiKey: widget.apiKey,
        email: widget.email,
      );
      if (!success) {
        throw Exception("Failed to connect to Eny");
      }
      if (mounted) {
        context.showToast(
          text: "integrations.eny.connect.success".t(context),
          type: .success,
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        context.showToast(
          text: "integrations.eny.invalidCredentials".t(context),
          type: .error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }
}
