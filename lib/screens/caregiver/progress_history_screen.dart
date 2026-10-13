import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/patient_progress.dart';
import '../../services/caregiver_service.dart';
import '../../widgets/async_body.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/refreshable_list.dart';

class ProgressHistoryScreen extends StatelessWidget {
  const ProgressHistoryScreen({
    super.key,
    required this.patientId,
    required this.caregiverId,
    required this.title,
  });

  final String patientId;
  final String caregiverId;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$title · history')),
      body: AsyncBody<List<PatientProgress>>(
        load: () => context
            .read<CaregiverService>()
            .patientHistory(patientId: patientId, caregiverId: caregiverId),
        builder: (context, logs, reload) => RefreshableList(
          onRefresh: reload,
          emptyIcon: Icons.history,
          emptyMessage: 'No progress recorded yet',
          children: [for (final log in logs) ProgressCard(progress: log)],
        ),
      ),
    );
  }
}
