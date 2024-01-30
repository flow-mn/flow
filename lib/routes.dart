import 'package:flow/routes/account_page.dart';
import 'package:flow/routes/categories_page.dart';
import 'package:flow/routes/category_page.dart';
import 'package:flow/routes/home_page.dart';
import 'package:flow/routes/preferences/numpad_preferences_page.dart';
import 'package:flow/routes/profile_page.dart';
import 'package:flow/routes/setup/setup_page.dart';
import 'package:flow/routes/transaction_page.dart';
import 'package:flow/routes/preferences_page.dart';
import 'package:flow/routes/utils/crop_square_image_page.dart';
import 'package:flutter/material.dart';
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
      builder: (context, state) =>
          (state.extra == null || state.extra is! Image)
              ? throw "Invalid state. Pass [Image] object to `extra` prop"
              : CropSquareImagePage(image: state.extra as Image),
    ),
    GoRoute(
      path: '/setup',
      builder: (context, state) => const SetupPage(),
    ),
  ],
);
