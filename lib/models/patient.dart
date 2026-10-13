import '../core/utils/json_utils.dart';
import 'family_member.dart';

class Patient {
  const Patient({
    required this.id,
    required this.uniqueId,
    required this.patientName,
    required this.phoneNumber,
    required this.age,
    required this.sex,
    required this.location,
    required this.illness,
    this.email,
    this.linkedFamilyMemberIds = const [],
    this.linkedFamilyMembers = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    final linked = json['linkedFamilyMembers'] is List
        ? json['linkedFamilyMembers'] as List
        : const [];
    return Patient(
      id: asString(json['_id']),
      uniqueId: asString(json['uniqueId']),
      patientName: asString(json['patientName'] ?? json['name']),
      phoneNumber: asString(json['phoneNumber']),
      email: asNullableString(json['email']),
      age: asInt(json['age']),
      sex: asString(json['sex']),
      location: asString(json['location']),
      illness: asStringList(json['illness']),
      linkedFamilyMemberIds: linked.map(idOf).toList(),
      linkedFamilyMembers:
          asMapList(linked).map(FamilyMember.fromJson).toList(),
      createdAt: asDate(json['createdAt']),
      updatedAt: asDate(json['updatedAt']),
    );
  }

  final String id;
  final String uniqueId;
  final String patientName;
  final String phoneNumber;
  final String? email;
  final int age;
  final String sex;
  final String location;
  final List<String> illness;
  final List<String> linkedFamilyMemberIds;
  final List<FamilyMember> linkedFamilyMembers;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get displayName {
    if (patientName.isNotEmpty) return patientName;
    return phoneNumber.isNotEmpty ? phoneNumber : 'Patient';
  }
}
