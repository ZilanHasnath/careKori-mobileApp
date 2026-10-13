import '../core/utils/json_utils.dart';
import 'caregiver.dart';
import 'job_status.dart';
import 'patient.dart';

class Job {
  const Job({
    required this.id,
    required this.patientId,
    required this.caregiverId,
    required this.status,
    required this.dateTime,
    this.patient,
    this.caregiver,
    this.createdAt,
    this.updatedAt,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    final patient = asMap(json['patientId']);
    final caregiver = asMap(json['caregiverId']);
    return Job(
      id: asString(json['_id']),
      patientId: idOf(json['patientId']),
      caregiverId: idOf(json['caregiverId']),
      status: JobStatus.parse(json['status']),
      dateTime: asDate(json['dateTime']) ?? DateTime.now(),
      patient: patient == null ? null : Patient.fromJson(patient),
      caregiver: caregiver == null ? null : Caregiver.fromJson(caregiver),
      createdAt: asDate(json['createdAt']),
      updatedAt: asDate(json['updatedAt']),
    );
  }

  final String id;
  final String patientId;
  final String caregiverId;
  final JobStatus status;
  final DateTime dateTime;
  final Patient? patient;
  final Caregiver? caregiver;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
