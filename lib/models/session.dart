import 'dart:convert';

import '../core/utils/json_utils.dart';

enum UserRole { patient, family, caregiver, admin }

class Session {
  const Session({required this.role, required this.roleLabel, required this.user});

  factory Session.fromLogin(String wireRole, Map<String, dynamic> user) => Session(
        role: _parseRole(wireRole),
        roleLabel: wireRole,
        user: user,
      );

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        role: _parseRole(asString(json['roleLabel'])),
        roleLabel: asString(json['roleLabel']),
        user: asMap(json['user']) ?? const {},
      );

  factory Session.decode(String raw) =>
      Session.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  final UserRole role;
  final String roleLabel;
  final Map<String, dynamic> user;

  String get id => asString(user['_id']);

  String get name => asString(
        user['patientName'] ?? user['familyMemberName'] ?? user['name'],
        'User',
      );

  String? get email => asNullableString(user['email']);

  String get uniqueId => asString(user['uniqueId']);

  Session copyWith({Map<String, dynamic>? user}) =>
      Session(role: role, roleLabel: roleLabel, user: user ?? this.user);

  Map<String, dynamic> toJson() => {'roleLabel': roleLabel, 'user': user};

  String encode() => jsonEncode(toJson());

  static UserRole _parseRole(String wire) => switch (wire) {
        'patient' => UserRole.patient,
        'family' => UserRole.family,
        'caregiver' => UserRole.caregiver,
        _ => UserRole.admin,
      };
}
