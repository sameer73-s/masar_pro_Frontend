import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/errors/either.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/base/base_repository.dart';
import '../../../../network_service/network_service.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/parser_repository.dart';
import '../datasources/parser_local_data_source.dart';
import '../datasources/parser_firestore_datasource.dart';
import '../datasources/parser_remote_data_source.dart';
import '../models/order_model.dart';

class ParserRepositoryImpl extends BaseRepository implements ParserRepository {
  final ParserRemoteDataSource remoteDataSource;
  final ParserLocalDataSource localDataSource;
  final ParserFirestoreDataSource firestoreDataSource;

  ParserRepositoryImpl({
    required NetworkService networkService,
    required this.remoteDataSource,
    required this.localDataSource,
    required this.firestoreDataSource,
  }) : super(networkService: networkService);

  @override
  Future<Either<AppFailure, OrderEntity>> analyzeInput({
    required String text,
    required List<PlatformFile> files,
    List<String>? preUploadedUrls,
  }) async {
    return guardedCall(() async {
      try {
        final result = await remoteDataSource.analyzeInput(
          text: text,
          files: files,
          preUploadedUrls: preUploadedUrls,
        );
        return result.fold(
          (failure) => Either.left(failure),
          (model) => Either.right(model),
        );
      } catch (e) {
        return Either.left(AppFailure.server(message: e.toString()));
      }
    });
  }

  @override
  Future<Either<AppFailure, void>> saveOrder(OrderEntity order) async {
    return guardedCall(() async {
      final model = OrderModel.fromEntity(order);
      debugPrint('[DEBUG] ParserRepositoryImpl.saveOrder: Saving order ${order.id} to Firestore and local storage');
      try {
        await firestoreDataSource.createOrder(model);
        debugPrint('[DEBUG] ParserRepositoryImpl.saveOrder: Order ${order.id} successfully saved to Firestore');
        await localDataSource.saveOrder(model);
        return Either.right(null);
      } catch (e) {
        debugPrint('[DEBUG] ParserRepositoryImpl.saveOrder: Failed to save to Firestore: $e');
        return Either.left(AppFailure.server(message: 'فشل حفظ الطلب في السحابة: $e'));
      }
    });
  }

  @override
  Stream<List<OrderEntity>> getSavedOrders() {
    return firestoreDataSource.getOrdersStream().map((models) => models.cast<OrderEntity>().toList());
  }

  @override
  Future<Either<AppFailure, String>> uploadAttachment(
    String orderId,
    File file, {
    Function(double)? onProgress,
  }) async {
    return guardedCall(() async {
      try {
        final result = await firestoreDataSource.uploadAttachmentAndLink(
          orderId,
          file,
          onProgress: onProgress,
        );
        return Either.right(result);
      } catch (e) {
        return Either.left(AppFailure.server(message: e.toString()));
      }
    });
  }
}
