import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'ui_helpers.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final auth = context.read<AuthProvider>();
        final ok = await confirm(
          context,
          title: 'Log out',
          message: 'Are you sure you want to log out?',
          confirmLabel: 'Log out',
        );
        if (ok) await auth.logout();
      },
      icon: const Icon(Icons.logout),
      label: const Text('Log out'),
    );
  }
}
