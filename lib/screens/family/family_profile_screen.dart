import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/validators.dart';
import '../../models/family_member.dart';
import '../../providers/auth_provider.dart';
import '../../services/family_service.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/async_body.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/logout_button.dart';
import '../../widgets/ui_helpers.dart';

class FamilyProfileScreen extends StatelessWidget {
  const FamilyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final id = context.read<AuthProvider>().session!.id;
    return AsyncBody<FamilyMember>(
      load: () => context.read<FamilyService>().profile(id),
      builder: (context, member, _) => _FamilyForm(member: member),
    );
  }
}

class _FamilyForm extends StatefulWidget {
  const _FamilyForm({required this.member});

  final FamilyMember member;

  @override
  State<_FamilyForm> createState() => _FamilyFormState();
}

class _FamilyFormState extends State<_FamilyForm> {
  final _formKey = GlobalKey<FormState>();
  late final _phone = TextEditingController(text: widget.member.phoneNumber);
  late final _email = TextEditingController(text: widget.member.email ?? '');
  bool _loading = false;

  @override
  void dispose() {
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final service = context.read<FamilyService>();
    setState(() => _loading = true);
    try {
      final updated = await service.updateProfile(
        id: widget.member.id,
        phoneNumber: _phone.text,
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
      );
      await auth.updateUser({
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
    final member = widget.member;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(child: UserAvatar(name: member.familyMemberName, radius: 36)),
        const SizedBox(height: 8),
        Center(
          child: Text(
            member.familyMemberName,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 20),
        SectionCard(child: InfoRow(label: 'Location', value: member.location, icon: Icons.location_on_outlined)),
        const SizedBox(height: 16),
        Form(
          key: _formKey,
          child: Column(
            children: [
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
            ],
          ),
        ),
        const SizedBox(height: 24),
        LoadingButton(label: 'Save changes', loading: _loading, onPressed: _save),
        const SizedBox(height: 12),
        const LogoutButton(),
      ],
    );
  }
}
