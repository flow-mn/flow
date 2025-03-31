import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/routes/account/account_edit_page.dart";
import "package:flow/routes/account_page.dart";
import "package:flow/routes/accounts_page.dart";
import "package:flow/routes/categories_page.dart";
import "package:flow/routes/category/category_edit_page.dart";
import "package:flow/routes/category_page.dart";
import "package:flow/routes/debug/debug_log_page.dart";
import "package:flow/routes/debug/debug_logs_page.dart";
import "package:flow/routes/debug/debug_scheduled_notifications_page.dart";
import "package:flow/routes/debug/debug_theme_page.dart";
import "package:flow/routes/error_page.dart";
import "package:flow/routes/export/export_history_page.dart";
import "package:flow/routes/export_options_page.dart";
import "package:flow/routes/export_page.dart";
import "package:flow/routes/home_page.dart";
import "package:flow/routes/import_page.dart";
import "package:flow/routes/import_wizard/csv.dart";
import "package:flow/routes/import_wizard/v1.dart";
import "package:flow/routes/import_wizard/v2.dart";
import "package:flow/routes/preferences/sync_preferences_page.dart";
import "package:flow/routes/preferences/button_order_preferences_page.dart";
import "package:flow/routes/preferences/money_formatting_preferences_page.dart";
import "package:flow/routes/preferences/numpad_preferences_page.dart";
import "package:flow/routes/preferences/pending_transactions_preferences_page.dart";
import "package:flow/routes/preferences/reminders_preferences_page.dart";
import "package:flow/routes/preferences/theme_preferences_page.dart";
import "package:flow/routes/preferences/transaction_geo_preferences_page.dart";
import "package:flow/routes/preferences/transaction_list_item_appearance_preferences_page.dart";
import "package:flow/routes/preferences/transfer_preferences_page.dart";
import "package:flow/routes/preferences/trash_bin_preferences_page.dart";
import "package:flow/routes/preferences_page.dart";
import "package:flow/routes/profile_page.dart";
import "package:flow/routes/setup/setup_accounts_page.dart";
import "package:flow/routes/setup/setup_categories_page.dart";
import "package:flow/routes/setup/setup_currency_page.dart";
import "package:flow/routes/setup/setup_onboarding_page.dart";
import "package:flow/routes/setup/setup_profile_page.dart";
import "package:flow/routes/setup/setup_profile_picture_page.dart";
import "package:flow/routes/setup_page.dart";
import "package:flow/routes/stats/stats_by_group_page.dart";
import "package:flow/routes/support_page.dart";
import "package:flow/routes/transaction_page.dart";
import "package:flow/routes/transactions_page.dart";
import "package:flow/routes/utils/crop_square_image_page.dart";
import "package:flow/routes/utils/edit_markdown_page.dart";
import "package:flow/sync/export/mode.dart";
import "package:flow/sync/import/import_csv.dart";
import "package:flow/sync/import/import_v1.dart";
import "package:flow/sync/import/import_v2.dart";
import "package:flow/utils/utils.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:moment_dart/moment_dart.dart";

final router = GoRouter(
  errorBuilder: (context, state) => ErrorPage(error: state.error?.toString()),
  routes: [
    GoRoute(path: "/", builder: (context, state) => const HomePage()),
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
      pageBuilder:
          (context, state) => MaterialPage(
            child: TransactionPage.edit(
              transactionId: int.tryParse(state.pathParameters["id"]!) ?? -1,
            ),
            fullscreenDialog: true,
          ),
    ),
    GoRoute(
      path: "/transactions",
      builder:
          (context, state) =>
              TransactionsPage.all(title: "transactions.all".t(context)),
    ),
    GoRoute(
      path: "/transactions/pending",
      builder:
          (context, state) => TransactionsPage.pending(
            title: "transactions.pending".t(context),
          ),
    ),
    GoRoute(
      path: "/transactions/deleted",
      builder:
          (context, state) =>
              TransactionsPage.deleted(title: "transaction.deleted".t(context)),
    ),
    GoRoute(
      path: "/account/new",
      builder: (context, state) => const AccountEditPage.create(),
    ),
    GoRoute(
      path: "/account/:id",
      builder:
          (context, state) => AccountPage(
            accountId: int.tryParse(state.pathParameters["id"]!) ?? -1,
            initialRange: TimeRange.tryParse(
              state.uri.queryParameters["range"] ?? "",
            ),
          ),
      routes: [
        GoRoute(
          path: "edit",
          pageBuilder:
              (context, state) => MaterialPage(
                child: AccountEditPage(
                  accountId: int.tryParse(state.pathParameters["id"]!) ?? -1,
                ),
                fullscreenDialog: true,
              ),
        ),
        GoRoute(
          path: "transactions",
          builder:
              (context, state) => TransactionsPage.account(
                accountId: int.tryParse(state.pathParameters["id"]!) ?? -1,
                title: state.uri.queryParameters["title"],
              ),
        ),
      ],
    ),
    GoRoute(
      path: "/category/new",
      builder: (context, state) => const CategoryEditPage.create(),
    ),
    GoRoute(
      path: "/category/:id",
      builder:
          (context, state) => CategoryPage(
            categoryId: int.tryParse(state.pathParameters["id"]!) ?? -1,
            initialRange: TimeRange.tryParse(
              state.uri.queryParameters["range"] ?? "",
            ),
          ),
      routes: [
        GoRoute(
          path: "edit",
          pageBuilder:
              (context, state) => MaterialPage(
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
      path: "/accounts",
      builder: (context, state) => const AccountsPage(),
    ),
    GoRoute(
      path: "/preferences",
      builder: (context, state) => const PreferencesPage(),
      routes: [
        GoRoute(
          path: "pendingTransactions",
          builder:
              (context, state) => const PendingTransactionPreferencesPage(),
        ),
        GoRoute(
          path: "numpad",
          builder: (context, state) => const NumpadPreferencesPage(),
        ),
        GoRoute(
          path: "trashBin",
          builder: (context, state) => const TrashBinPreferencesPage(),
        ),
        GoRoute(
          path: "transfer",
          builder: (context, state) => const TransferPreferencesPage(),
        ),
        GoRoute(
          path: "reminders",
          builder: (context, state) => const RemindersPreferencesPage(),
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
          path: "moneyFormatting",
          builder: (context, state) => const MoneyFormattingPreferencesPage(),
        ),
        GoRoute(
          path: "sync",
          builder: (context, state) => const SyncPreferencesPage(),
        ),
        GoRoute(
          path: "transactionListItemAppearance",
          builder:
              (context, state) =>
                  const TransactionListItemAppearancePreferencesPage(),
        ),
      ],
    ),
    GoRoute(path: "/profile", builder: (context, state) => const ProfilePage()),
    GoRoute(
      path: "/profile/:id",
      builder:
          (context, state) => ProfilePage(
            profileId: int.tryParse(state.pathParameters["id"]!) ?? -1,
          ),
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
          _ =>
            throw const ErrorPage(
              error:
                  "Invalid state. Pass [CropSquareImagePageProps] object to `extra` prop",
            ),
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
          _ =>
            throw const ErrorPage(
              error:
                  "Invalid state. Pass [EditMarkdownPageProps] object or nothing to `extra` prop",
            ),
        };
      },
    ),
    GoRoute(
      path: "/exportOptions",
      builder: (context, state) => const ExportOptionsPage(),
    ),
    GoRoute(
      path: "/import",
      builder: (context, state) {
        return ImportPage(
          setupMode: state.uri.queryParameters["setupMode"] == "true",
        );
      },
    ),
    GoRoute(
      path: "/import/wizard/v1",
      builder: (context, state) {
        if (state.extra case ImportV1 importV1) {
          return ImportWizardV1Page(
            importer: importV1,
            setupMode: state.uri.queryParameters["setupMode"] == "true",
          );
        }

        return ErrorPage(error: "error.sync.invalidBackupFile".t(context));
      },
    ),
    GoRoute(
      path: "/import/wizard/v2",
      builder: (context, state) {
        if (state.extra case ImportV2 importV2) {
          return ImportWizardV2Page(
            importer: importV2,
            setupMode: state.uri.queryParameters["setupMode"] == "true",
          );
        }

        return ErrorPage(error: "error.sync.invalidBackupFile".t(context));
      },
    ),
    GoRoute(
      path: "/import/wizard/csv",
      builder: (context, state) {
        if (state.extra case ImportCSV importCSV) {
          return ImportWizardCSVPage(
            importer: importCSV,
            setupMode: state.uri.queryParameters["setupMode"] == "true",
          );
        }

        return ErrorPage(error: "error.sync.invalidBackupFile".t(context));
      },
    ),
    GoRoute(
      path: "/export/history",
      builder: (context, state) => const ExportHistoryPage(),
    ),
    GoRoute(
      path: "/export/:type",
      builder:
          (context, state) => ExportPage(
            ExportMode.tryParse(state.pathParameters["type"] ?? "zip") ??
                ExportMode.zip,
          ),
    ),
    GoRoute(
      path: "/import",
      builder:
          (context, state) => ImportPage(
            setupMode: state.uri.queryParameters["setupMode"] == "true",
          ),
    ),
    GoRoute(
      path: "/setup",
      builder: (context, state) => const SetupPage(),
      routes: [
        GoRoute(
          path: "choose",
          builder: (context, state) => const SetupOnboardingPage(),
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
          builder:
              (context, state) => SetupCategoriesPage(
                standalone: state.uri.queryParameters["standalone"] == "true",
                selectAll: state.uri.queryParameters["selectAll"] != "false",
              ),
        ),
        GoRoute(
          path: "profile",
          builder: (context, state) => const SetupProfilePage(),
        ),
        GoRoute(
          path: "profile/photo",
          builder:
              (context, state) => SetupProfilePhotoPage(
                profileImagePath: state.extra as String,
              ),
        ),
      ],
    ),
    GoRoute(path: "/support", builder: (context, state) => const SupportPage()),
    GoRoute(
      path: "/stats/category",
      builder: (context, state) {
        final TimeRange? initialRange = TimeRange.tryParse(
          state.uri.queryParameters["range"] ?? "",
        );

        return StatsByGroupPage(byCategory: true, initialRange: initialRange);
      },
    ),
    GoRoute(
      path: "/stats/account",
      builder: (context, state) {
        final TimeRange? initialRange = TimeRange.tryParse(
          state.uri.queryParameters["range"] ?? "",
        );

        return StatsByGroupPage(byCategory: false, initialRange: initialRange);
      },
    ),
    GoRoute(
      path: "/_debug/theme",
      builder: (context, state) => DebugThemePage(),
    ),
    GoRoute(
      path: "/_debug/scheduledNotifications",
      builder: (context, state) => DebugScheduledNotificationsPage(),
    ),
    GoRoute(path: "/_debug/logs", builder: (context, state) => DebugLogsPage()),
    GoRoute(
      path: "/_debug/logs/view",
      builder: (context, state) {
        if (state.extra case String path) {
          return DebugLogPage(path: path);
        }

        return ErrorPage(error: "Provide path as route extra");
      },
    ),
  ],
);
