import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/job.dart';
import '../../models/job_status.dart';
import '../../services/admin_service.dart';
import '../../widgets/async_body.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/refreshable_list.dart';
import '../../widgets/ui_helpers.dart';

class AdminJobsScreen extends StatefulWidget {
  const AdminJobsScreen({super.key});

  @override
  State<AdminJobsScreen> createState() => _AdminJobsScreenState();
}

class _AdminJobsScreenState extends State<AdminJobsScreen> {
  static const _filters = <(String, String?)>[
    ('All', null),
    ('Running', 'running'),
    ('Pending', 'pending'),
    ('Active', 'Active'),
    ('Finished', 'Finish'),
    ('Rejected', 'Rejected'),
  ];

  String? _status;

  @override
  Widget build(BuildContext context) {
    final service = context.read<AdminService>();
    return Column(
      children: [
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              for (final filter in _filters)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter.$1),
                    selected: _status == filter.$2,
                    onSelected: (_) => setState(() => _status = filter.$2),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: AsyncBody<List<Job>>(
            key: ValueKey(_status),
            load: () => service.jobs(status: _status),
            builder: (context, jobs, reload) => RefreshableList(
              onRefresh: reload,
              emptyIcon: Icons.work_outline,
              emptyMessage: 'No jobs found',
              children: [
                for (final job in jobs)
                  SectionCard(
                    onTap: () => _manage(context, service, job, reload),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                job.patient?.displayName ?? 'Patient',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            StatusChip.job(job.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Caregiver: ${job.caregiver?.name ?? '-'}'),
                        Text(
                          Formatters.dateTime(job.dateTime),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _manage(
    BuildContext context,
    AdminService service,
    Job job,
    Reload reload,
  ) async {
    final action = await showModalBottomSheet<Object>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final status in JobStatus.values)
              ListTile(
                leading: Icon(
                  job.status == status ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: statusColor(status),
                ),
                title: Text('Set as ${status.label}'),
                onTap: () => Navigator.pop(sheetContext, status),
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppTheme.danger),
              title: const Text('Delete job', style: TextStyle(color: AppTheme.danger)),
              onTap: () => Navigator.pop(sheetContext, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;

    try {
      if (action is JobStatus) {
        if (action == job.status) return;
        await service.updateJobStatus(job.id, action);
      } else {
        final ok = await confirm(
          context,
          title: 'Delete job',
          message: 'This permanently deletes the job. Continue?',
          confirmLabel: 'Delete',
          destructive: true,
        );
        if (!ok) return;
        await service.deleteJob(job.id);
      }
      if (context.mounted) showMessage(context, 'Job updated');
      await reload();
    } catch (error) {
      if (context.mounted) showError(context, error);
    }
  }
}
