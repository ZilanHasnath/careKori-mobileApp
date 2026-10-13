import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/caregiver.dart';
import '../../models/family_member.dart';
import '../../models/patient.dart';
import '../../services/admin_service.dart';
import '../../widgets/async_body.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/refreshable_list.dart';
import 'admin_detail_screen.dart';

class AdminPeopleScreen extends StatelessWidget {
  const AdminPeopleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: const [
          TabBar(tabs: [Tab(text: 'Caregivers'), Tab(text: 'Patients'), Tab(text: 'Family')]),
          Expanded(
            child: TabBarView(
              children: [_CaregiversTab(), _PatientsTab(), _FamilyTab()],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _open(BuildContext context, Widget screen, Reload reload) async {
  final changed = await Navigator.push<bool>(
    context,
    MaterialPageRoute<bool>(builder: (_) => screen),
  );
  if (changed == true) await reload();
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({
    required this.name,
    required this.subtitle,
    required this.onTap,
    this.chip,
  });

  final String name;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? chip;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      onTap: onTap,
      child: Row(
        children: [
          UserAvatar(name: name),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (chip != null) chip!,
        ],
      ),
    );
  }
}

class _CaregiversTab extends StatefulWidget {
  const _CaregiversTab();

  @override
  State<_CaregiversTab> createState() => _CaregiversTabState();
}

class _CaregiversTabState extends State<_CaregiversTab> {
  String? _accountType;

  @override
  Widget build(BuildContext context) {
    final service = context.read<AdminService>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              for (final option in const [null, 'Pending', 'Approved'])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(option ?? 'All'),
                    selected: _accountType == option,
                    onSelected: (_) => setState(() => _accountType = option),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: AsyncBody<List<Caregiver>>(
            key: ValueKey(_accountType),
            load: () => service.caregivers(accountType: _accountType),
            builder: (context, caregivers, reload) => RefreshableList(
              onRefresh: reload,
              emptyIcon: Icons.medical_services_outlined,
              emptyMessage: 'No caregivers found',
              children: [
                for (final c in caregivers)
                  _PersonTile(
                    name: c.name,
                    subtitle: '${c.phoneNumber} · ${c.location}',
                    chip: StatusChip(
                      label: c.accountType,
                      color: c.isApproved ? AppTheme.success : AppTheme.warning,
                    ),
                    onTap: () => _open(
                      context,
                      AdminDetailScreen(
                        title: c.name,
                        rows: [
                          ('Status', c.accountType),
                          ('Phone', c.phoneNumber),
                          ('Email', Formatters.orDash(c.email)),
                          ('Location', c.location),
                          ('Sex', c.sex),
                          ('Age', '${c.age}'),
                          ('Experience', c.experience),
                          ('Salary', Formatters.salary(c.expectedSalary)),
                          ('Speciality', c.speciality.join(', ')),
                          ('ID / Passport', c.nationalIdPassportNo),
                          ('Joined', Formatters.date(c.createdAt)),
                        ],
                        onApprove: c.isApproved ? null : () => service.approveCaregiver(c.id),
                        onDelete: () => service.deleteCaregiver(c.id),
                      ),
                      reload,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PatientsTab extends StatelessWidget {
  const _PatientsTab();

  @override
  Widget build(BuildContext context) {
    final service = context.read<AdminService>();
    return AsyncBody<List<Patient>>(
      load: service.patients,
      builder: (context, patients, reload) => RefreshableList(
        onRefresh: reload,
        emptyIcon: Icons.personal_injury_outlined,
        emptyMessage: 'No patients found',
        children: [
          for (final p in patients)
            _PersonTile(
              name: p.displayName,
              subtitle: '${p.uniqueId} · ${p.location}',
              onTap: () => _open(
                context,
                AdminDetailScreen(
                  title: p.displayName,
                  rows: [
                    ('Unique ID', p.uniqueId),
                    ('Phone', p.phoneNumber),
                    ('Email', Formatters.orDash(p.email)),
                    ('Location', p.location),
                    ('Sex', p.sex),
                    ('Age', '${p.age}'),
                    ('Conditions', p.illness.join(', ')),
                    ('Joined', Formatters.date(p.createdAt)),
                  ],
                  extra: [
                    if (p.linkedFamilyMembers.isNotEmpty)
                      SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Linked family members',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                            for (final f in p.linkedFamilyMembers)
                              InfoRow(label: f.familyMemberName, value: f.phoneNumber),
                          ],
                        ),
                      ),
                  ],
                  onDelete: () => service.deletePatient(p.id),
                ),
                reload,
              ),
            ),
        ],
      ),
    );
  }
}

class _FamilyTab extends StatelessWidget {
  const _FamilyTab();

  @override
  Widget build(BuildContext context) {
    final service = context.read<AdminService>();
    return AsyncBody<List<FamilyMember>>(
      load: service.families,
      builder: (context, members, reload) => RefreshableList(
        onRefresh: reload,
        emptyIcon: Icons.family_restroom_outlined,
        emptyMessage: 'No family members found',
        children: [
          for (final m in members)
            _PersonTile(
              name: m.familyMemberName,
              subtitle: '${m.phoneNumber} · ${m.location}',
              onTap: () => _open(
                context,
                AdminDetailScreen(
                  title: m.familyMemberName,
                  rows: [
                    ('Phone', m.phoneNumber),
                    ('Email', Formatters.orDash(m.email)),
                    ('Location', m.location),
                    ('Joined', Formatters.date(m.createdAt)),
                  ],
                  extra: [
                    if (m.linkedPatients.isNotEmpty)
                      SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Linked patients',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                            for (final p in m.linkedPatients)
                              InfoRow(label: p.uniqueId, value: p.displayName),
                          ],
                        ),
                      ),
                  ],
                  onDelete: () => service.deleteFamily(m.id),
                ),
                reload,
              ),
            ),
        ],
      ),
    );
  }
}
