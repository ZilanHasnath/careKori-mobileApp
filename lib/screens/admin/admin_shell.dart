import 'package:flutter/material.dart';

import '../../widgets/shell_scaffold.dart';
import 'admin_account_screen.dart';
import 'admin_jobs_screen.dart';
import 'admin_overview_screen.dart';
import 'admin_people_screen.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ShellScaffold(
      tabs: [
        ShellTab(
          label: 'Overview',
          title: 'Admin Dashboard',
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          builder: (_) => const AdminOverviewScreen(),
        ),
        ShellTab(
          label: 'People',
          icon: Icons.groups_outlined,
          selectedIcon: Icons.groups,
          builder: (_) => const AdminPeopleScreen(),
        ),
        ShellTab(
          label: 'Jobs',
          icon: Icons.work_outline,
          selectedIcon: Icons.work,
          builder: (_) => const AdminJobsScreen(),
        ),
        ShellTab(
          label: 'Account',
          icon: Icons.admin_panel_settings_outlined,
          selectedIcon: Icons.admin_panel_settings,
          builder: (_) => const AdminAccountScreen(),
        ),
      ],
    );
  }
}
