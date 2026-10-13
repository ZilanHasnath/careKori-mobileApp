import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/validators.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/ui_helpers.dart';
import 'auth_scaffold.dart';

class RegisterFamilyScreen extends StatefulWidget {
  const RegisterFamilyScreen({super.key});

  @override
  State<RegisterFamilyScreen> createState() => _RegisterFamilyScreenState();
}

class _RegisterFamilyScreenState extends State<RegisterFamilyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _location = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _password, _location]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthService>().registerFamilyMember(
            familyMemberName: _name.text,
            phoneNumber: _phone.text,
            email: _email.text.trim().isEmpty ? null : _email.text.trim(),
            password: _password.text,
            location: _location.text,
          );
      if (!mounted) return;
      Navigator.pop(context);
      showMessage(context, 'Account created. You can log in now.');
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Family registration',
      subtitle: 'Create an account to follow a patient\'s care',
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
              AppTextField(
                controller: _location,
                label: 'Location',
                icon: Icons.location_on_outlined,
                validator: (v) => Validators.required(v, 'Location'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        LoadingButton(label: 'Create account', loading: _loading, onPressed: _submit),
      ],
    );
  }
}
