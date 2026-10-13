import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/caregiver.dart';
import '../../services/patient_service.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/state_views.dart';
import '../../widgets/ui_helpers.dart';
import 'caregiver_detail_screen.dart';

class SearchCaregiversScreen extends StatefulWidget {
  const SearchCaregiversScreen({super.key});

  @override
  State<SearchCaregiversScreen> createState() => _SearchCaregiversScreenState();
}

class _SearchCaregiversScreenState extends State<SearchCaregiversScreen> {
  static const _any = 'Any';

  final _location = TextEditingController();
  String _sex = _any;
  String _speciality = _any;
  bool _loading = false;
  List<Caregiver>? _results;

  @override
  void dispose() {
    _location.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final location = _location.text.trim();
    if (location.isEmpty && _sex == _any && _speciality == _any) {
      showMessage(context, 'Choose at least one filter', error: true);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      final results = await context.read<PatientService>().searchCaregivers(
            location: location,
            sex: _sex == _any ? null : _sex,
            speciality: _speciality == _any ? null : _speciality,
          );
      if (mounted) setState(() => _results = results);
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          child: Column(
            children: [
              AppTextField(
                controller: _location,
                label: 'Location',
                icon: Icons.location_on_outlined,
                textInputAction: TextInputAction.search,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppDropdown(
                      label: 'Sex',
                      value: _sex,
                      options: const [_any, ...AppConstants.sexOptions],
                      onChanged: (v) => setState(() => _sex = v ?? _any),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppDropdown(
                      label: 'Speciality',
                      value: _speciality,
                      options: const [_any, ...AppConstants.specialityOptions],
                      onChanged: (v) => setState(() => _speciality = v ?? _any),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LoadingButton(
                label: 'Search',
                icon: Icons.search,
                loading: _loading,
                onPressed: _search,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (results == null)
          const SizedBox(
            height: 260,
            child: EmptyState(
              icon: Icons.person_search_outlined,
              message: 'Search by location, sex or speciality to find approved caregivers',
            ),
          )
        else if (results.isEmpty)
          const SizedBox(
            height: 260,
            child: EmptyState(
              icon: Icons.search_off,
              message: 'No caregivers match your search',
            ),
          )
        else
          for (final caregiver in results) ...[
            _CaregiverCard(caregiver: caregiver),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _CaregiverCard extends StatelessWidget {
  const _CaregiverCard({required this.caregiver});

  final Caregiver caregiver;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final match = caregiver.matchPercentage;
    return SectionCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => CaregiverDetailScreen(caregiverId: caregiver.id),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(name: caregiver.name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(caregiver.name,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    Text('${caregiver.location} · ${caregiver.sex}, ${caregiver.age}',
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              if (match != null)
                StatusChip(label: '$match% match', color: theme.colorScheme.primary),
            ],
          ),
          const SizedBox(height: 12),
          TagWrap(tags: caregiver.speciality),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(caregiver.experience, style: theme.textTheme.bodyMedium),
              const Spacer(),
              Text(
                '${Formatters.salary(caregiver.expectedSalary)} / month',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
