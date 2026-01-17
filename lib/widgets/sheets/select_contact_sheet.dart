import "package:flow/l10n/flow_localizations.dart";
import "package:flow/utils/optional.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/sheets/select_contact_sheet/no_contacts.dart";
import "package:flutter/material.dart";
import "package:flutter_contacts/flutter_contacts.dart";
import "package:fuzzywuzzy/fuzzywuzzy.dart";
import "package:go_router/go_router.dart";
import "package:logging/logging.dart";
import "package:material_symbols_icons/symbols.dart";

final Logger _log = Logger("SelectContactSheet");

/// Pops with a [Optional<Contact>] when a contact is selected, or null if selection is canceled.
class SelectContactSheet extends StatefulWidget {
  final String? initialSerach;

  const SelectContactSheet({super.key, this.initialSerach});

  @override
  State<SelectContactSheet> createState() => _SelectContactSheetState();
}

class _SelectContactSheetState extends State<SelectContactSheet> {
  final ScrollController _scrollController = ScrollController();

  late String _query;

  bool ready = false;

  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    _query = widget.initialSerach ?? "";

    FlutterContacts.getContacts(withPhoto: true)
        .then((value) {
          contacts = value;
        })
        .catchError((error, stackTrace) {
          _log.warning("Failed to get contacts", error, stackTrace);
        })
        .whenComplete(() {
          ready = true;
          if (mounted) {
            setState(() {});
          }
        });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String normalizedQuery = _query.trim().toLowerCase();

    final List<Contact> queriedContacts = normalizedQuery.isNotEmpty
        ? extractTop<Contact>(
            query: normalizedQuery,
            choices: contacts,
            getter: (contact) => contact.displayName.toLowerCase(),
            limit: 10,
          ).map((result) => result.choice).toList()
        : contacts;

    return ModalSheet.scrollable(
      title: Text("select.contact".t(context)),
      trailing: ModalOverflowBar(
        alignment: .end,
        children: [
          TextButton.icon(
            onPressed: () => context.pop(const Optional<Contact>(null)),
            icon: const Icon(Symbols.block_rounded),
            label: Text("select.contact.none".t(context)),
          ),
        ],
      ),
      leading: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: TextField(
          onChanged: _updateQuery,
          onSubmitted: _updateQuery,
          decoration: InputDecoration(
            hintText: "currency.searchHint".t(context),
            prefixIcon: const Icon(Symbols.search_rounded),
          ),
          autofocus: true,
        ),
      ),
      child: switch ((ready, contacts.length)) {
        (false, _) => const Spinner.center(),
        (true, 0) => const NoContacts(),
        (true, _) => ListView.builder(
          controller: _scrollController,
          itemCount: queriedContacts.length,
          itemBuilder: (context, index) {
            final contact = queriedContacts[index];
            return ListTile(
              leading: (contact.photo == null || contact.photo!.isEmpty)
                  ? CircleAvatar(child: Text(_contactInitials(contact)))
                  : CircleAvatar(backgroundImage: MemoryImage(contact.photo!)),
              title: Text(contact.displayName),
              subtitle: contact.phones.isNotEmpty
                  ? Text(contact.phones.first.number)
                  : null,
              onTap: () => context.pop(Optional(contact)),
            );
          },
        ),
      },
    );
  }

  void _updateQuery(String value) {
    _query = value;
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    setState(() {});
  }

  String _contactInitials(Contact contact) {
    final names = contact.displayName.split(" ");
    if (names.length == 1) {
      return names[0].substring(0, 1).toUpperCase();
    } else if (names.length > 1) {
      return (names[0].substring(0, 1) + names[1].substring(0, 1))
          .toUpperCase();
    } else {
      return "?";
    }
  }
}
