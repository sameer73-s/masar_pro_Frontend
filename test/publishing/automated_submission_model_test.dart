import 'package:flutter_test/flutter_test.dart';
import 'package:masar_pro/features/publishing/data/models/automated_submission_model.dart';

void main() {
  group('AutomatedSubmissionJobModel', () {
    test('parses the backend job_id and status', () {
      final model = AutomatedSubmissionJobModel.fromJson({
        'job_id': 'job-123',
        'status': 'QUEUED',
      });

      expect(model.jobId, 'job-123');
      expect(model.toEntity().status, 'QUEUED');
    });
  });

  group('SubmissionProgressUpdateModel', () {
    test('parses flat WebSocket progress events and percent values', () {
      final model = SubmissionProgressUpdateModel.fromEnvelope({
        'type': 'STEP_PROGRESS',
        'state': 'UPLOADING_FILES',
        'message': 'Uploading manuscript',
        'progress': 75,
        'occurred_at': '2026-08-28T10:00:00Z',
      });

      expect(model.state, 'UPLOADING_FILES');
      expect(model.message, 'Uploading manuscript');
      expect(model.progress, closeTo(0.75, 0.0001));
      expect(model.occurredAt, isNotNull);
    });

    test('parses nested human-action events without exposing credentials', () {
      final model = SubmissionProgressUpdateModel.fromEnvelope({
        'data': {
          'state': 'HUMAN_ACTION_REQUIRED',
          'message': 'Complete the challenge in the browser',
          'challenge_type': 'CAPTCHA',
        },
      });

      final entity = model.toEntity();
      expect(entity.isHumanActionRequired, isTrue);
      expect(entity.challengeType, 'CAPTCHA');
      expect(entity.message, isNot(contains('password')));
    });
  });
}
