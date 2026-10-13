import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/validators.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/ui_helpers.dart';
import 'auth_scaffold.dart';

class RegisterCaregiverScreen extends StatefulWidget {
  const RegisterCaregiverScreen({super.key});

  @override
  State<RegisterCaregiverScreen> createState() => _RegisterCaregiverScreenState();
}

class _RegisterCaregiverScreenState extends State<RegisterCaregiverScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _location = TextEditingController();
  final _salary = TextEditingController();
  final _experience = TextEditingController();
  final _age = TextEditingController();
  final _documentNo = TextEditingController();
  String _sex = AppConstants.sexOptions.first;
  String _speciality = AppConstants.specialityOptions.first;
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [
      _name,
      _phone,
      _email,
      _password,
      _location,
      _salary,
      _experience,
      _age,
      _documentNo,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthService>().registerCaregiver(
            name: _name.text,
            phoneNumber: _phone.text,
            email: _email.text.trim().isEmpty ? null : _email.text.trim(),
            password: _password.text,
            location: _location.text,
            expectedSalary: double.parse(_salary.text.trim()),
            speciality: [_speciality],
            experience: _experience.text,
            sex: _sex,
            age: int.parse(_age.text.trim()),
            nationalIdPassportNo: _documentNo.text,
          );
      if (!mounted) return;
      Navigator.pop(context);
      showMessage(context, 'Registration submitted. Your account is pending approval.');
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Caregiver registration',
      subtitle: 'An admin will review your account before you appear in search',
      children: [
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
              AppTextField(
                controller: _password,
                label: 'Password',
                icon: Icons.lock_outline,
                obscure: true,
                validator: Validators.password,
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
              const SizedBox(height: 16),
              AppDropdown(
                label: 'Speciality',
                value: _speciality,
                options: AppConstants.specialityOptions,
                onChanged: (v) => setState(() => _speciality = v ?? _speciality),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _experience,
                label: 'Experience (e.g. 3 years)',
                icon: Icons.work_outline,
                validator: (v) => Validators.required(v, 'Experience'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _salary,
                label: 'Expected salary (BDT)',
                icon: Icons.payments_outlined,
                keyboardType: TextInputType.number,
                validator: (v) => Validators.positiveNumber(v, 'Salary'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _documentNo,
                label: 'National ID / Passport no.',
                icon: Icons.badge_outlined,
                validator: (v) => Validators.required(v, 'ID number'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        LoadingButton(label: 'Submit registration', loading: _loading, onPressed: _submit),
      ],
    );
  }
}
