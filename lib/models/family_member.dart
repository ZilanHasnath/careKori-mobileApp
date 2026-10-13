import '../core/utils/json_utils.dart';
import 'patient.dart';

class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.familyMemberName,
    required this.phoneNumber,
    required this.location,
    this.email,
    this.linkedPatientIds = const [],
    this.linkedPatients = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    final linked =
        json['linkedPatient'] is List ? json['linkedPatient'] as List : const [];
    return FamilyMember(
      id: asString(json['_id']),
      familyMemberName: asString(json['familyMemberName'] ?? json['name']),
      phoneNumber: asString(json['phoneNumber']),
      email: asNullableString(json['email']),
      location: asString(json['location']),
      linkedPatientIds: linked.map(idOf).toList(),
      linkedPatients: asMapList(linked).map(Patient.fromJson).toList(),
      createdAt: asDate(json['createdAt']),
      updatedAt: asDate(json['updatedAt']),
    );
  }

  final String id;
  final String familyMemberName;
  final String phoneNumber;
  final String? email;
  final String location;
  final List<String> linkedPatientIds;
  final List<Patient> linkedPatients;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
