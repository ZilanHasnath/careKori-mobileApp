import '../core/utils/json_utils.dart';

class Caregiver {
  const Caregiver({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.location,
    required this.expectedSalary,
    required this.experience,
    required this.sex,
    required this.age,
    required this.nationalIdPassportNo,
    required this.speciality,
    required this.accountType,
    this.email,
    this.matchPercentage,
    this.createdAt,
    this.updatedAt,
  });

  factory Caregiver.fromJson(Map<String, dynamic> json) => Caregiver(
        id: asString(json['_id']),
        name: asString(json['name']),
        phoneNumber: asString(json['phoneNumber']),
        email: asNullableString(json['email']),
        location: asString(json['location']),
        expectedSalary: asDouble(json['expectedSalary']),
        experience: asString(json['experience']),
        sex: asString(json['sex']),
        age: asInt(json['age']),
        nationalIdPassportNo: asString(json['nationalIdPassportNo']),
        speciality: asStringList(json['speciality']),
        accountType: asString(json['accountType'], 'Pending'),
        matchPercentage:
            json['matchPercentage'] == null ? null : asInt(json['matchPercentage']),
        createdAt: asDate(json['createdAt']),
        updatedAt: asDate(json['updatedAt']),
      );

  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final String location;
  final double expectedSalary;
  final String experience;
  final String sex;
  final int age;
  final String nationalIdPassportNo;
  final List<String> speciality;
  final String accountType;
  final int? matchPercentage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isApproved => accountType == 'Approved';
}
