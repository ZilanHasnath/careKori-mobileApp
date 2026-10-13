import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/network/api_client.dart';
import 'providers/auth_provider.dart';
import 'services/admin_service.dart';
import 'services/auth_service.dart';
import 'services/caregiver_service.dart';
import 'services/family_service.dart';
import 'services/patient_service.dart';
import 'services/session_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final api = ApiClient();
  final authService = AuthService(api);

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        Provider<PatientService>.value(value: PatientService(api)),
        Provider<CaregiverService>.value(value: CaregiverService(api)),
        Provider<FamilyService>.value(value: FamilyService(api)),
        Provider<AdminService>.value(value: AdminService(api)),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
            authService: authService,
            storage: SessionStorage(),
          )..restore(),
        ),
      ],
      child: const CareKoriApp(),
    ),
  );
}
