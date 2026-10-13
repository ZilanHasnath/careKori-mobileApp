import 'package:flutter/material.dart';

import '../../widgets/shell_scaffold.dart';
import 'patient_home_screen.dart';
import 'patient_profile_screen.dart';
import 'patient_progress_screen.dart';
import 'patient_requests_screen.dart';
import 'search_caregivers_screen.dart';

class PatientShell extends StatelessWidget {
  const PatientShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ShellScaffold(
      tabs: [
        ShellTab(
          label: 'Home',
          title: 'Dashboard',
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          builder: (_) => const PatientHomeScreen(),
        ),
        ShellTab(
          label: 'Find',
          title: 'Find caregiver',
          icon: Icons.search,
          selectedIcon: Icons.search,
          builder: (_) => const SearchCaregiversScreen(),
        ),
        ShellTab(
          label: 'Requests',
          icon: Icons.assignment_outlined,
          selectedIcon: Icons.assignment,
          builder: (_) => const PatientRequestsScreen(),
        ),
        ShellTab(
          label: 'Progress',
          icon: Icons.monitor_heart_outlined,
          selectedIcon: Icons.monitor_heart,
          builder: (_) => const PatientProgressScreen(),
        ),
        ShellTab(
          label: 'Profile',
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          builder: (_) => const PatientProfileScreen(),
        ),
      ],
    );
  }
}
