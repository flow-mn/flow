import "package:flow/data/exchange_rates.dart";
import "package:flow/data/multi_currency_flow.dart";
import "package:flow/data/single_currency_flow.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/data/transactions_filter/time_range.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/profile.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/services/accounts.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/transactions.dart";
import "package:flow/sync/export/export_pdf/headers.dart";
import "package:flutter/services.dart";
import "package:moment_dart/moment_dart.dart";
import "package:pdf/pdf.dart";
import "package:pdf/widgets.dart" as pw;

class ExportPdfOptions {
  final TimeRange timeRange;
  final List<Account>? whitelistedAccounts;
  final bool useA4;

  const ExportPdfOptions({
    required this.timeRange,
    this.whitelistedAccounts,
    this.useA4 = true,
  });
}

Future<Uint8List> generatePDFContent({
  required ExportPdfOptions options,
}) async {
  final List<pw.Font> fontFallbacks = [
    pw.Font.ttf(await rootBundle.load("assets/fonts/NotoEmoji-Regular.ttf")),
    pw.Font.ttf(
      await rootBundle.load("assets/fonts/NotoSansArabic-Regular.ttf"),
    ),
    pw.Font.ttf(
      await rootBundle.load("assets/fonts/NotoSansHebrew-Regular.ttf"),
    ),
  ];
  final pw.Font defaultFont = pw.Font.ttf(
    await rootBundle.load("assets/fonts/NotoSans-Regular.ttf"),
  );
  final Uint8List imageBytes = await rootBundle
      .load("assets/images/flow.png")
      .then((value) => value.buffer.asUint8List());

  final [
    List<Account> accounts,
    List<Category> categories,
  ] = await Future.wait<dynamic>([
    AccountsService().getAll(),
    ObjectBox().box<Category>().getAllAsync(),
  ]);

  final Map<String, String> accountNames = {
    for (final Account account in accounts) account.uuid: account.name,
  };

  final Map<String, String> categoryNames = {
    for (final Category category in categories) category.uuid: category.name,
  };

  final TransactionFilter filter = TransactionFilter(
    accounts: options.whitelistedAccounts
        ?.map((account) => account.uuid)
        .toList(),
    range: TransactionFilterTimeRange.fromTimeRange(options.timeRange),
    isPending: false,
    includeDeleted: false,
  );

  final List<Transaction> transactions = await TransactionsService().findMany(
    filter,
  );

  /// TODO @sadespresso maybe ask user to download missing fonts?
  // final Map<String, bool> potentialMissingFonts = {
  //   "korean": false,
  //   "chinese": false,
  //   "japanese": false,
  //   "arabic": false,
  // };

  final List<String?> resultingAccounts = transactions
      .map((transaction) {
        // TODO @sadespresso check if there's any CJK, Arabic, or other characters in the title

        return transaction.accountUuid;
      })
      .toSet()
      .toList();

  final pw.TextStyle defaultTextStyle = pw.TextStyle(
    font: defaultFont,
    color: PdfColor.fromInt(0xFF050505),
    fontSize: 10.0,
    fontFallback: fontFallbacks,
  );

  final pw.TextStyle fineTextStyle = defaultTextStyle.copyWith(
    fontSize: 6.0,
    color: PdfColor.fromInt(0xa0050505),
  );

  final PdfColor dividerColor = PdfColor(
    204.0 / 255.0,
    204.0 / 255.0,
    204.0 / 255.0,
  );

  bool even = true;

  final pw.BoxDecoration rowEvenDeco = pw.BoxDecoration(
    color: PdfColor.fromInt(0xFFF5F6FA),
    border: pw.Border(bottom: pw.BorderSide(color: dividerColor, width: 0.5)),
  );
  final pw.BoxDecoration rowOddDeco = pw.BoxDecoration(
    color: PdfColor.fromInt(0xFFFFFFFF),
    border: pw.Border(bottom: pw.BorderSide(color: dividerColor, width: 0.5)),
  );

  pw.TableRow generateRow(Transaction transaction) {
    final String transactionDate = transaction.transactionDate.format(
      payload: "LLL",
      forceLocal: true,
    );

    final String title =
        transaction.title ??
        (transaction.isTransfer
            ? "transaction.transfer.fromToTitle".tr({
                "from":
                    accountNames[transaction
                        .extensions
                        .transfer
                        ?.fromAccountUuid] ??
                    "~",
                "to":
                    accountNames[transaction
                        .extensions
                        .transfer
                        ?.toAccountUuid] ??
                    "~",
              })
            : "transaction.fallbackTitle".tr());

    final String accountName = (transaction.isTransfer)
        ? "${accountNames[transaction.extensions.transfer!.fromAccountUuid] ?? "~"} -> ${accountNames[transaction.extensions.transfer!.toAccountUuid] ?? "~"}"
        : (accountNames[transaction.accountUuid] ?? "~");

    return pw.TableRow(
      decoration: (even = !even) ? rowEvenDeco : rowOddDeco,
      children:
          [
                pw.Text(
                  transactionDate,
                  style: defaultTextStyle.copyWith(fontSize: 8.0),
                ),
                pw.Text(title, style: defaultTextStyle.copyWith(fontSize: 8.0)),
                pw.Align(
                  child: pw.Text(transaction.money.formatMoney()),
                  alignment: pw.Alignment.topRight,
                ),
                pw.Text(accountName),
                pw.Text(categoryNames[transaction.categoryUuid] ?? "~"),
              ]
              .map(
                (cell) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 4.0,
                    vertical: 4.0,
                  ),
                  child: cell,
                ),
              )
              .toList(),
    );
  }

  final Map<String, SingleCurrencyFlow> accountFlowSummary = {};

  for (final transaction in transactions) {
    accountFlowSummary[accountNames[transaction.accountUuid] ?? "~"] ??=
        SingleCurrencyFlow(currency: transaction.currency);
    accountFlowSummary[accountNames[transaction.accountUuid] ?? "~"]!.add(
      transaction.money,
      null,
    );
  }

  final ExchangeRates? rates = ExchangeRatesService().getPrimaryCurrencyRates();

  late final SingleCurrencyFlow? allAccountsFlow;

  if (rates == null) {
    allAccountsFlow = null;
  } else {
    final MultiCurrencyFlow multiCurrencyFlow = MultiCurrencyFlow();

    for (final SingleCurrencyFlow flow in accountFlowSummary.values) {
      multiCurrencyFlow.add(flow.totalExpense);
      multiCurrencyFlow.add(flow.totalIncome);
    }

    allAccountsFlow = multiCurrencyFlow.merge(
      rates.baseCurrency.toUpperCase(),
      rates,
    );
  }

  final String author =
      ObjectBox().box<Profile>().getAll().firstOrNull?.name ?? "Flow";

  final TimeRange? realTimeRange = transactions.range;

  final pw.Document pdf = pw.Document(
    theme: pw.ThemeData(defaultTextStyle: defaultTextStyle),
    // TODO @sadespresso add l10n support
    title: "Flow - Transactions statement (${options.timeRange})",
    author: author,
    keywords: "Flow, statement, personal, non-legal",
  );

  final String formattedPdfRange = (realTimeRange ?? options.timeRange).format(
    useRelative: false,
  );

  pw.Widget footer(context) => pw.Container(
    width: double.infinity,
    margin: pw.EdgeInsets.only(top: 16.0),
    color: PdfColor.fromInt(0x00ffffff),
    child: pw.RichText(
      text: pw.TextSpan(
        style: fineTextStyle,
        baseline: 0.0,
        children: [
          pw.TextSpan(text: "sync.export.pdf.notice[0]".tr()),
          pw.WidgetSpan(
            child: pw.UrlLink(
              child: pw.Text("Flow", style: fineTextStyle),
              destination: "https://flow.gege.mn",
            ),
          ),
          pw.TextSpan(text: "sync.export.pdf.notice[1]".tr()),
          pw.TextSpan(text: " "),
          pw.TextSpan(
            text: "sync.export.pdf.header".tr({"range": formattedPdfRange}),
          ),
          pw.TextSpan(text: " "),
          pw.TextSpan(
            text: resultingAccounts
                .map((uuid) => accountNames[uuid])
                .nonNulls
                .join(", "),
          ),
        ],
      ),
    ),
  );

  final pw.PageTheme pageTheme = pw.PageTheme(
    clip: true,
    pageFormat: options.useA4 ? PdfPageFormat.a4 : PdfPageFormat.letter,
    buildBackground: (context) {
      return pw.FullPage(
        ignoreMargins: true,
        child: pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(
                color: PdfColor.fromInt(0xFFF5CCFF),
                width: 16.0,
              ),
            ),
          ),
        ),
      );
    },
    margin: pw.EdgeInsets.all(32.0),
  );

  pdf.addPage(
    pw.MultiPage(
      maxPages: 10000,
      pageTheme: pageTheme,
      footer: footer,
      build: (context) => [
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(vertical: 12.0),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Image(
                    pw.MemoryImage(imageBytes),
                    height: defaultTextStyle.fontSize! * 2,
                    width: defaultTextStyle.fontSize! * 2,
                  ),
                  pw.SizedBox(width: 6.0),
                  pw.Text("Flow"),
                ],
              ),
              pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Opacity(
                    opacity: 0.5,
                    child: pw.Text(
                      "sync.export.pdf.timeRange".tr(),
                      style: fineTextStyle.copyWith(),
                    ),
                  ),
                  pw.Text(options.timeRange.format(useRelative: false)),
                ],
              ),
            ],
          ),
        ),
        pw.Divider(color: dividerColor, height: 0.5),
        pw.SizedBox(height: 20),
        pw.Table(
          defaultColumnWidth: pw.FlexColumnWidth(),
          children: [
            pw.TableRow(
              decoration: rowOddDeco,
              children: PDFHeader.values
                  .map(
                    (header) => pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 4.0,
                      ),
                      child: pw.Text(
                        header.localizedName,
                        style: pw.TextStyle(
                          color: PdfColor.fromInt(0xff33004f),
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            ...transactions.map(generateRow),
          ],
        ),
      ],
    ),
  );

  pdf.addPage(
    pw.MultiPage(
      pageTheme: pageTheme,
      footer: footer,
      build: (context) {
        return [
          pw.SizedBox(height: 20),
          pw.Text(
            "sync.export.pdf.summary".tr({"range": formattedPdfRange}),
            style: pw.TextStyle(fontSize: 18.0, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 20),
          pw.Table(
            defaultColumnWidth: pw.FlexColumnWidth(),
            children: [
              pw.TableRow(
                decoration: rowOddDeco,
                children:
                    [
                          "",
                          "sync.export.pdf.summary.income",
                          "sync.export.pdf.summary.expense",
                          "sync.export.pdf.summary.flow",
                        ]
                        .map(
                          (header) => pw.Align(
                            alignment: pw.Alignment.topRight,
                            child: pw.Padding(
                              padding: pw.EdgeInsets.symmetric(
                                horizontal: 4.0,
                                vertical: 4.0,
                              ),
                              child: pw.Text(
                                header.tr(),
                                style: pw.TextStyle(
                                  color: PdfColor.fromInt(0xff33004f),
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
              ...accountFlowSummary.entries.map(
                (entry) => pw.TableRow(
                  decoration: (even = !even) ? rowEvenDeco : rowOddDeco,
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 4.0,
                      ),
                      child: pw.Text(
                        entry.key,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 4.0,
                      ),
                      child: pw.Align(
                        alignment: pw.Alignment.topRight,
                        child: pw.Text(entry.value.totalIncome.formatMoney()),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 4.0,
                      ),
                      child: pw.Align(
                        alignment: pw.Alignment.topRight,
                        child: pw.Text(entry.value.totalExpense.formatMoney()),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 4.0,
                      ),
                      child: pw.Align(
                        alignment: pw.Alignment.topRight,
                        child: pw.Text(entry.value.totalFlow.formatMoney()),
                      ),
                    ),
                  ],
                ),
              ),
              if (allAccountsFlow != null)
                pw.TableRow(
                  decoration: (even = !even) ? rowEvenDeco : rowOddDeco,
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 4.0,
                      ),
                      child: pw.Text(
                        "sync.export.pdf.summary.allAcounts".tr(),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 4.0,
                      ),
                      child: pw.Align(
                        alignment: pw.Alignment.topRight,
                        child: pw.Text(
                          allAccountsFlow.totalIncome.formatMoney(),
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 4.0,
                      ),
                      child: pw.Align(
                        alignment: pw.Alignment.topRight,
                        child: pw.Text(
                          allAccountsFlow.totalExpense.formatMoney(),
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 4.0,
                      ),
                      child: pw.Align(
                        alignment: pw.Alignment.topRight,
                        child: pw.Text(allAccountsFlow.totalFlow.formatMoney()),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ];
      },
    ),
  );

  return await pdf.save();
}
