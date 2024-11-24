import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/routes/account/account_edit_page.dart";
import "package:flow/routes/account_page.dart";
import "package:flow/routes/categories_page.dart";
import "package:flow/routes/category/category_edit_page.dart";
import "package:flow/routes/category_page.dart";
import "package:flow/routes/error_page.dart";
import "package:flow/routes/export/export_history_page.dart";
import "package:flow/routes/export_options_page.dart";
import "package:flow/routes/export_page.dart";
import "package:flow/routes/home_page.dart";
import "package:flow/routes/import_page.dart";
import "package:flow/routes/import_wizard/v1.dart";
import "package:flow/routes/preferences/button_order_preferences_page.dart";
import "package:flow/routes/preferences/money_formatting_preferences_page.dart";
import "package:flow/routes/preferences/numpad_preferences_page.dart";
import "package:flow/routes/preferences/pending_transactions.dart";
import "package:flow/routes/preferences/privacy_preferences_page.dart";
import "package:flow/routes/preferences/theme_preferences_page.dart";
import "package:flow/routes/preferences/transaction_geo_preferences_page.dart";
import "package:flow/routes/preferences/transfer_preferences_page.dart";
import "package:flow/routes/preferences_page.dart";
import "package:flow/routes/profile_page.dart";
import "package:flow/routes/setup/setup_accounts_page.dart";
import "package:flow/routes/setup/setup_categories_page.dart";
import "package:flow/routes/setup/setup_currency_page.dart";
import "package:flow/routes/setup/setup_profile_page.dart";
import "package:flow/routes/setup/setup_profile_picture_page.dart";
import "package:flow/routes/setup_page.dart";
import "package:flow/routes/support_page.dart";
import "package:flow/routes/transaction_page.dart";
import "package:flow/routes/transactions_page.dart";
import "package:flow/routes/utils/crop_square_image_page.dart";
import "package:flow/routes/utils/edit_markdown_page.dart";
import "package:flow/sync/export/mode.dart";
import "package:flow/sync/import/import_v1.dart";
import "package:flow/utils/utils.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:moment_dart/moment_dart.dart";

final router = GoRouter(
  errorBuilder: (context, state) => ErrorPage(error: state.error?.toString()),
  routes: [
    GoRoute(
      path: "/",
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: "/transaction/new",
      pageBuilder: (context, state) {
        final TransactionType? type = TransactionType.values.firstWhereOrNull(
          (element) => element.value == state.uri.queryParameters["type"],
        );

        return MaterialPage(
          child: TransactionPage.create(initialTransactionType: type),
          fullscreenDialog: true,
        );
      },
    ),
    GoRoute(
      path: "/transaction/:id",
      pageBuilder: (context, state) => MaterialPage(
        child: TransactionPage.edit(
          transactionId: int.tryParse(state.pathParameters["id"]!) ?? -1,
        ),
        fullscreenDialog: true,
      ),
    ),
    GoRoute(
      path: "/transactions",
      builder: (context, state) => TransactionsPage.all(
        title: "transactions.all".t(context),
      ),
    ),
    GoRoute(
      path: "/transactions/pending",
      builder: (context, state) => TransactionsPage.pending(
        title: "transactions.pending".t(context),
      ),
    ),
    GoRoute(
      path: "/account/new",
      builder: (context, state) => const AccountEditPage.create(),
    ),
    GoRoute(
        path: "/account/:id",
        builder: (context, state) => AccountPage(
              accountId: int.tryParse(state.pathParameters["id"]!) ?? -1,
              initialRange: TimeRange.tryParse(
                state.uri.queryParameters["range"] ?? "",
              ),
            ),
        routes: [
          GoRoute(
            path: "edit",
            pageBuilder: (context, state) => MaterialPage(
              child: AccountEditPage(
                accountId: int.tryParse(state.pathParameters["id"]!) ?? -1,
              ),
              fullscreenDialog: true,
            ),
          ),
          GoRoute(
            path: "transactions",
            builder: (context, state) => TransactionsPage.account(
              accountId: int.tryParse(state.pathParameters["id"]!) ?? -1,
              title: state.uri.queryParameters["title"],
            ),
          ),
        ]),
    GoRoute(
      path: "/category/new",
      builder: (context, state) => const CategoryEditPage.create(),
    ),
    GoRoute(
      path: "/category/:id",
      builder: (context, state) => CategoryPage(
        categoryId: int.tryParse(state.pathParameters["id"]!) ?? -1,
        initialRange: TimeRange.tryParse(
          state.uri.queryParameters["range"] ?? "",
        ),
      ),
      routes: [
        GoRoute(
          path: "edit",
          pageBuilder: (context, state) => MaterialPage(
            child: CategoryEditPage(
              categoryId: int.tryParse(state.pathParameters["id"]!) ?? -1,
            ),
            fullscreenDialog: true,
          ),
        ),
      ],
    ),
    GoRoute(
      path: "/categories",
      builder: (context, state) => const CategoriesPage(),
    ),
    GoRoute(
      path: "/preferences",
      builder: (context, state) => const PreferencesPage(),
      routes: [
        GoRoute(
          path: "pendingTransactions",
          builder: (context, state) =>
              const PendingTransactionPreferencesPage(),
        ),
        GoRoute(
          path: "numpad",
          builder: (context, state) => const NumpadPreferencesPage(),
        ),
        GoRoute(
          path: "transfer",
          builder: (context, state) => const TransferPreferencesPage(),
        ),
        GoRoute(
          path: "transactionButtonOrder",
          builder: (context, state) => const ButtonOrderPreferencesPage(),
        ),
        GoRoute(
          path: "transactionGeo",
          builder: (context, state) => const TransactionGeoPreferencesPage(),
        ),
        GoRoute(
          path: "theme",
          builder: (context, state) => const ThemePreferencesPage(),
        ),
        GoRoute(
          path: "privacy",
          builder: (context, state) => const PrivacyPreferencesPage(),
        ),
        GoRoute(
          path: "moneyFormatting",
          builder: (context, state) => const MoneyFormattingPreferencesPage(),
        ),
      ],
    ),
    GoRoute(
      path: "/profile",
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: "/profile/:id",
      builder: (context, state) => ProfilePage(
          profileId: int.tryParse(state.pathParameters["id"]!) ?? -1),
    ),
    GoRoute(
      path: "/utils/cropsquare",
      pageBuilder: (context, state) {
        return switch (state.extra) {
          CropSquareImagePageProps props => MaterialPage(
              child: CropSquareImagePage(
                image: props.image,
                maxDimension: props.maxDimension,
                returnBitmap: props.returnBitmap,
              ),
              fullscreenDialog: true,
            ),
          _ => throw const ErrorPage(
              error:
                  "Invalid state. Pass [CropSquareImagePageProps] object to `extra` prop",
            )
        };
      },
    ),
    GoRoute(
      path: "/utils/editmd",
      pageBuilder: (context, state) {
        return switch (state.extra) {
          null => MaterialPage(
              child: EditMarkdownPage(),
              fullscreenDialog: true,
            ),
          EditMarkdownPageProps props => MaterialPage(
              child: EditMarkdownPage(
                initialValue: props.initialValue,
                maxLength: props.maxLength,
              ),
              fullscreenDialog: true,
            ),
          _ => throw const ErrorPage(
              error:
                  "Invalid state. Pass [EditMarkdownPageProps] object or nothing to `extra` prop",
            )
        };
      },
    ),
    GoRoute(
      path: "/exportOptions",
      builder: (context, state) => const ExportOptionsPage(),
    ),
    GoRoute(
      path: "/import",
      builder: (context, state) => const ImportPage(),
    ),
    GoRoute(
      path: "/import/wizard/v1",
      builder: (context, state) {
        if (state.extra case ImportV1 importV1) {
          return ImportWizardV1Page(importer: importV1);
        }

        return ErrorPage(
          error: "error.sync.invalidBackupFile".t(context),
        );
      },
    ),
    GoRoute(
      path: "/export/history",
      builder: (context, state) => const ExportHistoryPage(),
    ),
    GoRoute(
      path: "/export/:type",
      builder: (context, state) => ExportPage(
        state.pathParameters["type"] == "csv"
            ? ExportMode.csv
            : ExportMode.json,
      ),
    ),
    GoRoute(
      path: "/import",
      builder: (context, state) => const ImportPage(),
    ),
    GoRoute(
      path: "/setup",
      builder: (context, state) => const SetupPage(),
      routes: [
        GoRoute(
          path: "profile",
          builder: (context, state) => const SetupProfilePage(),
        ),
        GoRoute(
          path: "profile/photo",
          builder: (context, state) => SetupProfilePhotoPage(
            profileImagePath: state.extra as String,
          ),
        ),
        GoRoute(
          path: "currency",
          builder: (context, state) => const SetupCurrencyPage(),
        ),
        GoRoute(
          path: "accounts",
          builder: (context, state) => const SetupAccountsPage(),
        ),
        GoRoute(
          path: "categories",
          builder: (context, state) => const SetupCategoriesPage(),
        ),
      ],
    ),
    GoRoute(
      path: "/support",
      builder: (context, state) => const SupportPage(),
    ),
  ],
);
