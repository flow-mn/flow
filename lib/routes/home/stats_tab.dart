import 'dart:convert';

import 'package:flow/data/money_flow.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/actions.dart';
import 'package:flow/widgets/general/spinner.dart';
import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab>
    with AutomaticKeepAliveClientMixin {
  final DateTime from = DateTime.fromMillisecondsSinceEpoch(0);
  final DateTime to =
      DateTime.now().add(const Duration(days: 7)).startOfLocalWeek();
  // final DateTime from = DateTime.now().startOfLocalWeek();
  // final DateTime to =
  //     DateTime.now().add(const Duration(days: 7)).startOfLocalWeek();

  late final Future<Map<String, MoneyFlow>> categoriesFlow =
      ObjectBox().flowByCategories(from: from, to: to);
  late final Future<Map<String, MoneyFlow>> accountsFlow =
      ObjectBox().flowByAccounts(from: from, to: to);

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          FutureBuilder(
            future: categoriesFlow,
            builder: (context, snapshot) => snapshot.data == null
                ? const Spinner()
                : Text(
                    jsonEncode(
                      snapshot.data!.map(
                        (key, value) => MapEntry(key, value.flow),
                      ),
                    ),
                  ),
          ),
          FutureBuilder(
            future: accountsFlow,
            builder: (context, snapshot) => snapshot.data == null
                ? const Spinner()
                : Text(
                    jsonEncode(
                      snapshot.data!.map(
                        (key, value) => MapEntry(key, value.flow),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
