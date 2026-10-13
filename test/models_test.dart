import 'package:carekori/core/utils/validators.dart';
import 'package:carekori/models/job.dart';
import 'package:carekori/models/job_status.dart';
import 'package:carekori/models/patient.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Job.fromJson', () {
    test('parses populated references', () {
      final job = Job.fromJson({
        '_id': 'j1',
        'status': 'Active',
        'dateTime': '2026-01-01T10:00:00.000Z',
        'patientId': {'_id': 'p1', 'patientName': 'Rahim', 'phoneNumber': '01712345678'},
        'caregiverId': {'_id': 'c1', 'name': 'Karim'},
      });
      expect(job.status, JobStatus.active);
      expect(job.patientId, 'p1');
      expect(job.caregiverId, 'c1');
      expect(job.patient?.patientName, 'Rahim');
      expect(job.caregiver?.name, 'Karim');
    });

    test('parses plain object ids', () {
      final job = Job.fromJson({'_id': 'j1', 'status': 'pending', 'patientId': 'p1', 'caregiverId': 'c1'});
      expect(job.patient, isNull);
      expect(job.patientId, 'p1');
    });
  });

  group('Patient.fromJson', () {
    test('falls back to phone number for display name', () {
      final patient = Patient.fromJson({'_id': 'p1', 'phoneNumber': '01712345678'});
      expect(patient.displayName, '01712345678');
    });
  });

  group('Validators', () {
    test('accepts Bangladeshi phone numbers', () {
      expect(Validators.phone('01712345678'), isNull);
      expect(Validators.phone('+8801712345678'), isNull);
      expect(Validators.phone('12345'), isNotNull);
    });

    test('email is optional when allowed', () {
      expect(Validators.optionalEmail(''), isNull);
      expect(Validators.optionalEmail('bad'), isNotNull);
    });
  });
}
