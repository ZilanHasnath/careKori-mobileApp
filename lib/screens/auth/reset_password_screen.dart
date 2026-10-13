import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/validators.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/ui_helpers.dart';
import 'auth_scaffold.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _token = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _token.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthService>().resetPassword(_token.text, _password.text);
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      showMessage(context, 'Password reset. You can log in now.');
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Reset password',
      subtitle: 'Enter the token from your email and a new password',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                controller: _token,
                label: 'Reset token',
                icon: Icons.key_outlined,
                validator: (v) => Validators.required(v, 'Token'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _password,
                label: 'New password',
                icon: Icons.lock_outline,
                obscure: true,
                validator: Validators.password,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        LoadingButton(label: 'Reset password', loading: _loading, onPressed: _submit),
      ],
    );
  }
}
