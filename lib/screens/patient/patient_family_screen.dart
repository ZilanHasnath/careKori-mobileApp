import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/family_member.dart';
import '../../providers/auth_provider.dart';
import '../../services/patient_service.dart';
import '../../widgets/async_body.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/refreshable_list.dart';
import '../../widgets/ui_helpers.dart';

class PatientFamilyPage extends StatelessWidget {
  const PatientFamilyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family members')),
      body: const PatientFamilyScreen(),
    );
  }
}

class PatientFamilyScreen extends StatelessWidget {
  const PatientFamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.read<AuthProvider>().session!;
    return AsyncBody<List<FamilyMember>>(
      load: () => context.read<PatientService>().connectedFamily(session.id),
      builder: (context, members, reload) => RefreshableList(
        onRefresh: reload,
        emptyIcon: Icons.family_restroom_outlined,
        emptyMessage: 'No family member is connected yet',
        header: SectionCard(
          child: Row(
            children: [
              const Icon(Icons.badge_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your patient ID'),
                    Text(
                      session.uniqueId,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const Text(
                      'Share it with family so they can follow your care.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: session.uniqueId));
                  if (context.mounted) showMessage(context, 'Patient ID copied');
                },
              ),
            ],
          ),
        ),
        children: [
          for (final member in members)
            SectionCard(
              child: Row(
                children: [
                  UserAvatar(name: member.familyMemberName),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.familyMemberName,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(member.phoneNumber),
                        if (member.email != null) Text(member.email!),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
