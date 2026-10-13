import '../core/network/api_client.dart';
import '../core/utils/json_utils.dart';
import '../models/caregiver.dart';
import '../models/job.dart';
import '../models/job_status.dart';
import '../models/patient_progress.dart';

class CaregiverService {
  const CaregiverService(this._api);

  final ApiClient _api;

  Future<Caregiver> profile(String id) async {
    final json = await _api.get('/api/caregiver/profile', query: {'id': id});
    return Caregiver.fromJson(asMap(json['profile']) ?? const {});
  }

  Future<Caregiver> updateProfile({
    required String id,
    required String name,
    required String phoneNumber,
    required String location,
    String? email,
  }) async {
    final json = await _api.put('/api/caregiver/profile', body: {
      'id': id,
      'name': name.trim(),
      'phoneNumber': phoneNumber.trim(),
      'email': email,
      'location': location.trim(),
    });
    return Caregiver.fromJson(asMap(json['profile']) ?? const {});
  }

  Future<List<Job>> myJobs(String caregiverId) async {
    final json =
        await _api.get('/api/caregiver/myjobs', query: {'caregiverId': caregiverId});
    return asMapList(json['jobs']).map(Job.fromJson).toList();
  }

  Future<void> acceptJob(String jobId) =>
      _api.patch('/api/caregiver/jobs/accept', body: {'jobId': jobId});

  Future<void> updateJobStatus(String jobId, JobStatus status) => _api.put(
        '/api/caregiver/updateJobStatus',
        body: {'jobId': jobId, 'status': status.wire},
      );

  Future<void> addProgress({
    required String jobId,
    required String caregiverId,
    required String patientId,
    required String bloodPressure,
    required int heartRate,
    required String meals,
    required String exercise,
    required String medicineStatus,
    required String patientMood,
    required String note,
  }) =>
      _api.post('/api/caregiver/addprogress', body: {
        'jobId': jobId,
        'caregiverId': caregiverId,
        'patientId': patientId,
        'bloodPressure': bloodPressure.trim(),
        'heartRate': heartRate,
        'meals': meals.trim(),
        'exercise': exercise.trim(),
        'medicineStatus': medicineStatus.trim(),
        'patientMood': patientMood.trim(),
        'note': note.trim(),
      });

  Future<List<PatientProgress>> patientHistory({
    required String patientId,
    required String caregiverId,
  }) async {
    final json = await _api.get('/api/caregiver/patient/history', query: {
      'patientId': patientId,
      'caregiverId': caregiverId,
    });
    return asMapList(json['history']).map(PatientProgress.fromJson).toList();
  }
}
