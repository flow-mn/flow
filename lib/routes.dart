import 'package:flow/l10n/extensions.dart';
import 'package:flow/routes/account_page.dart';
import 'package:flow/routes/categories_page.dart';
import 'package:flow/routes/category_page.dart';
import 'package:flow/routes/error_page.dart';
import 'package:flow/routes/export_options_page.dart';
import 'package:flow/routes/export_page.dart';
import 'package:flow/routes/home_page.dart';
import 'package:flow/routes/import_page.dart';
import 'package:flow/routes/import_wizard/v1.dart';
import 'package:flow/routes/preferences/numpad_preferences_page.dart';
import 'package:flow/routes/profile_page.dart';
import 'package:flow/routes/setup/setup_page.dart';
import 'package:flow/routes/transaction_page.dart';
import 'package:flow/routes/preferences_page.dart';
import 'package:flow/routes/transactions_page.dart';
import 'package:flow/routes/utils/crop_square_image_page.dart';
import 'package:flow/sync/export/mode.dart';
import 'package:flow/sync/import/import_v1.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/transaction/new',
      builder: (context, state) => const TransactionPage.create(),
    ),
    GoRoute(
      path: '/transaction/:id',
      builder: (context, state) => TransactionPage.edit(
        transactionId: int.tryParse(state.pathParameters["id"]!) ?? -1,
      ),
    ),
    GoRoute(
      path: '/account/new',
      builder: (context, state) => const AccountPage.create(),
    ),
    GoRoute(
      path: '/account/:id',
      builder: (context, state) => AccountPage.edit(
        accountId: int.tryParse(state.pathParameters["id"]!) ?? -1,
      ),
    ),
    GoRoute(
      path: '/account/:id/transactions',
      builder: (context, state) => TransactionsPage.account(
        accountId: int.tryParse(state.pathParameters["id"]!) ?? -1,
        title: state.uri.queryParameters["title"],
      ),
    ),
    GoRoute(
      path: '/category/new',
      builder: (context, state) => const CategoryPage.create(),
    ),
    GoRoute(
      path: '/category/:id',
      builder: (context, state) => CategoryPage.edit(
        categoryId: int.tryParse(state.pathParameters["id"]!) ?? -1,
      ),
    ),
    GoRoute(
      path: '/categories',
      builder: (context, state) => const CategoriesPage(),
    ),
    GoRoute(
      path: '/preferences',
      builder: (context, state) => const PreferencesPage(),
    ),
    GoRoute(
      path: '/preferences/numpad',
      builder: (context, state) => const NumpadPreferencesPage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/profile/:id',
      builder: (context, state) => ProfilePage(
          profileId: int.tryParse(state.pathParameters['id']!) ?? -1),
    ),
    GoRoute(
      path: '/utils/cropsquare',
      builder: (context, state) {
        return switch (state.extra) {
          CropSquareImagePageProps props => CropSquareImagePage(
              image: props.image,
              maxDimension: props.maxDimension,
              returnBitmap: props.returnBitmap,
            ),
          _ => throw const ErrorPage(
              error:
                  "Invalid state. Pass [CropSquareImagePageProps] object to `extra` prop",
            )
        };
      },
    ),
    GoRoute(
      path: '/exportOptions',
      builder: (context, state) => const ExportOptionsPage(),
    ),
    GoRoute(
      path: '/import',
      builder: (context, state) => const ImportPage(),
    ),
    GoRoute(
      path: '/import/wizard/v1',
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
      path: '/export/:type',
      builder: (context, state) => ExportPage(
        state.pathParameters["type"] == "csv"
            ? ExportMode.csv
            : ExportMode.json,
      ),
    ),
    GoRoute(
      path: '/import',
      builder: (context, state) => const ImportPage(),
    ),
    GoRoute(
      path: '/setup',
      builder: (context, state) => const SetupPage(),
    ),
  ],
);
