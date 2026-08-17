import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_headers.dart';

import '../../../../core/errors/either.dart';
import '../../../../core/errors/app_failure.dart';
import '../models/order_model.dart';
import 'parser_firestore_datasource.dart';

abstract class ParserRemoteDataSource {
  Future<Either<AppFailure, OrderModel>> analyzeInput({
    required String text,
    required List<PlatformFile> files,
    List<String>? preUploadedUrls,
  });
}

class ParserRemoteDataSourceImpl implements ParserRemoteDataSource {
  final ParserFirestoreDataSource firestoreDataSource;

  ParserRemoteDataSourceImpl({
    required this.firestoreDataSource,
  });

  @override
  Future<Either<AppFailure, OrderModel>> analyzeInput({
    required String text,
    required List<PlatformFile> files,
    List<String>? preUploadedUrls,
  }) async {
    try {
      // 1. Generate document ID beforehand using Firestore
      final orderId = FirebaseFirestore.instance.collection('orders').doc().id;

      // 2. Upload attachments first and get their secure Cloudinary URLs
      final List<String> fileUrls = List<String>.from(preUploadedUrls ?? []);
      for (final file in files) {
        if (file.path != null) {
          final secureUrl = await firestoreDataSource.uploadAttachmentAndLink(
            orderId,
            File(file.path!),
          );
          fileUrls.add(secureUrl);
        }
      }

      // 3. Post URLs to backend analyze endpoint using ApiClient
      FormData formData = FormData.fromMap({
        'text': text,
        'file_urls': fileUrls,
      });

      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '/analyze',
        headers: await ApiHeaders.authenticatedAsync(),
        body: formData,
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) {
          if (data is! Map) {
            return Either.left(
              AppFailure.server(
                message: 'AI processing failed. Please try again.',
                statusCode: 502,
              ),
            );
          }

          final payload = Map<String, dynamic>.from(data);
          final status = payload['status']?.toString();
          final subject = payload['subject']?.toString() ?? '';
          if (status == 'error' || subject == 'AI Processing Failed') {
            final detail = payload['missing_info']?.toString().trim();
            return Either.left(
              AppFailure.server(
                message: (detail != null && detail.isNotEmpty)
                    ? detail
                    : 'AI processing failed. Please try again.',
                statusCode: 502,
              ),
            );
          }

          final analyzedOrder = OrderModel.fromJson(payload);

          final orderModel = OrderModel(
            id: orderId,
            subject: analyzedOrder.subject,
            taskType: analyzedOrder.taskType,
            deadline: analyzedOrder.deadline,
            status: analyzedOrder.status,
            attachments: fileUrls,
            missingInfo: analyzedOrder.missingInfo,
            taskNameAr: analyzedOrder.taskNameAr,
            isReady: analyzedOrder.isReady,
            dynamicMissingFields: analyzedOrder.dynamicMissingFields,
            generatedContentUrl: analyzedOrder.generatedContentUrl,
            createdAt: analyzedOrder.createdAt,
            updatedAt: analyzedOrder.updatedAt,
            userId: analyzedOrder.userId,
          );
          return Either.right(orderModel);
        }
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }
}
