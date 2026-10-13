import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'models/session.dart';
import 'providers/auth_provider.dart';
import 'screens/admin/admin_shell.dart';
import 'screens/auth/portal_selection_screen.dart';
import 'screens/caregiver/caregiver_shell.dart';
import 'screens/family/family_shell.dart';
import 'screens/patient/patient_shell.dart';
import 'widgets/care_loader.dart';

class CareKoriApp extends StatelessWidget {
  const CareKoriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.initializing:
        return const Scaffold(body: CareLoader(label: 'Loading...'));
      case AuthStatus.unauthenticated:
        return const PortalSelectionScreen();
      case AuthStatus.authenticated:
        return switch (auth.session!.role) {
          UserRole.patient => const PatientShell(),
          UserRole.family => const FamilyShell(),
          UserRole.caregiver => const CaregiverShell(),
          UserRole.admin => const AdminShell(),
        };
    }
  }
}
