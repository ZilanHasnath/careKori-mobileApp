import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/admin_service.dart';
import '../../widgets/async_body.dart';

class _Stats {
  const _Stats({
    required this.caregivers,
    required this.pendingCaregivers,
    required this.patients,
    required this.families,
    required this.runningJobs,
  });

  final int caregivers;
  final int pendingCaregivers;
  final int patients;
  final int families;
  final int runningJobs;
}

class AdminOverviewScreen extends StatelessWidget {
  const AdminOverviewScreen({super.key});

  Future<_Stats> _load(AdminService service) async {
    final caregivers = service.caregivers();
    final patients = service.patients();
    final families = service.families();
    final jobs = service.jobs(status: 'running');
    final caregiverList = await caregivers;
    return _Stats(
      caregivers: caregiverList.length,
      pendingCaregivers: caregiverList.where((c) => !c.isApproved).length,
      patients: (await patients).length,
      families: (await families).length,
      runningJobs: (await jobs).length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<AdminService>();
    return AsyncBody<_Stats>(
      load: () => _load(service),
      builder: (context, stats, reload) => RefreshIndicator(
        onRefresh: reload,
        child: GridView.count(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            _StatTile(label: 'Caregivers', value: stats.caregivers, icon: Icons.medical_services_rounded, color: const Color(0xFF4F46E5)),
            _StatTile(
              label: 'Pending approval',
              value: stats.pendingCaregivers,
              icon: Icons.hourglass_top,
              color: const Color(0xFFD97706),
            ),
            _StatTile(label: 'Patients', value: stats.patients, icon: Icons.personal_injury_rounded, color: const Color(0xFFE11D48)),
            _StatTile(label: 'Family members', value: stats.families, icon: Icons.family_restroom_rounded, color: const Color(0xFF0891B2)),
            _StatTile(
              label: 'Running jobs',
              value: stats.runningJobs,
              icon: Icons.work_outline,
              color: const Color(0xFF059669),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tint, Color.lerp(tint, Colors.black, 0.28) ?? tint],
        ),
        boxShadow: [
          BoxShadow(
            color: tint.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(icon, size: 90, color: Colors.white.withValues(alpha: 0.14)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$value',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(label, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
