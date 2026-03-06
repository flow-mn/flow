import "package:flutter_contacts/flutter_contacts.dart";

extension ContactExtension on Contact {
  String get resolvedName => displayName ?? name?.first ?? "<unnamed>";
}
