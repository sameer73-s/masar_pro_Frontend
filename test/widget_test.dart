import 'package:flutter_test/flutter_test.dart';

import 'package:masar_pro/core/network/api_client.dart';
import 'package:masar_pro/features/agency/domain/enums/task_status.dart';

void main() {
  group('Masar Pro core smoke tests', () {
    test('buildRequestUri joins the configured API root safely', () {
      final uri = ApiClient.buildRequestUri(
        serverURL: 'https://masar-pro-backend.onrender.com/',
        endPoint: '/api/v1/tasks',
      );

      expect(
        uri.toString(),
        'https://masar-pro-backend.onrender.com/api/v1/tasks',
      );
    });

    test('TaskStatus maps backend wire values without losing states', () {
      expect(
        TaskStatus.fromApi('PENDING_APPROVAL'),
        TaskStatus.pendingApproval,
      );
      expect(TaskStatus.fromApi('PROCESSING'), TaskStatus.processing);
      expect(TaskStatus.fromApi('COMPLETED'), TaskStatus.completed);
      expect(TaskStatus.completed.apiValue, 'COMPLETED');
    });
  });
}
