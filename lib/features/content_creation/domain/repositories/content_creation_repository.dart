import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../../../core/errors/either.dart';
import '../../../../core/errors/app_failure.dart';
import '../entities/content_entity.dart';

abstract class ContentCreationRepository {
  Stream<List<ContentEntity>> getSavedContents();

  Future<Either<AppFailure, String>> uploadReferenceFile(
    String contentId,
    File file, {
    Function(double)? onProgress,
  });

  Future<Either<AppFailure, ContentGenerationResult>> generateAndSaveContent({
    required String contentId,
    required String taskType,
    required String title,
    required PromptDetailsEntity promptDetails,
    required List<String> referenceFiles,
  });

  Future<Either<AppFailure, Map<String, dynamic>>> createContent({
    required String taskType,
    required String title,
    required Map<String, dynamic> optionalFields,
  });

  Future<Either<AppFailure, String>> extractText(PlatformFile file);

  Future<Either<AppFailure, Map<String, dynamic>>> checkThenHumanize({
    required String text,
    required bool isArabic,
    required bool useGemini,
  });
}
