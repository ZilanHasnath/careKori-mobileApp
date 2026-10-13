import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/validators.dart';
import '../../models/job.dart';
import '../../models/job_status.dart';
import '../../providers/auth_provider.dart';
import '../../services/caregiver_service.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/async_body.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/state_views.dart';
import '../../widgets/ui_helpers.dart';

class AddProgressPage extends StatelessWidget {
  const AddProgressPage({super.key, this.initialJob});

  final Job? initialJob;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add progress')),
      body: AddProgressForm(initialJob: initialJob),
    );
  }
}

class AddProgressForm extends StatelessWidget {
  const AddProgressForm({super.key, this.initialJob});

  final Job? initialJob;

  @override
  Widget build(BuildContext context) {
    final caregiverId = context.read<AuthProvider>().session!.id;
    return AsyncBody<List<Job>>(
      load: () async {
        final jobs = await context.read<CaregiverService>().myJobs(caregiverId);
        return jobs.where((job) => job.status == JobStatus.active).toList();
      },
      builder: (context, jobs, _) {
        if (jobs.isEmpty) {
          return const EmptyState(
            icon: Icons.work_off_outlined,
            message: 'You need an active job before you can record progress',
          );
        }
        return _ProgressFormBody(
          jobs: jobs,
          caregiverId: caregiverId,
          initialJobId: initialJob?.id,
        );
      },
    );
  }
}

class _ProgressFormBody extends StatefulWidget {
  const _ProgressFormBody({
    required this.jobs,
    required this.caregiverId,
    this.initialJobId,
  });

  final List<Job> jobs;
  final String caregiverId;
  final String? initialJobId;

  @override
  State<_ProgressFormBody> createState() => _ProgressFormBodyState();
}

class _ProgressFormBodyState extends State<_ProgressFormBody> {
  final _formKey = GlobalKey<FormState>();
  final _bloodPressure = TextEditingController();
  final _heartRate = TextEditingController();
  final _meals = TextEditingController();
  final _exercise = TextEditingController();
  final _medicine = TextEditingController();
  final _mood = TextEditingController();
  final _note = TextEditingController();
  late String _jobId = widget.jobs.any((j) => j.id == widget.initialJobId)
      ? widget.initialJobId!
      : widget.jobs.first.id;
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [_bloodPressure, _heartRate, _meals, _exercise, _medicine, _mood, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  Job get _job => widget.jobs.firstWhere((j) => j.id == _jobId);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final service = context.read<CaregiverService>();
    setState(() => _loading = true);
    try {
      await service.addProgress(
        jobId: _job.id,
        caregiverId: widget.caregiverId,
        patientId: _job.patientId,
        bloodPressure: _bloodPressure.text,
        heartRate: int.parse(_heartRate.text.trim()),
        meals: _meals.text,
        exercise: _exercise.text,
        medicineStatus: _medicine.text,
        patientMood: _mood.text,
        note: _note.text,
      );
      for (final c in [_bloodPressure, _heartRate, _meals, _exercise, _medicine, _mood, _note]) {
        c.clear();
      }
      if (mounted) showMessage(context, 'Progress recorded');
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _label(Job job) {
    final patient = job.patient;
    if (patient == null) return 'Patient';
    final name = patient.patientName.isEmpty ? patient.phoneNumber : patient.patientName;
    return name.isEmpty ? 'Patient' : name;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: _jobId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Patient',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items: [
                  for (final job in widget.jobs)
                    DropdownMenuItem(value: job.id, child: Text(_label(job))),
                ],
                onChanged: (value) => setState(() => _jobId = value ?? _jobId),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _bloodPressure,
                      label: 'Blood pressure',
                      validator: (v) => Validators.required(v, 'Blood pressure'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _heartRate,
                      label: 'Heart rate',
                      keyboardType: TextInputType.number,
                      validator: (v) => Validators.positiveInt(v, 'Heart rate'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _meals,
                label: 'Meals',
                validator: (v) => Validators.required(v, 'Meals'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _exercise,
                label: 'Exercise',
                validator: (v) => Validators.required(v, 'Exercise'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _medicine,
                label: 'Medicine status',
                validator: (v) => Validators.required(v, 'Medicine status'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _mood,
                label: 'Patient mood',
                validator: (v) => Validators.required(v, 'Mood'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _note,
                label: 'Note',
                maxLines: 4,
                validator: (v) => Validators.required(v, 'Note'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        LoadingButton(label: 'Save progress', loading: _loading, onPressed: _submit),
      ],
    );
  }
}
