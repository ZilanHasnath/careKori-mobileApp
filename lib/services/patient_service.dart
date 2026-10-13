import '../core/network/api_client.dart';
import '../core/utils/json_utils.dart';
import '../models/caregiver.dart';
import '../models/family_member.dart';
import '../models/job.dart';
import '../models/patient.dart';
import '../models/patient_progress.dart';

class PatientService {
  const PatientService(this._api);

  final ApiClient _api;

  Future<Patient> profile(String id) async {
    final json = await _api.get('/api/patient/profile', query: {'id': id});
    return Patient.fromJson(asMap(json['patient']) ?? const {});
  }

  Future<Patient> updateProfile({
    required String id,
    required String patientName,
    required String phoneNumber,
    required int age,
    required String sex,
    required String location,
    required List<String> illness,
    String? email,
  }) async {
    final json = await _api.put('/api/patient/profile', body: {
      'id': id,
      'patientName': patientName.trim(),
      'phoneNumber': phoneNumber.trim(),
      'email': email,
      'age': age,
      'sex': sex,
      'location': location.trim(),
      'illness': illness,
    });
    return Patient.fromJson(asMap(json['patient']) ?? const {});
  }

  Future<List<Caregiver>> searchCaregivers({
    String? location,
    String? sex,
    String? speciality,
  }) async {
    final json = await _api.get('/api/patient/SearchCaregiver', query: {
      'location': location?.trim(),
      'sex': sex,
      'speciality': speciality,
    });
    return asMapList(json['data']).map(Caregiver.fromJson).toList();
  }

  Future<Caregiver> caregiver(String id) async {
    final json = await _api.get('/api/patient/CareGiver/$id');
    return Caregiver.fromJson(asMap(json['caregiver']) ?? const {});
  }

  Future<void> requestJob({
    required String patientId,
    required String caregiverId,
    DateTime? dateTime,
  }) =>
      _api.post('/api/patient/requestJob', body: {
        'patientId': patientId,
        'caregiverId': caregiverId,
        if (dateTime != null) 'dateTime': dateTime.toUtc().toIso8601String(),
      });

  Future<List<Job>> myRequests(String patientId) async {
    final json =
        await _api.get('/api/patient/myrequests', query: {'patientId': patientId});
    return asMapList(json['requests']).map(Job.fromJson).toList();
  }

  Future<List<PatientProgress>> myProgress(String patientId) async {
    final json =
        await _api.get('/api/patient/myprogress', query: {'patientId': patientId});
    return asMapList(json['progress']).map(PatientProgress.fromJson).toList();
  }

  Future<List<FamilyMember>> connectedFamily(String patientId) async {
    final json = await _api
        .get('/api/patient/family/connected', query: {'patientId': patientId});
    return asMapList(json['familyMembers']).map(FamilyMember.fromJson).toList();
  }
}
