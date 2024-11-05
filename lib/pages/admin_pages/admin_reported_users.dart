import 'package:flutter/material.dart';

class ReportedUsersPage extends StatelessWidget {
  const ReportedUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Reported Users'),
        actions: [],
      ),
      body: Center(),
    );
  }
}
