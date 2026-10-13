import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/dashboard_widgets.dart';
import '../../widgets/shell_scaffold.dart';

class CaregiverHomeScreen extends StatelessWidget {
  const CaregiverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthProvider>().session!;
    final shell = ShellScope.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GreetingHeader(name: session.name, subtitle: 'Your caregiver dashboard',
          icon: Icons.medical_services_rounded),
        const SizedBox(height: 22),
        const SectionLabel('Quick actions'),
        DashboardGrid(
          children: [
            DashboardCard(
              icon: Icons.work_rounded,
              title: 'My Job Requests',
              description: 'Check incoming care requests and accept new patients.',
              color: const Color(0xFF10B981),
              badge: 'New Requests',
              onTap: () => shell.select(1),
            ),
            DashboardCard(
              icon: Icons.monitor_heart_rounded,
              title: 'Patient Progress',
              description: 'Log daily observations and track vital signs.',
              color: const Color(0xFFF59E0B),
              badge: 'Daily Log',
              onTap: () => shell.select(2),
            ),
            DashboardCard(
              icon: Icons.badge_rounded,
              title: 'Profile',
              description: 'View and update your caregiver profile details.',
              color: const Color(0xFF3B5BFD),
              badge: 'Active Profile',
              onTap: () => shell.select(3),
            ),
          ],
        ),
      ],
    );
  }
}
