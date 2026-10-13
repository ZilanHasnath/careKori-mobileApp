import 'package:flutter/material.dart';

import '../../widgets/shell_scaffold.dart';
import 'add_progress_screen.dart';
import 'caregiver_home_screen.dart';
import 'caregiver_jobs_screen.dart';
import 'caregiver_profile_screen.dart';

class CaregiverShell extends StatelessWidget {
  const CaregiverShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ShellScaffold(
      tabs: [
        ShellTab(
          label: 'Home',
          title: 'Dashboard',
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          builder: (_) => const CaregiverHomeScreen(),
        ),
        ShellTab(
          label: 'Jobs',
          icon: Icons.work_outline,
          selectedIcon: Icons.work,
          builder: (_) => const CaregiverJobsScreen(),
          reloadOnVisit: true,
        ),
        ShellTab(
          label: 'Add progress',
          icon: Icons.edit_note_outlined,
          selectedIcon: Icons.edit_note,
          builder: (_) => const AddProgressForm(),
          reloadOnVisit: true,
        ),
        ShellTab(
          label: 'Profile',
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          builder: (_) => const CaregiverProfileScreen(),
        ),
      ],
    );
  }
}
