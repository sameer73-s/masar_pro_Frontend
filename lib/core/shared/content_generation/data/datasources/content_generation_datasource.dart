import 'package:flutter/foundation.dart';

import '../../../../network/api_client.dart';
import '../../../../network/api_headers.dart';
import '../../domain/exceptions/content_generation_exceptions.dart';

abstract class ContentGenerationDataSource {
  Future<Map<String, dynamic>> generateContent({
    required String orderId,
    required Map<String, dynamic> formValues,
    required Map<String, dynamic> orderData,
  });
}

class ContentGenerationDataSourceImpl implements ContentGenerationDataSource {
  ContentGenerationDataSourceImpl();

  @override
  Future<Map<String, dynamic>> generateContent({
    required String orderId,
    required Map<String, dynamic> formValues,
    required Map<String, dynamic> orderData,
  }) async {
    try {
      final payload = {
        'task_type': orderData['task_type'] ?? orderData['task_type_key'] ?? '',
        'title': orderData['subject'] ?? orderData['title'] ?? '',
        'optional_fields': formValues,
      };

      final headers = await ApiHeaders.authenticatedAsync();
      final hasAuth = headers.containsKey('Authorization');
      debugPrint(
        '[ContentGeneration] POST /api/v1/create-content '
        'auth=$hasAuth task_type=${payload['task_type']}',
      );

      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '/api/v1/create-content',
        headers: headers,
        body: payload,
      );

      return response.fold(
        (failure) {
          final message = failure.message;
          if (failure.statusCode == 422) {
            throw PlagiarismRejectedException(
              message.isNotEmpty
                  ? message
                  : 'تم رفض توليد المحتوى بسبب عدم اجتياز فحص الانتحال والسرقة العلمية.',
            );
          }
          throw ServerException(
            message.isNotEmpty
                ? message
                : 'Failed to generate content. Status code: ${failure.statusCode}',
          );
        },
        (data) => Map<String, dynamic>.from(data as Map),
      );
    } on PlagiarismRejectedException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
