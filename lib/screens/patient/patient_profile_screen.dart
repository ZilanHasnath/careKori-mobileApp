import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/validators.dart';
import '../../models/patient.dart';
import '../../providers/auth_provider.dart';
import '../../services/patient_service.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/async_body.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/logout_button.dart';
import '../../widgets/ui_helpers.dart';

class PatientProfileScreen extends StatelessWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final id = context.read<AuthProvider>().session!.id;
    return AsyncBody<Patient>(
      load: () => context.read<PatientService>().profile(id),
      builder: (context, patient, _) => _PatientForm(patient: patient),
    );
  }
}

class _PatientForm extends StatefulWidget {
  const _PatientForm({required this.patient});

  final Patient patient;

  @override
  State<_PatientForm> createState() => _PatientFormState();
}

class _PatientFormState extends State<_PatientForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.patient.patientName);
  late final _phone = TextEditingController(text: widget.patient.phoneNumber);
  late final _email = TextEditingController(text: widget.patient.email ?? '');
  late final _age = TextEditingController(text: '${widget.patient.age}');
  late final _location = TextEditingController(text: widget.patient.location);
  late String _sex = AppConstants.sexOptions.contains(widget.patient.sex)
      ? widget.patient.sex
      : AppConstants.sexOptions.first;
  late final Set<String> _illness = {...widget.patient.illness};
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _age, _location]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final service = context.read<PatientService>();
    setState(() => _loading = true);
    try {
      final updated = await service.updateProfile(
        id: widget.patient.id,
        patientName: _name.text,
        phoneNumber: _phone.text,
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        age: int.parse(_age.text.trim()),
        sex: _sex,
        location: _location.text,
        illness: _illness.toList(),
      );
      await auth.updateUser({
        'patientName': updated.patientName,
        'phoneNumber': updated.phoneNumber,
        'email': updated.email,
      });
      if (mounted) showMessage(context, 'Profile updated');
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = {...AppConstants.illnessOptions, ..._illness}.toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(child: UserAvatar(name: widget.patient.patientName, radius: 36)),
        const SizedBox(height: 8),
        Center(child: Text('ID: ${widget.patient.uniqueId}')),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                controller: _name,
                label: 'Full name',
                icon: Icons.person_outline,
                validator: (v) => Validators.required(v, 'Name'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _phone,
                label: 'Phone number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: Validators.phone,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _email,
                label: 'Email (optional)',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.optionalEmail,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _age,
                      label: 'Age',
                      keyboardType: TextInputType.number,
                      validator: (v) => Validators.positiveInt(v, 'Age'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppDropdown(
                      label: 'Sex',
                      value: _sex,
                      options: AppConstants.sexOptions,
                      onChanged: (v) => setState(() => _sex = v ?? _sex),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _location,
                label: 'Location',
                icon: Icons.location_on_outlined,
                validator: (v) => Validators.required(v, 'Location'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Conditions', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              FilterChip(
                label: Text(option),
                selected: _illness.contains(option),
                onSelected: (selected) => setState(() {
                  if (selected) {
                    _illness.add(option);
                  } else if (_illness.length > 1) {
                    _illness.remove(option);
                  }
                }),
              ),
          ],
        ),
        const SizedBox(height: 24),
        LoadingButton(label: 'Save changes', loading: _loading, onPressed: _save),
        const SizedBox(height: 12),
        const LogoutButton(),
      ],
    );
  }
}
