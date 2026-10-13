import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/job.dart';
import '../../models/job_status.dart';
import '../../providers/auth_provider.dart';
import '../../services/caregiver_service.dart';
import '../../widgets/async_body.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/refreshable_list.dart';
import '../../widgets/ui_helpers.dart';
import '../../widgets/care_loader.dart';
import 'add_progress_screen.dart';
import 'progress_history_screen.dart';

class CaregiverJobsScreen extends StatefulWidget {
  const CaregiverJobsScreen({super.key});

  @override
  State<CaregiverJobsScreen> createState() => _CaregiverJobsScreenState();
}

class _CaregiverJobsScreenState extends State<CaregiverJobsScreen> {
  JobStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final caregiverId = context.read<AuthProvider>().session!.id;
    return AsyncBody<List<Job>>(
      load: () => context.read<CaregiverService>().myJobs(caregiverId),
      builder: (context, jobs, reload) {
        final visible =
            _filter == null ? jobs : jobs.where((j) => j.status == _filter).toList();
        return Column(
          children: [
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _filter == null,
                    onTap: () => setState(() => _filter = null),
                  ),
                  for (final status in JobStatus.values)
                    _FilterChip(
                      label: status.label,
                      selected: _filter == status,
                      onTap: () => setState(() => _filter = status),
                    ),
                ],
              ),
            ),
            Expanded(
              child: RefreshableList(
                onRefresh: reload,
                emptyIcon: Icons.work_outline,
                emptyMessage: 'No job requests here',
                children: [
                  for (final job in visible) _JobCard(job: job, onChanged: reload),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onTap()),
    );
  }
}

class _JobCard extends StatefulWidget {
  const _JobCard({required this.job, required this.onChanged});

  final Job job;
  final Reload onChanged;

  @override
  State<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<_JobCard> {
  bool _busy = false;

  Future<void> _run(Future<void> Function(CaregiverService service) action, String done) async {
    final service = context.read<CaregiverService>();
    setState(() => _busy = true);
    try {
      await action(service);
      if (mounted) showMessage(context, done);
      await widget.onChanged();
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reject() async {
    final ok = await confirm(
      context,
      title: 'Reject request',
      message: 'Do you want to reject this request?',
      confirmLabel: 'Reject',
      destructive: true,
    );
    if (ok) {
      await _run((s) => s.updateJobStatus(widget.job.id, JobStatus.rejected), 'Request rejected');
    }
  }

  Future<void> _finish() async {
    final ok = await confirm(
      context,
      title: 'Finish job',
      message: 'Mark this job as finished?',
      confirmLabel: 'Finish',
    );
    if (ok) {
      await _run((s) => s.updateJobStatus(widget.job.id, JobStatus.finish), 'Job finished');
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final patient = job.patient;
    final theme = Theme.of(context);
    final caregiverId = context.read<AuthProvider>().session!.id;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(name: patient?.displayName ?? '?'),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  patient?.displayName ?? 'Patient',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              StatusChip.job(job.status),
            ],
          ),
          const SizedBox(height: 12),
          if (patient != null) ...[
            InfoRow(label: 'Phone', value: patient.phoneNumber, icon: Icons.phone_outlined),
            InfoRow(label: 'Location', value: patient.location, icon: Icons.location_on_outlined),
          ],
          InfoRow(label: 'Requested', value: Formatters.dateTime(job.dateTime), icon: Icons.schedule),
          const SizedBox(height: 8),
          if (_busy)
            const CareLoader()
          else if (job.status == JobStatus.pending)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      foregroundColor: AppTheme.danger,
                    ),
                    onPressed: _reject,
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                    onPressed: () => _run((s) => s.acceptJob(job.id), 'Request accepted'),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            )
          else if (job.status == JobStatus.active)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => AddProgressPage(initialJob: job),
                    ),
                  ),
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Add progress'),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => ProgressHistoryScreen(
                        patientId: job.patientId,
                        caregiverId: caregiverId,
                        title: patient?.displayName ?? 'Patient',
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.history),
                  label: const Text('History'),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                  onPressed: _finish,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Finish'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
