import 'package:flutter/material.dart';

class SetupAccountsPage extends StatefulWidget {
  const SetupAccountsPage({super.key});

  @override
  State<SetupAccountsPage> createState() => _SetupAccountsPageState();
}

class _SetupAccountsPageState extends State<SetupAccountsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const SafeArea(
        child: Column(),
      ),
    );
  }
}
