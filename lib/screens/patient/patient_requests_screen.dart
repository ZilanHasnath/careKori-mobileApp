import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/formatters.dart';
import '../../models/job.dart';
import '../../providers/auth_provider.dart';
import '../../services/patient_service.dart';
import '../../widgets/async_body.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/refreshable_list.dart';

class PatientRequestsScreen extends StatelessWidget {
  const PatientRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patientId = context.read<AuthProvider>().session!.id;
    return AsyncBody<List<Job>>(
      load: () => context.read<PatientService>().myRequests(patientId),
      builder: (context, jobs, reload) => RefreshableList(
        onRefresh: reload,
        emptyIcon: Icons.assignment_outlined,
        emptyMessage: 'You have not requested any caregiver yet',
        children: [for (final job in jobs) _RequestCard(job: job)],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final caregiver = job.caregiver;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(name: caregiver?.name ?? '?'),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  caregiver?.name ?? 'Caregiver',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              StatusChip.job(job.status),
            ],
          ),
          const SizedBox(height: 12),
          if (caregiver != null) ...[
            InfoRow(label: 'Phone', value: caregiver.phoneNumber, icon: Icons.phone_outlined),
            InfoRow(label: 'Location', value: caregiver.location, icon: Icons.location_on_outlined),
            InfoRow(
              label: 'Salary',
              value: Formatters.salary(caregiver.expectedSalary),
              icon: Icons.payments_outlined,
            ),
          ],
          InfoRow(
            label: 'Requested',
            value: Formatters.dateTime(job.dateTime),
            icon: Icons.schedule,
          ),
        ],
      ),
    );
  }
}
