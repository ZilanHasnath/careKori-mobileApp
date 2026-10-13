import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/dashboard_widgets.dart';
import '../../widgets/shell_scaffold.dart';
import '../../widgets/ui_helpers.dart';
import 'patient_family_screen.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthProvider>().session!;
    final shell = ShellScope.of(context);
    final displayId = session.uniqueId.isNotEmpty ? session.uniqueId : session.id;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GreetingHeader(name: session.name, subtitle: 'How can we help today?',
            icon: Icons.personal_injury_rounded),
        const SizedBox(height: 16),
        _IdCard(
          uniqueId: displayId,
          onCopy: () async {
            await Clipboard.setData(ClipboardData(text: displayId));
            if (context.mounted) showMessage(context, 'Patient ID copied');
          },
        ),
        const SizedBox(height: 22),
        const SectionLabel('Quick actions'),
        DashboardGrid(
          children: [
            DashboardCard(
              icon: Icons.search_rounded,
              title: 'Find Caregiver',
              description: 'Search and hire certified caregivers nearby.',
              color: const Color(0xFF3B5BFD),
              onTap: () => shell.select(1),
            ),
            DashboardCard(
              icon: Icons.assignment_rounded,
              title: 'Job Requests',
              description: 'Track active and pending care requests.',
              color: const Color(0xFFF59E0B),
              onTap: () => shell.select(2),
            ),
            DashboardCard(
              icon: Icons.monitor_heart_rounded,
              title: 'Health Progress',
              description: 'View daily vitals and caregiver reports.',
              color: const Color(0xFFF43F5E),
              onTap: () => shell.select(3),
            ),
            DashboardCard(
              icon: Icons.groups_rounded,
              title: 'Family Members',
              description: 'Manage linked family accounts.',
              color: const Color(0xFF10B981),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const PatientFamilyPage()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _ProfileBanner(onTap: () => shell.select(4)),
      ],
    );
  }
}

class _IdCard extends StatelessWidget {
  const _IdCard({required this.uniqueId, required this.onCopy});

  final String uniqueId;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.line),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PATIENT ID',
                    style: TextStyle(
                        color: AppTheme.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2)),
                const SizedBox(height: 6),
                Text(
                  uniqueId.isEmpty ? 'N/A' : uniqueId,
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Share this ID to link family accounts.',
                  style: TextStyle(color: AppTheme.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFE8ECFF),
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            onPressed: uniqueId.isEmpty ? null : onCopy,
            icon: const Icon(Icons.copy_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}

class _ProfileBanner extends StatelessWidget {
  const _ProfileBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.ink,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: Colors.white),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profile completeness',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                SizedBox(height: 2),
                Text(
                  'Keep your details updated for better care.',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.ink,
            ),
            onPressed: onTap,
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
