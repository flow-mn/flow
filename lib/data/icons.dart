library flow_selected_icons;

import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:material_symbols_icons/iconname_to_unicode_map.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:simple_icons/simple_icons.dart';

List<IconData> querySimpleIcons(String query) {
  final String trimmed = query.trim();

  if (trimmed.isEmpty) return SimpleIcons.values.values.toList();

  final List<String> queryResults = extractTop<String>(
    query: trimmed.startsWith(RegExp(r'\d')) ? "n$trimmed" : trimmed,
    choices: SimpleIcons.values.keys.toList(),
    limit: 50,
  ).map((extractedResult) => extractedResult.choice).toList();

  return queryResults.map((key) => SimpleIcons.values[key]!).toList();
}

IconData _getMaterialSymbolsForCodepoint(int codepoint) =>
    IconDataRounded(codepoint);

List<IconData> queryMaterialSymbols(String query) {
  final String trimmed = query.trim();

  if (trimmed.isEmpty) {
    return materialSymbolsIconNameToUnicodeMap.values
        .map(_getMaterialSymbolsForCodepoint)
        .toList();
  }

  final List<String> queryResults = extractTop<String>(
    query: trimmed.startsWith(RegExp(r'\d')) ? "n$trimmed" : trimmed,
    choices: materialSymbolsIconNameToUnicodeMap.keys.toList(),
    limit: 50,
  ).map((extractedResult) => extractedResult.choice).toList();

  return queryResults
      .map((key) => _getMaterialSymbolsForCodepoint(
          materialSymbolsIconNameToUnicodeMap[key]!))
      .toList();
}

const List<IconData> fSimpleIcons = [
  SimpleIcons.revolut,
  SimpleIcons.bankofamerica,
  SimpleIcons.nubank,
  SimpleIcons.hdfcbank,
  SimpleIcons.icicibank,
  SimpleIcons.commerzbank,
  SimpleIcons.deutschebank,
  SimpleIcons.starlingbank,
  SimpleIcons.aib,
  SimpleIcons.thurgauerkantonalbank,
  SimpleIcons.moneygram,
  SimpleIcons.fi,
  SimpleIcons.webmoney,
  SimpleIcons.onlyfans,
  SimpleIcons.payoneer,
  SimpleIcons.paypal,
  SimpleIcons.paytm,
  SimpleIcons.contactlesspayment,
  SimpleIcons.patreon,
  SimpleIcons.alipay,
  SimpleIcons.fampay,
  SimpleIcons.applepay,
  SimpleIcons.googlepay,
  SimpleIcons.googleadmob,
  SimpleIcons.googleadsense,
  SimpleIcons.googleads,
  SimpleIcons.amazonpay,
  SimpleIcons.samsungpay,
];
const List<IconData> fMaterialSymbols = [
  Symbols.wallet_rounded,
  Symbols.money_rounded,
  Symbols.send_money_rounded,
];
