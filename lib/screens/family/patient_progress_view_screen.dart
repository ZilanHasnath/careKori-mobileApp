import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/patient.dart';
import '../../models/patient_progress.dart';
import '../../services/family_service.dart';
import '../../widgets/async_body.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/refreshable_list.dart';

class PatientProgressViewScreen extends StatelessWidget {
  const PatientProgressViewScreen({super.key, required this.patient});

  final Patient patient;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(patient.displayName)),
      body: AsyncBody<List<PatientProgress>>(
        load: () => context.read<FamilyService>().patientProgress(patient.id),
        builder: (context, logs, reload) => RefreshableList(
          onRefresh: reload,
          emptyIcon: Icons.monitor_heart_outlined,
          emptyMessage: 'No progress has been recorded yet',
          children: [for (final log in logs) ProgressCard(progress: log)],
        ),
      ),
    );
  }
}
