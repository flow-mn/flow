import 'package:flow/routes/account_page.dart';
import 'package:flow/routes/home_page.dart';
import 'package:flow/routes/transaction_page.dart';
import 'package:flow/routes/preferences_page.dart';
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
      path: '/preferences',
      builder: (context, state) => const PreferencesPage(),
    ),
  ],
);
