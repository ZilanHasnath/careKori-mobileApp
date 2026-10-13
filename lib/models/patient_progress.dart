import '../core/utils/json_utils.dart';
import 'patient.dart';

class PatientProgress {
  const PatientProgress({
    required this.id,
    required this.jobId,
    required this.caregiverId,
    required this.patientId,
    required this.bloodPressure,
    required this.heartRate,
    required this.meals,
    required this.exercise,
    required this.medicineStatus,
    required this.patientMood,
    required this.note,
    required this.dateTime,
    this.patient,
  });

  factory PatientProgress.fromJson(Map<String, dynamic> json) {
    final patient = asMap(json['patientId']);
    return PatientProgress(
      id: asString(json['_id']),
      jobId: idOf(json['jobId']),
      caregiverId: idOf(json['caregiverId']),
      patientId: idOf(json['patientId']),
      bloodPressure: asString(json['bloodPressure']),
      heartRate: asInt(json['heartRate']),
      meals: asString(json['meals']),
      exercise: asString(json['exercise']),
      medicineStatus: asString(json['medicineStatus']),
      patientMood: asString(json['patientMood']),
      note: asString(json['note']),
      dateTime:
          asDate(json['dateTime']) ?? asDate(json['createdAt']) ?? DateTime.now(),
      patient: patient == null ? null : Patient.fromJson(patient),
    );
  }

  final String id;
  final String jobId;
  final String caregiverId;
  final String patientId;
  final String bloodPressure;
  final int heartRate;
  final String meals;
  final String exercise;
  final String medicineStatus;
  final String patientMood;
  final String note;
  final DateTime dateTime;
  final Patient? patient;
}
