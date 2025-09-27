import "package:flow/entity/transaction/tag_type.dart";
import "package:flutter/widgets.dart";
import "package:material_symbols_icons/symbols.dart";

extension TransactionTagTypeExtension on TransactionTagType {
  IconData get icon {
    switch (this) {
      case TransactionTagType.generic:
        return Symbols.label_rounded;
      case TransactionTagType.location:
        return Symbols.map_rounded;
      case TransactionTagType.contact:
        return Symbols.person_rounded;
    }
  }
}
