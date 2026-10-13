import '../core/network/api_client.dart';
import '../core/utils/json_utils.dart';
import '../models/admin.dart';
import '../models/caregiver.dart';
import '../models/family_member.dart';
import '../models/job.dart';
import '../models/job_status.dart';
import '../models/patient.dart';

class AdminService {
  const AdminService(this._api);

  final ApiClient _api;

  Future<Admin> profile(String email) async {
    final json = await _api
        .get('/api/admin/profile', headers: {'x-admin-email': email});
    return Admin.fromJson(json);
  }

  Future<List<Admin>> admins() async {
    final json = await _api.get('/api/admin/getall');
    return asMapList(json['data']).map(Admin.fromJson).toList();
  }

  Future<void> deleteAdmin(String id) => _api.delete('/api/admin/$id');

  Future<List<Caregiver>> caregivers({String? accountType}) async {
    final json =
        await _api.get('/api/admin/caregiver', query: {'accountType': accountType});
    return asMapList(json['data']).map(Caregiver.fromJson).toList();
  }

  Future<void> approveCaregiver(String id) =>
      _api.put('/api/admin/caregiver/$id', body: {'accountType': 'Approved'});

  Future<void> deleteCaregiver(String id) => _api.delete('/api/admin/caregiver/$id');

  Future<List<Patient>> patients() async {
    final json = await _api.get('/api/admin/patient');
    return asMapList(json['data']).map(Patient.fromJson).toList();
  }

  Future<Patient> patient(String id) async {
    final json = await _api.get('/api/admin/patient/$id');
    return Patient.fromJson(asMap(json['data']) ?? const {});
  }

  Future<void> deletePatient(String id) => _api.delete('/api/admin/patient/$id');

  Future<List<FamilyMember>> families() async {
    final json = await _api.get('/api/admin/family');
    return asMapList(json['data']).map(FamilyMember.fromJson).toList();
  }

  Future<FamilyMember> family(String id) async {
    final json = await _api.get('/api/admin/family/$id');
    return FamilyMember.fromJson(asMap(json['data']) ?? const {});
  }

  Future<void> deleteFamily(String id) => _api.delete('/api/admin/family/$id');

  Future<List<Job>> jobs({String? status}) async {
    final json = await _api.get('/api/admin/job', query: {'status': status});
    return asMapList(json['data']).map(Job.fromJson).toList();
  }

  Future<void> updateJobStatus(String id, JobStatus status) =>
      _api.put('/api/admin/job/$id', body: {'status': status.wire});

  Future<void> deleteJob(String id) => _api.delete('/api/admin/job/$id');
}
