import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/dashboard_widgets.dart';
import '../../widgets/shell_scaffold.dart';

class FamilyHomeScreen extends StatelessWidget {
  const FamilyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthProvider>().session!;
    final shell = ShellScope.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GreetingHeader(name: session.name, subtitle: 'Quick access',
          icon: Icons.family_restroom_rounded),
        const SizedBox(height: 22),
        const SectionLabel('Quick actions'),
        DashboardGrid(
          children: [
            DashboardCard(
              icon: Icons.volunteer_activism_rounded,
              title: 'My Patient',
              description: 'View patient info and status.',
              color: const Color(0xFFF43F5E),
              onTap: () => shell.select(1),
            ),
            DashboardCard(
              icon: Icons.manage_accounts_rounded,
              title: 'Profile',
              description: 'Manage your account settings.',
              color: const Color(0xFF3B5BFD),
              onTap: () => shell.select(2),
            ),
          ],
        ),
      ],
    );
  }
}
