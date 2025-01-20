import 'package:Gamify/api/api_repo.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final googleSignInProvider = GoogleSignInProvider();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
      body:  Column(
        children: [
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Log Out'),
            onTap: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
              googleSignInProvider.signOut();
            },
          )
        ],
      ),
    );
  }
}
