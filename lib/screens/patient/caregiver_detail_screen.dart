import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/formatters.dart';
import '../../models/caregiver.dart';
import '../../providers/auth_provider.dart';
import '../../services/patient_service.dart';
import '../../widgets/async_body.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/ui_helpers.dart';

class CaregiverDetailScreen extends StatelessWidget {
  const CaregiverDetailScreen({super.key, required this.caregiverId});

  final String caregiverId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caregiver')),
      body: AsyncBody<Caregiver>(
        load: () => context.read<PatientService>().caregiver(caregiverId),
        builder: (context, caregiver, _) => _Detail(caregiver: caregiver),
      ),
    );
  }
}

class _Detail extends StatefulWidget {
  const _Detail({required this.caregiver});

  final Caregiver caregiver;

  @override
  State<_Detail> createState() => _DetailState();
}

class _DetailState extends State<_Detail> {
  bool _loading = false;

  Future<void> _request() async {
    final patientId = context.read<AuthProvider>().session!.id;
    final service = context.read<PatientService>();
    final ok = await confirm(
      context,
      title: 'Send request',
      message: 'Send a care request to ${widget.caregiver.name}?',
      confirmLabel: 'Send',
    );
    if (!ok) return;

    setState(() => _loading = true);
    try {
      await service.requestJob(patientId: patientId, caregiverId: widget.caregiver.id);
      if (mounted) showMessage(context, 'Request sent');
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final caregiver = widget.caregiver;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(child: UserAvatar(name: caregiver.name, radius: 40)),
        const SizedBox(height: 12),
        Center(
          child: Text(caregiver.name,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 4),
        Center(child: Text(caregiver.location)),
        const SizedBox(height: 20),
        SectionCard(
          child: Column(
            children: [
              InfoRow(label: 'Experience', value: caregiver.experience, icon: Icons.work_outline),
              InfoRow(
                label: 'Expected salary',
                value: '${Formatters.salary(caregiver.expectedSalary)} / month',
                icon: Icons.payments_outlined,
              ),
              InfoRow(label: 'Sex', value: caregiver.sex, icon: Icons.wc),
              InfoRow(label: 'Age', value: '${caregiver.age}', icon: Icons.cake_outlined),
              InfoRow(label: 'Phone', value: caregiver.phoneNumber, icon: Icons.phone_outlined),
              InfoRow(label: 'Email', value: caregiver.email ?? '', icon: Icons.mail_outline),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Speciality', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        TagWrap(tags: caregiver.speciality),
        const SizedBox(height: 24),
        LoadingButton(
          label: 'Request this caregiver',
          icon: Icons.send_outlined,
          loading: _loading,
          onPressed: _request,
        ),
      ],
    );
  }
}
