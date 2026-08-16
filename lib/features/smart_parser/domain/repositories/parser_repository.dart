import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../../../core/errors/either.dart';
import '../../../../core/errors/app_failure.dart';
import '../entities/order_entity.dart';

abstract class ParserRepository {
  Future<Either<AppFailure, OrderEntity>> analyzeInput({
    required String text,
    required List<PlatformFile> files,
    List<String>? preUploadedUrls,
  });

  Future<Either<AppFailure, void>> saveOrder(OrderEntity order);

  Stream<List<OrderEntity>> getSavedOrders();

  Future<Either<AppFailure, String>> uploadAttachment(
    String orderId,
    File file, {
    Function(double)? onProgress,
  });
}
