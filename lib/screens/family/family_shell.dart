import 'package:flutter/material.dart';

import '../../widgets/shell_scaffold.dart';
import 'family_home_screen.dart';
import 'family_patients_screen.dart';
import 'family_profile_screen.dart';

class FamilyShell extends StatelessWidget {
  const FamilyShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ShellScaffold(
      tabs: [
        ShellTab(
          label: 'Home',
          title: 'Dashboard',
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          builder: (_) => const FamilyHomeScreen(),
        ),
        ShellTab(
          label: 'My patients',
          icon: Icons.personal_injury_outlined,
          selectedIcon: Icons.personal_injury,
          builder: (_) => const FamilyPatientsScreen(),
        ),
        ShellTab(
          label: 'Profile',
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          builder: (_) => const FamilyProfileScreen(),
        ),
      ],
    );
  }
}
