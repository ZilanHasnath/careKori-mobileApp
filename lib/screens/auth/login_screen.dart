import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/ui_helpers.dart';
import 'auth_scaffold.dart';
import 'forgot_password_screen.dart';
import 'register_caregiver_screen.dart';
import 'register_family_screen.dart';
import 'register_patient_screen.dart';

enum PortalType {
  patient(
    icon: Icons.personal_injury_outlined,
    title: 'Patient',
    subtitle: 'Find and hire a caregiver',
  ),
  family(
    icon: Icons.family_restroom_outlined,
    title: 'Family Member',
    subtitle: 'Follow a loved one\'s care progress',
  ),
  caregiver(
    icon: Icons.medical_services_outlined,
    title: 'Caregiver',
    subtitle: 'Offer your care services',
  );

  const PortalType({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  Widget get registerScreen => switch (this) {
        PortalType.patient => const RegisterPatientScreen(),
        PortalType.family => const RegisterFamilyScreen(),
        PortalType.caregiver => const RegisterCaregiverScreen(),
      };
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.portal});

  final PortalType portal;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().login(_identifier.text, _password.text);
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openRegister() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => widget.portal.registerScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: '${widget.portal.title} Login',
      subtitle: 'Log in to ${AppConstants.appName} with your phone number or email',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                controller: _identifier,
                label: 'Phone or email',
                icon: Icons.person_outline,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.required(v, 'Phone or email'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _password,
                label: 'Password',
                icon: Icons.lock_outline,
                obscure: true,
                textInputAction: TextInputAction.done,
                validator: (v) => Validators.required(v, 'Password'),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const ForgotPasswordScreen()),
            ),
            child: const Text('Forgot password?'),
          ),
        ),
        const SizedBox(height: 8),
        LoadingButton(label: 'Log in', loading: _loading, onPressed: _submit),
        const SizedBox(height: 16),
        OutlinedButton(onPressed: _openRegister, child: Text('Create ${widget.portal.title} account')),
      ],
    );
  }
}
