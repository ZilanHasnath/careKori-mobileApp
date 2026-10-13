import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/admin.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin_service.dart';
import '../../widgets/async_body.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/logout_button.dart';
import '../../widgets/ui_helpers.dart';

class _AccountData {
  const _AccountData({required this.me, required this.admins});

  final Admin me;
  final List<Admin> admins;
}

class AdminAccountScreen extends StatelessWidget {
  const AdminAccountScreen({super.key});

  Future<_AccountData> _load(AdminService service, String email) async {
    final meFuture = service.profile(email);
    final adminsFuture = service.admins();
    return _AccountData(me: await meFuture, admins: await adminsFuture);
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<AdminService>();
    final session = context.read<AuthProvider>().session!;
    return AsyncBody<_AccountData>(
      load: () => _load(service, session.email ?? ''),
      builder: (context, data, reload) => RefreshIndicator(
        onRefresh: reload,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Center(child: UserAvatar(name: data.me.name, radius: 36)),
            const SizedBox(height: 8),
            Center(
              child: Text(
                data.me.name,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Center(child: Text(data.me.email)),
            const SizedBox(height: 8),
            Center(
              child: StatusChip(
                label: data.me.role,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text('Administrators', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final admin in data.admins) ...[
              SectionCard(
                child: Row(
                  children: [
                    UserAvatar(name: admin.name),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(admin.name,
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text('${admin.email} · ${admin.role}',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    if (admin.id != data.me.id)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppTheme.danger),
                        onPressed: () async {
                          final ok = await confirm(
                            context,
                            title: 'Remove admin',
                            message: 'Remove ${admin.name} as an administrator?',
                            confirmLabel: 'Remove',
                            destructive: true,
                          );
                          if (!ok) return;
                          try {
                            await service.deleteAdmin(admin.id);
                            await reload();
                          } catch (error) {
                            if (context.mounted) showError(context, error);
                          }
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 16),
            const LogoutButton(),
          ],
        ),
      ),
    );
  }
}
