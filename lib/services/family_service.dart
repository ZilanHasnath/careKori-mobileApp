import '../core/network/api_client.dart';
import '../core/utils/json_utils.dart';
import '../models/family_member.dart';
import '../models/patient.dart';
import '../models/patient_progress.dart';

class FamilyService {
  const FamilyService(this._api);

  final ApiClient _api;

  Future<FamilyMember> profile(String id) async {
    final json = await _api.get('/api/family/profile', query: {'id': id});
    return FamilyMember.fromJson(asMap(json['profile']) ?? const {});
  }

  Future<FamilyMember> updateProfile({
    required String id,
    required String phoneNumber,
    String? email,
  }) async {
    final json = await _api.put('/api/family/profile', body: {
      'id': id,
      'phoneNumber': phoneNumber.trim(),
      'email': email,
    });
    return FamilyMember.fromJson(asMap(json['profile']) ?? const {});
  }

  Future<List<Patient>> myPatients(String familyMemberId) async {
    final json = await _api
        .get('/api/family/mypatient', query: {'familyMemberId': familyMemberId});
    return asMapList(json['patients']).map(Patient.fromJson).toList();
  }

  Future<void> linkPatient({
    required String familyMemberId,
    required String uniqueId,
  }) =>
      _api.post('/api/family/mypatient', body: {
        'familyMemberId': familyMemberId,
        'uniqueId': uniqueId.trim(),
      });

  Future<List<PatientProgress>> patientProgress(String patientId) async {
    final json = await _api
        .get('/api/family/patientprogress', query: {'patientId': patientId});
    return asMapList(json['logs']).map(PatientProgress.fromJson).toList();
  }
}
