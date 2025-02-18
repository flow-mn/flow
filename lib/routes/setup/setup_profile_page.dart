import "dart:async";

import "package:flow/entity/profile.dart";
import "package:flow/form_validators.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/button.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class SetupProfilePage extends StatefulWidget {
  const SetupProfilePage({super.key});

  @override
  State<SetupProfilePage> createState() => _SetupProfilePageState();
}

class _SetupProfilePageState extends State<SetupProfilePage> {
  final TextEditingController _textEditingController = TextEditingController();

  late Profile? _currentlyEditing;

  final GlobalKey<FormState> formKey = GlobalKey();

  bool testMode = false;

  bool busy = false;

  @override
  void initState() {
    super.initState();

    final Query<Profile> profileQuery =
        ObjectBox().box<Profile>().query().build();

    _currentlyEditing = profileQuery.findFirst();

    profileQuery.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("setup.profile.setup".t(context))),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextFormField(
                    controller: _textEditingController,
                    autofocus: true,
                    validator: validateRequiredField,
                    textInputAction: TextInputAction.send,
                    onFieldSubmitted: (value) => save(),
                  ),
                ),
                const SizedBox(height: 16.0),
                if (_textEditingController.text.trim().toLowerCase() == "test")
                  CheckboxListTile /*.adaptive*/ (
                    title: Text("Enable demo mode"),
                    value: testMode,
                    onChanged: (value) {
                      setState(() {
                        testMode = value ?? testMode;
                      });
                    },
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

  Future<void> save() async {
    if (busy) return;

    if (formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      busy = true;
    });

    final String trimmed = _textEditingController.text.trim();
    try {
      if (_currentlyEditing != null) {
        _currentlyEditing!.name = trimmed;
      } else {
        _currentlyEditing = Profile(name: trimmed);
      }

      final updatedProfile = await ObjectBox().box<Profile>().putAndGetAsync(
        _currentlyEditing!,
      );

      if (testMode) {
        unawaited(LocalPreferences().primaryCurrency.set("USD"));
        unawaited(ObjectBox().createAndPutDebugData());
        if (mounted) {
          GoRouter.of(context).popUntil((route) => route.path == "/setup");

          context.pushReplacement("/");
        }
      } else if (mounted) {
        await context.push(
          "/setup/profile/photo",
          extra: updatedProfile.imagePath,
        );
      }
    } finally {
      busy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }
}
