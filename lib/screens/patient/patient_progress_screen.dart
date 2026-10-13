import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/patient_progress.dart';
import '../../providers/auth_provider.dart';
import '../../services/patient_service.dart';
import '../../widgets/async_body.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/refreshable_list.dart';

class PatientProgressScreen extends StatelessWidget {
  const PatientProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patientId = context.read<AuthProvider>().session!.id;
    return AsyncBody<List<PatientProgress>>(
      load: () async {
        final logs = await context.read<PatientService>().myProgress(patientId);
        return logs.reversed.toList();
      },
      builder: (context, logs, reload) => RefreshableList(
        onRefresh: reload,
        emptyIcon: Icons.monitor_heart_outlined,
        emptyMessage: 'No progress has been recorded yet',
        children: [for (final log in logs) ProgressCard(progress: log)],
      ),
    );
  }
}
