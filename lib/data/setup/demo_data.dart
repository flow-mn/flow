import "dart:math";

import "package:flow/data/flow_icon.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction_tag.dart";
import "package:flow/objectbox/actions.dart";
import "package:flutter/widgets.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:uuid/uuid.dart";

/// Generates a rich, realistic multi-year financial history for demo and
/// screenshot purposes.
///
/// Unlike a fixture, this is intentionally **non-deterministic** — every run
/// produces a different (but plausible) history. Pass a seeded [Random] if you
/// ever need reproducible output (e.g. for golden tests).
///
/// The simulation walks the timeline day-by-day so that running balances stay
/// positive and savings grow over time. Regular income/expense transactions
/// are accumulated and returned for a single batch insert via
/// [Box.putManyAsync], while money movements between accounts (monthly savings,
/// credit-card payoff, ATM withdrawals) are written immediately through
/// [AccountActions.transferTo].
///
/// Usage:
/// ```dart
/// final generator = DemoDataGenerator(
///   main: main, cash: cash, savings: savings, creditCard: creditCard,
///   categories: categories, tags: tagsByTitle,
/// );
/// await box<Transaction>().putManyAsync(generator.generate());
/// ```
class DemoDataGenerator {
  DemoDataGenerator({
    required this.main,
    required this.cash,
    required this.savings,
    required this.creditCard,
    required List<Category> categories,
    required Map<String, TransactionTag> tags,
    Random? random,
    DateTime? now,
    this.years = 3,
  }) : rng = random ?? Random(),
       _tags = tags,
       end = now ?? DateTime.now() {
    _categories = _resolveCategories(categories);
  }

  final Account main;
  final Account cash;
  final Account savings;
  final Account creditCard;

  final Map<String, TransactionTag> _tags;
  final Random rng;
  final DateTime end;

  /// How many years of history to generate, counting back from [end].
  final int years;

  late final Map<String, Category> _categories;
  late final DateTime _start;

  /// Net monthly take-home pay at the very start of the timeline. Grows yearly.
  ///
  /// Set a little above total monthly spending so the checking balance never
  /// underflows, while leaving a believable ~20% to save.
  static const double _baseSalary = 4400;

  /// Compounding annual raise applied to [_baseSalary].
  static const double _annualRaise = 0.06;

  /// Minimum balance we try to leave in [main] before moving money out. Large
  /// enough to cover the month's direct spending (rent lands on the 1st, salary
  /// only on the 25th) so transfers never push the account negative.
  static const double _buffer = 1800;

  /// On payday, anything in [main] above this is swept into savings, so the
  /// checking balance stays in a realistic band instead of ballooning as the
  /// surplus accumulates over the years.
  static const double _checkingCap = 6500;

  final List<Transaction> _txns = [];
  final Map<String, double> _balances = {};

  late final Set<String> _tripDays;

  /// Builds the full history. Returns the regular (non-transfer) transactions
  /// to be inserted in one batch. Transfers are persisted as a side effect.
  List<Transaction> generate() {
    _start = DateTime(end.year - years, end.month, end.day);

    _seedInitialBalances();
    _planTrips();

    DateTime cursor = _start;
    while (cursor.isBefore(end)) {
      _runDay(cursor);
      cursor = cursor.add(const Duration(days: 1));
    }

    return _txns;
  }

  // ---------------------------------------------------------------------------
  // Setup
  // ---------------------------------------------------------------------------

  /// Maps a semantic key to the preset category's icon, so we can resolve the
  /// persisted [Category] regardless of its (localized) name.
  static const Map<String, IconData> _categoryIcons = {
    "eatingOut": Symbols.restaurant_rounded,
    "groceries": Symbols.grocery_rounded,
    "drinks": Symbols.local_cafe_rounded,
    "education": Symbols.school_rounded,
    "health": Symbols.health_and_safety_rounded,
    "transport": Symbols.train_rounded,
    "petrol": Symbols.local_gas_station_rounded,
    "shopping": Symbols.shopping_cart_rounded,
    "entertainment": Symbols.sports_basketball_rounded,
    "onlineServices": Symbols.cloud_circle_rounded,
    "gifts": Symbols.featured_seasonal_and_gifts_rounded,
    "rent": Symbols.request_quote_rounded,
    "utils": Symbols.valve_rounded,
    "taxes": Symbols.account_balance_rounded,
    "paychecks": Symbols.wallet_rounded,
    "insurance": Symbols.privacy_tip_rounded,
    "petCare": Symbols.pets_rounded,
    "fitness": Symbols.fitness_center_rounded,
    "gadgets": Symbols.devices_other_rounded,
    "services": Symbols.support_agent_rounded,
    "snacks": Symbols.bakery_dining_rounded,
    "stationery": Symbols.note_stack_rounded,
    "hobby": Symbols.sports_esports_rounded,
    "donations": Symbols.volunteer_activism_rounded,
    "beauty": Symbols.self_care_rounded,
    "travel": Symbols.flight_rounded,
  };

  Map<String, Category> _resolveCategories(List<Category> categories) {
    final Map<String, Category> byCode = {
      for (final category in categories) category.iconCode: category,
    };

    final Map<String, Category> result = {};
    _categoryIcons.forEach((key, icon) {
      final Category? match = byCode[IconFlowIcon(icon).toString()];
      if (match != null) result[key] = match;
    });
    return result;
  }

  void _seedInitialBalances() {
    _income(
      account: main,
      amount: 6000,
      date: _start,
      title: "Initial balance",
      subtype: TransactionSubtype.updateBalance.value,
    );
    _income(
      account: cash,
      amount: 120,
      date: _start,
      title: "Initial balance",
      subtype: TransactionSubtype.updateBalance.value,
    );
    _income(
      account: savings,
      amount: 8500,
      date: _start,
      title: "Initial balance",
      subtype: TransactionSubtype.updateBalance.value,
    );
  }

  /// Pre-picks 1–2 trips per year (a summer trip, sometimes a winter getaway)
  /// so they land as recognizable spending spikes.
  void _planTrips() {
    _tripDays = {};
    for (int year = _start.year; year <= end.year; year++) {
      final DateTime summer = DateTime(year, 7 + rng.nextInt(2), 1 + rng.nextInt(20));
      if (_within(summer)) _tripDays.add(_dayKey(summer));

      if (_chance(0.5)) {
        final DateTime winter = DateTime(year, 12, 18 + rng.nextInt(8));
        if (_within(winter)) _tripDays.add(_dayKey(winter));
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Per-day simulation
  // ---------------------------------------------------------------------------

  void _runDay(DateTime day) {
    final bool weekend =
        day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
    final int dom = day.day;

    _runRecurring(day);

    if (dom == 25) _runPayday(day);
    if (dom == 5) _runCreditCardPayoff(day);
    if (dom == 7 || dom == 21) _maybeTopUpCash(day);

    if (_tripDays.contains(_dayKey(day))) _runTrip(day);

    // December gift shopping
    if (day.month == 12 && dom <= 24 && _chance(0.26)) {
      _spend(
        amount: _money(18, 180),
        date: _at(day),
        categoryKey: "gifts",
        title: _pick(_giftTitles),
        tagKeys: const ["gifts", "family"],
        prefer: _cardOr(main, 0.8),
      );
    }

    // Coffee
    if (_chance(weekend ? 0.42 : 0.58)) {
      _spend(
        amount: _money(3.25, 6.75),
        date: _at(day),
        categoryKey: "drinks",
        title: _pick(_coffeeTitles),
        tagKeys: _chance(0.4) ? const ["coffee"] : const [],
        prefer: _chance(0.6) ? [cash, main] : [main],
      );
    }

    // Groceries
    if (_chance(weekend ? 0.42 : 0.18)) {
      _spend(
        amount: _money(16, 96),
        date: _at(day),
        categoryKey: "groceries",
        title: _pick(_groceryTitles),
        tagKeys: _chance(0.3) ? const ["groceries"] : const [],
        prefer: _cardOr(main, 0.4),
      );
    }

    // Eating out
    if (_chance(weekend ? 0.5 : 0.22)) {
      _spend(
        amount: _money(10, 56),
        date: _at(day),
        categoryKey: "eatingOut",
        title: _pick(_diningTitles),
        tagKeys: weekend && _chance(0.4)
            ? const ["dining", "friends"]
            : const ["dining"],
        prefer: _chance(0.5)
            ? [cash, main]
            : (_chance(0.5) ? [creditCard, main] : [main]),
      );
    }

    // Snacks
    if (_chance(0.18)) {
      _spend(
        amount: _money(2, 12),
        date: _at(day),
        categoryKey: "snacks",
        title: _pick(_snackTitles),
        prefer: [cash, main],
      );
    }

    // Transport
    if (_chance(weekend ? 0.2 : 0.5)) {
      _spend(
        amount: _money(2.5, 16),
        date: _at(day),
        categoryKey: "transport",
        title: _pick(_transportTitles),
        tagKeys: const ["transport"],
        prefer: [cash, main],
      );
    }

    // Petrol (~ every 12 days)
    if (_chance(0.08)) {
      _spend(
        amount: _money(34, 62),
        date: _at(day),
        categoryKey: "petrol",
        title: _pick(_petrolTitles),
        prefer: _cardOr(main, 0.5),
      );
    }

    // Entertainment
    if (_chance(weekend ? 0.28 : 0.06)) {
      _spend(
        amount: _money(8, 60),
        date: _at(day),
        categoryKey: "entertainment",
        title: _pick(_entertainmentTitles),
        tagKeys: _chance(0.3) ? const ["fun"] : const [],
        prefer: _cardOr(main, 0.5),
      );
    }

    // Shopping
    if (_chance(0.1)) {
      _spend(
        amount: _money(14, 185),
        date: _at(day),
        categoryKey: "shopping",
        title: _pick(_shoppingTitles),
        tagKeys: _chance(0.5) ? const ["online"] : const [],
        prefer: _cardOr(main, 0.8),
      );
    }

    // Health
    if (_chance(0.025)) {
      _spend(
        amount: _money(8, 65),
        date: _at(day),
        categoryKey: "health",
        title: _pick(_healthTitles),
        tagKeys: const ["health"],
        prefer: [main],
      );
    }

    // Beauty / grooming
    if (_chance(0.035)) {
      _spend(
        amount: _money(12, 70),
        date: _at(day),
        categoryKey: "beauty",
        title: _pick(_beautyTitles),
        prefer: [main],
      );
    }

    // Hobby
    if (_chance(0.06)) {
      _spend(
        amount: _money(10, 80),
        date: _at(day),
        categoryKey: "hobby",
        title: _pick(_hobbyTitles),
        tagKeys: _chance(0.3) ? const ["fun"] : const [],
        prefer: _chance(0.5) ? [cash, main] : [main],
      );
    }

    // Pet care
    if (_chance(0.03)) {
      _spend(
        amount: _money(11, 85),
        date: _at(day),
        categoryKey: "petCare",
        title: _pick(_petTitles),
        tagKeys: const ["pets"],
        prefer: [main],
      );
    }

    // Stationery / office
    if (_chance(0.015)) {
      _spend(
        amount: _money(5, 40),
        date: _at(day),
        categoryKey: "stationery",
        title: _pick(_stationeryTitles),
        prefer: [main],
      );
    }

    // Education
    if (_chance(0.012)) {
      _spend(
        amount: _money(15, 200),
        date: _at(day),
        categoryKey: "education",
        title: _pick(_educationTitles),
        prefer: _cardOr(main, 0.5),
      );
    }

    // Gadgets
    if (_chance(0.005)) {
      _spend(
        amount: _money(80, 1300),
        date: _at(day),
        categoryKey: "gadgets",
        title: _pick(_gadgetTitles),
        tagKeys: const ["gadgets"],
        prefer: _cardOr(main, 0.85),
      );
    }

    // Rare big-ticket purchase, occasionally pulled from savings
    if (_chance(0.0015) && _bal(savings) > 3500) {
      final double amount = _money(600, 2400);
      _transfer(
        from: savings,
        to: main,
        amount: amount,
        date: _at(day),
        title: "From savings",
      );
      _spend(
        amount: amount * _rand(0.6, 0.95),
        date: _at(day),
        categoryKey: _chance(0.5) ? "gadgets" : "shopping",
        title: _pick(_bigPurchaseTitles),
        prefer: [main],
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Recurring & money movements
  // ---------------------------------------------------------------------------

  void _runRecurring(DateTime day) {
    final int dom = day.day;
    final int month = day.month;

    // Subscriptions (charged to the credit card)
    if (dom == 1) {
      _spend(
        amount: 39.00,
        date: _at(day),
        categoryKey: "fitness",
        title: "Gym membership",
        tagKeys: const ["subscription", "health"],
        prefer: _cardOr(main, 0.9),
      );
    }
    if (dom == 2) {
      _spend(
        amount: 2.99,
        date: _at(day),
        categoryKey: "onlineServices",
        title: "iCloud+",
        tagKeys: const ["subscription"],
        prefer: _cardOr(main, 0.9),
      );
    }
    if (dom == 5) {
      _spend(
        amount: _netflixPrice(day),
        date: _at(day),
        categoryKey: "onlineServices",
        title: "Netflix",
        tagKeys: const ["subscription"],
        prefer: _cardOr(main, 0.9),
      );
    }
    if (dom == 9) {
      _spend(
        amount: 11.99,
        date: _at(day),
        categoryKey: "onlineServices",
        title: "Spotify",
        tagKeys: const ["subscription"],
        prefer: _cardOr(main, 0.9),
      );
    }
    if (dom == 12) {
      _spend(
        amount: 20.00,
        date: _at(day),
        categoryKey: "onlineServices",
        title: "ChatGPT Plus",
        tagKeys: const ["subscription"],
        prefer: _cardOr(main, 0.9),
      );
    }

    // Bills (paid from the main account)
    if (dom == 1) {
      _spend(
        amount: _rentPrice(day),
        date: _at(day),
        categoryKey: "rent",
        title: "Rent",
        tagKeys: const ["bills"],
        prefer: [main],
      );
    }
    if (dom == 6) {
      _spend(
        amount: 59.00,
        date: _at(day),
        categoryKey: "utils",
        title: "Internet",
        tagKeys: const ["bills"],
        prefer: [main],
      );
    }
    if (dom == 18) {
      _spend(
        amount: _money(42, 52),
        date: _at(day),
        categoryKey: "utils",
        title: "Phone bill",
        tagKeys: const ["bills"],
        prefer: [main],
      );
    }
    if (dom == 20) {
      _spend(
        amount: _electricityPrice(day),
        date: _at(day),
        categoryKey: "utils",
        title: "Electricity",
        tagKeys: const ["bills"],
        prefer: [main],
      );
    }
    if (dom == 22) {
      _spend(
        amount: _money(22, 38),
        date: _at(day),
        categoryKey: "utils",
        title: "Water",
        tagKeys: const ["bills"],
        prefer: [main],
      );
    }

    // Quarterly car insurance
    if (dom == 14 && const [1, 4, 7, 10].contains(month)) {
      _spend(
        amount: _money(178, 214),
        date: _at(day),
        categoryKey: "insurance",
        title: "Car insurance",
        tagKeys: const ["bills"],
        prefer: [main],
      );
    }

    // Monthly donation
    if (dom == 10) {
      _spend(
        amount: _money(15, 45),
        date: _at(day),
        categoryKey: "donations",
        title: _pick(_donationTitles),
        tagKeys: const ["charity"],
        prefer: [main],
      );
    }

    // Monthly savings interest (~3.5% APY)
    if (dom == 28) {
      final double interest = _bal(savings) * 0.035 / 12;
      if (interest > 1) {
        _income(
          account: savings,
          amount: interest,
          date: _at(day),
          title: "Interest",
        );
      }
    }

    // Annual tax refund (late March)
    if (month == 3 && dom == 27) {
      _income(
        account: main,
        amount: _money(320, 1380),
        date: _at(day),
        categoryKey: "taxes",
        title: "Tax refund",
      );
    }
  }

  void _runPayday(DateTime day) {
    final double yearsElapsed = day.difference(_start).inDays / 365.0;
    final double salary =
        _baseSalary * pow(1 + _annualRaise, yearsElapsed) * _rand(0.985, 1.015);

    _income(
      account: main,
      amount: salary,
      date: _at(day),
      categoryKey: "paychecks",
      title: "Salary",
      tagKeys: const ["work"],
    );

    // Year-end bonus
    double savingsTarget = salary * 0.15;
    if (day.month == 12) {
      final double bonus = salary * _rand(0.8, 1.3);
      _income(
        account: main,
        amount: bonus,
        date: _at(day),
        categoryKey: "paychecks",
        title: "Year-end bonus",
        tagKeys: const ["work"],
      );
      savingsTarget += bonus * 0.5;
    }

    // Occasional freelance income
    if (_chance(0.3)) {
      _income(
        account: main,
        amount: _money(220, 940),
        date: _at(day),
        categoryKey: "services",
        title: _pick(_freelanceTitles),
        tagKeys: const ["work", "reimbursable"],
      );
    }

    // Pay yourself first — a fixed monthly contribution into savings.
    _transfer(
      from: main,
      to: savings,
      amount: min(savingsTarget, _bal(main) - _buffer),
      date: _at(day),
      title: "Monthly savings",
    );

    // Sweep any excess checking into savings so the balance stays realistic.
    if (_bal(main) > _checkingCap) {
      _transfer(
        from: main,
        to: savings,
        amount: _bal(main) - _checkingCap,
        date: _at(day),
        title: "Top up savings",
      );
    }
  }

  void _runCreditCardPayoff(DateTime day) {
    final double owed = -_bal(creditCard);
    if (owed <= 0) return;

    // Pay what we can without dipping below the buffer; the rest revolves.
    _transfer(
      from: main,
      to: creditCard,
      amount: min(owed, _bal(main) - _buffer),
      date: _at(day),
      title: "Credit card payment",
    );
  }

  void _maybeTopUpCash(DateTime day) {
    if (_bal(cash) >= 100) return;

    final double amount = (_money(100, 220) / 20).roundToDouble() * 20;
    _transfer(
      from: main,
      to: cash,
      amount: amount,
      date: _at(day),
      title: "ATM withdrawal",
    );
  }

  void _runTrip(DateTime day) {
    // Outbound flight
    _spend(
      amount: _money(160, 520),
      date: _at(day),
      categoryKey: "travel",
      title: "Flight",
      tagKeys: const ["vacation"],
      prefer: _cardOr(main, 0.9),
    );

    final int nights = 2 + rng.nextInt(4);
    for (int i = 0; i < nights; i++) {
      final DateTime night = day.add(Duration(days: i));
      if (!_within(night)) break;

      _spend(
        amount: _money(95, 260),
        date: _at(night),
        categoryKey: "travel",
        title: "Hotel",
        tagKeys: const ["vacation"],
        prefer: _cardOr(main, 0.9),
      );

      if (_chance(0.8)) {
        _spend(
          amount: _money(18, 80),
          date: _at(night),
          categoryKey: _chance(0.6) ? "eatingOut" : "entertainment",
          title: _chance(0.6) ? _pick(_diningTitles) : _pick(_entertainmentTitles),
          tagKeys: const ["vacation"],
          prefer: _cardOr(main, 0.8),
        );
      }
    }

    // Return flight
    final DateTime back = day.add(Duration(days: nights));
    if (_within(back)) {
      _spend(
        amount: _money(160, 520),
        date: _at(back),
        categoryKey: "travel",
        title: "Flight",
        tagKeys: const ["vacation"],
        prefer: _cardOr(main, 0.9),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Emit helpers
  // ---------------------------------------------------------------------------

  void _spend({
    required double amount,
    required DateTime date,
    required String categoryKey,
    String? title,
    List<String> tagKeys = const [],
    List<Account> prefer = const [],
  }) {
    final Account account = _pickSpendAccount(
      prefer.isEmpty ? [main] : prefer,
      amount,
    );
    _emit(
      account: account,
      amount: -amount,
      date: date,
      title: title,
      categoryKey: categoryKey,
      tagKeys: tagKeys,
    );
  }

  void _income({
    required Account account,
    required double amount,
    required DateTime date,
    String? title,
    String? categoryKey,
    List<String> tagKeys = const [],
    String? subtype,
  }) {
    _emit(
      account: account,
      amount: amount,
      date: date,
      title: title,
      categoryKey: categoryKey,
      tagKeys: tagKeys,
      subtype: subtype,
    );
  }

  void _emit({
    required Account account,
    required double amount,
    required DateTime date,
    String? title,
    String? categoryKey,
    List<String> tagKeys = const [],
    String? subtype,
  }) {
    if (date.isAfter(end)) return;

    final Transaction transaction =
        Transaction(
            uuid: const Uuid().v4(),
            amount: double.parse(amount.toStringAsFixed(2)),
            currency: account.currency,
            title: title,
            transactionDate: date,
            subtype: subtype,
          )
          ..setAccount(account)
          ..setCategory(categoryKey == null ? null : _categories[categoryKey]);

    final List<TransactionTag> resolvedTags = [
      for (final key in tagKeys)
        if (_tags[key] != null) _tags[key]!,
    ];
    if (resolvedTags.isNotEmpty) transaction.setTags(resolvedTags);

    _txns.add(transaction);
    _apply(account, transaction.amount);
  }

  void _transfer({
    required Account from,
    required Account to,
    required double amount,
    required DateTime date,
    String? title,
  }) {
    if (date.isAfter(end)) return;

    final double rounded = double.parse(amount.toStringAsFixed(2));
    if (rounded <= 0) return;

    from.transferTo(
      amount: rounded,
      targetAccount: to,
      transactionDate: date,
      title: title,
    );

    _apply(from, -rounded);
    _apply(to, rounded);
  }

  /// Picks the first preferred account that can cover [amount], falling back to
  /// [main] (which is always topped up by the salary).
  Account _pickSpendAccount(List<Account> prefer, double amount) {
    for (final account in prefer) {
      if (identical(account, creditCard)) {
        final double owed = -_bal(creditCard);
        final double limit = creditCard.creditLimit ?? 5000;
        if (owed + amount <= limit * 0.92) return account;
      } else if (identical(account, cash) || identical(account, savings)) {
        if (_bal(account) >= amount) return account;
      } else {
        return account;
      }
    }
    return main;
  }

  // ---------------------------------------------------------------------------
  // Balance bookkeeping
  // ---------------------------------------------------------------------------

  double _bal(Account account) => _balances[account.uuid] ?? 0;

  void _apply(Account account, double delta) {
    _balances[account.uuid] = _bal(account) + delta;
  }

  // ---------------------------------------------------------------------------
  // Pricing curves
  // ---------------------------------------------------------------------------

  double _netflixPrice(DateTime day) =>
      day.difference(_start).inDays > 600 ? 17.99 : 15.49;

  double _rentPrice(DateTime day) {
    final int elapsed = day.difference(_start).inDays;
    if (elapsed > 730) return 1690;
    if (elapsed > 365) return 1590;
    return 1480;
  }

  double _electricityPrice(DateTime day) {
    double base = 52;
    final int month = day.month;
    if (month == 12 || month == 1 || month == 2) base += 46; // winter heating
    if (month == 7 || month == 8) base += 34; // summer cooling
    return _money(base - 12, base + 16);
  }

  // ---------------------------------------------------------------------------
  // Randomness utilities
  // ---------------------------------------------------------------------------

  double _rand(double min, double max) => min + rng.nextDouble() * (max - min);

  double _money(double min, double max) =>
      double.parse(_rand(min, max).toStringAsFixed(2));

  bool _chance(double probability) => rng.nextDouble() < probability;

  T _pick<T>(List<T> items) => items[rng.nextInt(items.length)];

  /// A spending preference list that uses the credit card [cardProbability] of
  /// the time, otherwise the given [fallback] account.
  List<Account> _cardOr(Account fallback, double cardProbability) =>
      _chance(cardProbability) ? [creditCard, fallback] : [fallback];

  DateTime _at(DateTime day) => DateTime(
    day.year,
    day.month,
    day.day,
    7 + rng.nextInt(15),
    rng.nextInt(60),
    rng.nextInt(60),
  );

  bool _within(DateTime day) => !day.isBefore(_start) && day.isBefore(end);

  String _dayKey(DateTime day) => "${day.year}-${day.month}-${day.day}";

  // ---------------------------------------------------------------------------
  // Title pools
  // ---------------------------------------------------------------------------

  static const List<String> _coffeeTitles = [
    "Latte",
    "Cappuccino",
    "Iced mocha",
    "Flat white",
    "Cold brew",
    "Americano",
    "Espresso",
    "Matcha latte",
    "Chai latte",
  ];

  static const List<String> _groceryTitles = [
    "Groceries",
    "Supermarket",
    "Whole Foods",
    "Trader Joe's",
    "Costco",
    "Corner store",
    "Farmers market",
  ];

  static const List<String> _diningTitles = [
    "Lunch",
    "Dinner",
    "Brunch",
    "Pizza",
    "Sushi",
    "Burger joint",
    "Thai food",
    "Ramen",
    "Tacos",
    "Sandwich",
    "Noodles",
    "Dumplings",
  ];

  static const List<String> _snackTitles = [
    "Snack",
    "Convenience store",
    "Bakery",
    "Ice cream",
    "Smoothie",
    "Donut",
  ];

  static const List<String> _transportTitles = [
    "Subway",
    "Bus fare",
    "Uber",
    "Lyft",
    "Taxi",
    "Parking",
    "Train ticket",
  ];

  static const List<String> _petrolTitles = [
    "Gas station",
    "Fuel",
    "Shell",
    "Chevron",
  ];

  static const List<String> _entertainmentTitles = [
    "Movie tickets",
    "Concert",
    "Bar",
    "Bowling",
    "Mini golf",
    "Arcade",
    "Comedy show",
    "Museum",
  ];

  static const List<String> _shoppingTitles = [
    "Amazon order",
    "Clothes",
    "Sneakers",
    "Uniqlo",
    "Zara",
    "Target run",
    "Home goods",
    "IKEA",
    "H&M",
  ];

  static const List<String> _healthTitles = [
    "Pharmacy",
    "Doctor visit",
    "Dentist",
    "Vitamins",
    "Prescription",
    "Clinic",
  ];

  static const List<String> _beautyTitles = [
    "Haircut",
    "Salon",
    "Skincare",
    "Barber",
    "Nails",
    "Spa",
  ];

  static const List<String> _hobbyTitles = [
    "Art supplies",
    "Climbing gym",
    "Board game",
    "Guitar strings",
    "Camera gear",
    "Pottery class",
    "Bookstore",
  ];

  static const List<String> _educationTitles = [
    "Online course",
    "Udemy course",
    "Workshop",
    "E-book",
    "Coursera",
  ];

  static const List<String> _petTitles = [
    "Pet food",
    "Vet visit",
    "Pet supplies",
    "Grooming",
    "Cat litter",
  ];

  static const List<String> _stationeryTitles = [
    "Stationery",
    "Notebook",
    "Pens",
    "Printer paper",
    "Desk supplies",
  ];

  static const List<String> _gadgetTitles = [
    "Headphones",
    "Mechanical keyboard",
    "Monitor",
    "Phone case",
    "Smartwatch",
    "SSD",
    "Webcam",
    "New phone",
  ];

  static const List<String> _giftTitles = [
    "Birthday gift",
    "Christmas gift",
    "Holiday present",
    "Gift for family",
    "Anniversary gift",
    "Wedding gift",
  ];

  static const List<String> _donationTitles = [
    "Red Cross",
    "Wikipedia",
    "Local shelter",
    "NPR",
    "Charity: water",
    "Patreon",
  ];

  static const List<String> _bigPurchaseTitles = [
    "New laptop",
    "Furniture",
    "Standing desk",
    "Mattress",
    "New TV",
    "Bicycle",
    "Vacuum cleaner",
  ];

  static const List<String> _freelanceTitles = [
    "Freelance project",
    "Side gig",
    "Consulting",
    "Design commission",
    "Web project",
  ];
}
