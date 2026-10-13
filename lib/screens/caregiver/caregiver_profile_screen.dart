import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../models/caregiver.dart';
import '../../providers/auth_provider.dart';
import '../../services/caregiver_service.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/async_body.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/logout_button.dart';
import '../../widgets/ui_helpers.dart';

class CaregiverProfileScreen extends StatelessWidget {
  const CaregiverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final id = context.read<AuthProvider>().session!.id;
    return AsyncBody<Caregiver>(
      load: () => context.read<CaregiverService>().profile(id),
      builder: (context, caregiver, _) => _CaregiverForm(caregiver: caregiver),
    );
  }
}

class _CaregiverForm extends StatefulWidget {
  const _CaregiverForm({required this.caregiver});

  final Caregiver caregiver;

  @override
  State<_CaregiverForm> createState() => _CaregiverFormState();
}

class _CaregiverFormState extends State<_CaregiverForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.caregiver.name);
  late final _phone = TextEditingController(text: widget.caregiver.phoneNumber);
  late final _email = TextEditingController(text: widget.caregiver.email ?? '');
  late final _location = TextEditingController(text: widget.caregiver.location);
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _location]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final service = context.read<CaregiverService>();
    setState(() => _loading = true);
    try {
      final updated = await service.updateProfile(
        id: widget.caregiver.id,
        name: _name.text,
        phoneNumber: _phone.text,
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        location: _location.text,
      );
      await auth.updateUser({
        'name': updated.name,
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
    final caregiver = widget.caregiver;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(child: UserAvatar(name: caregiver.name, radius: 36)),
        const SizedBox(height: 8),
        Center(
          child: StatusChip(
            label: caregiver.isApproved ? 'Approved' : 'Pending approval',
            color: caregiver.isApproved ? AppTheme.success : AppTheme.warning,
          ),
        ),
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
        SectionCard(
          child: Column(
            children: [
              InfoRow(label: 'Experience', value: caregiver.experience),
              InfoRow(label: 'Expected salary', value: Formatters.salary(caregiver.expectedSalary)),
              InfoRow(label: 'Sex', value: caregiver.sex),
              InfoRow(label: 'Age', value: '${caregiver.age}'),
              InfoRow(label: 'Speciality', value: caregiver.speciality.join(', ')),
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
