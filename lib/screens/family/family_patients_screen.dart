import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/validators.dart';
import '../../models/patient.dart';
import '../../providers/auth_provider.dart';
import '../../services/family_service.dart';
import '../../widgets/async_body.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/refreshable_list.dart';
import '../../widgets/ui_helpers.dart';
import 'patient_progress_view_screen.dart';

class FamilyPatientsScreen extends StatelessWidget {
  const FamilyPatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final familyId = context.read<AuthProvider>().session!.id;
    return AsyncBody<List<Patient>>(
      load: () => context.read<FamilyService>().myPatients(familyId),
      builder: (context, patients, reload) => Stack(
        children: [
          RefreshableList(
            onRefresh: reload,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            emptyIcon: Icons.personal_injury_outlined,
            emptyMessage: 'Link a patient using their unique ID to follow their care',
            children: [
              for (final patient in patients)
                SectionCard(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => PatientProgressViewScreen(patient: patient),
                    ),
                  ),
                  child: Row(
                    children: [
                      UserAvatar(name: patient.patientName),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patient.displayName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text('${patient.uniqueId} · ${patient.location}'),
                            const SizedBox(height: 6),
                            TagWrap(tags: patient.illness),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: () async {
                final linked = await showDialog<bool>(
                  context: context,
                  builder: (_) => const _LinkPatientDialog(),
                );
                if (linked == true) await reload();
              },
              icon: const Icon(Icons.add_link),
              label: const Text('Link patient'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkPatientDialog extends StatefulWidget {
  const _LinkPatientDialog();

  @override
  State<_LinkPatientDialog> createState() => _LinkPatientDialogState();
}

class _LinkPatientDialogState extends State<_LinkPatientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _uniqueId = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _uniqueId.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final service = context.read<FamilyService>();
    final familyId = context.read<AuthProvider>().session!.id;
    final navigator = Navigator.of(context);
    setState(() => _loading = true);
    try {
      await service.linkPatient(familyMemberId: familyId, uniqueId: _uniqueId.text);
      navigator.pop(true);
    } catch (error) {
      if (mounted) {
        setState(() => _loading = false);
        showError(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Link a patient'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _uniqueId,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(labelText: 'Patient unique ID', hintText: 'PAT-XXXXXXXX'),
          validator: (v) => Validators.required(v, 'Unique ID'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(96, 44)),
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Link'),
        ),
      ],
    );
  }
}
