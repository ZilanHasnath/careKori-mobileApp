import '../core/network/api_client.dart';
import '../core/utils/json_utils.dart';
import '../models/session.dart';

class AuthService {
  const AuthService(this._api);

  final ApiClient _api;

  Future<Session> login(String identifier, String password) async {
    final json = await _api.post('/api/auth/login', body: {
      'identifier': identifier.trim(),
      'password': password,
    });
    return Session.fromLogin(
      asString(json['role']),
      asMap(json['user']) ?? const {},
    );
  }

  Future<void> registerPatient({
    required String patientName,
    required String phoneNumber,
    required String password,
    required int age,
    required String sex,
    required String location,
    required List<String> illness,
    String? email,
  }) =>
      _api.post('/api/auth/register/patient', body: {
        'patientName': patientName.trim(),
        'phoneNumber': phoneNumber.trim(),
        'email': email,
        'password': password,
        'age': age,
        'sex': sex,
        'location': location.trim(),
        'illness': illness,
      });

  Future<void> registerFamilyMember({
    required String familyMemberName,
    required String phoneNumber,
    required String password,
    required String location,
    String? email,
  }) =>
      _api.post('/api/auth/register/familyMember', body: {
        'familyMemberName': familyMemberName.trim(),
        'phoneNumber': phoneNumber.trim(),
        'email': email,
        'password': password,
        'location': location.trim(),
      });

  Future<void> registerCaregiver({
    required String name,
    required String phoneNumber,
    required String password,
    required String location,
    required double expectedSalary,
    required List<String> speciality,
    required String experience,
    required String sex,
    required int age,
    required String nationalIdPassportNo,
    String? email,
  }) =>
      _api.post('/api/auth/register/caregiver', body: {
        'name': name.trim(),
        'phoneNumber': phoneNumber.trim(),
        'email': email,
        'password': password,
        'location': location.trim(),
        'expectedSalary': expectedSalary,
        'speciality': speciality,
        'experience': experience.trim(),
        'sex': sex,
        'age': age,
        'nationalIdPassportNo': nationalIdPassportNo.trim(),
      });

  Future<void> forgotPassword(String email) =>
      _api.post('/api/auth/forgot-password', body: {'email': email.trim()});

  Future<void> resetPassword(String token, String password) => _api.post(
        '/api/auth/reset-password',
        body: {'token': token.trim(), 'password': password},
      );
}
