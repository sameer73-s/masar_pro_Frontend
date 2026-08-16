import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/errors/either.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/base/base_repository.dart';
import '../../../../network_service/network_service.dart';
import '../../../../core/shared/content_generation/domain/usecases/generate_content_usecase.dart';
import '../../../../core/shared/content_generation/domain/exceptions/content_generation_exceptions.dart';
import '../../domain/entities/content_entity.dart';
import '../../domain/repositories/content_creation_repository.dart';
import '../datasources/content_firestore_datasource.dart';
import '../datasources/content_creation_remote_data_source.dart' as remote_ds;
import '../models/content_model.dart';

class ContentCreationRepositoryImpl extends BaseRepository implements ContentCreationRepository {
  final ContentFirestoreDataSource firestoreDataSource;
  final GenerateContentUseCase generateContentUseCase;
  final remote_ds.ContentCreationRemoteDataSource remoteDataSource;

  ContentCreationRepositoryImpl({
    required NetworkService networkService,
    required this.firestoreDataSource,
    required this.generateContentUseCase,
    required this.remoteDataSource,
  }) : super(networkService: networkService);

  @override
  Stream<List<ContentEntity>> getSavedContents() {
    return firestoreDataSource
        .getContentsStream()
        .map((models) => models.cast<ContentEntity>().toList());
  }

  @override
  Future<Either<AppFailure, String>> uploadReferenceFile(
    String contentId,
    File file, {
    Function(double)? onProgress,
  }) async {
    return guardedCall(() async {
      try {
        final result = await firestoreDataSource.uploadReferenceFileAndLink(
          contentId,
          file,
          onProgress: onProgress,
        );
        return Either.right(result);
      } catch (e) {
        return Either.left(AppFailure.server(message: e.toString()));
      }
    });
  }

  @override
  Future<Either<AppFailure, ContentGenerationResult>> generateAndSaveContent({
    required String contentId,
    required String taskType,
    required String title,
    required PromptDetailsEntity promptDetails,
    required List<String> referenceFiles,
  }) async {
    return guardedCall(() async {
      final formValues = {
        'prompt': promptDetails.prompt,
        'tone': promptDetails.tone,
        'keywords': promptDetails.keywords,
        'additional_context': promptDetails.additionalContext,
      };

      final orderData = {
        'subject': title,
        'task_type': taskType,
      };

      try {
        debugPrint('[DEBUG] ContentCreationRepositoryImpl: Calling generateContentUseCase for $contentId');
        final result = await generateContentUseCase(
          GenerateContentParams(
            orderId: contentId,
            formValues: formValues,
            orderData: orderData,
          ),
        );

        String generatedText = '';
        if (result['humanization_result'] != null && result['humanization_result']['humanized_text'] != null) {
          generatedText = result['humanization_result']['humanized_text'].toString();
        } else if (result['generation_result'] != null && result['generation_result']['content'] != null) {
          generatedText = result['generation_result']['content'].toString();
        } else if (result['content'] != null) {
          generatedText = result['content'].toString();
        }

        final contentModel = ContentModel(
          id: contentId,
          taskType: taskType,
          title: title,
          promptDetails: PromptDetailsModel(
            prompt: promptDetails.prompt,
            tone: promptDetails.tone,
            keywords: promptDetails.keywords,
            additionalContext: promptDetails.additionalContext,
          ),
          referenceFiles: referenceFiles,
          generatedText: generatedText,
          createdAt: DateTime.now(),
        );

        debugPrint('[DEBUG] ContentCreationRepositoryImpl: Saving generated content $contentId to Firestore');
        await firestoreDataSource.createContent(contentModel);
        debugPrint('[DEBUG] ContentCreationRepositoryImpl: Saved generated content $contentId successfully');

        return Either.right(ContentGenerationResult(content: contentModel, rawResult: result));
      } on PlagiarismRejectedException catch (e) {
        debugPrint('[DEBUG] ContentCreationRepositoryImpl: Plagiarism check failed: ${e.message}');
        return Either.left(AppFailure.server(message: e.message)); // Handling Plagiarism as Server Failure or custom failure
      } catch (e) {
        debugPrint('[DEBUG] ContentCreationRepositoryImpl: Unexpected error: $e');
        return Either.left(AppFailure.server(message: e.toString()));
      }
    });
  }

  @override
  Future<Either<AppFailure, Map<String, dynamic>>> createContent({
    required String taskType,
    required String title,
    required Map<String, dynamic> optionalFields,
  }) async {
    return guardedCall(() async {
      final result = await remoteDataSource.createContent(
        taskType: taskType,
        title: title,
        optionalFields: optionalFields,
      );
      return result;
    });
  }

  @override
  Future<Either<AppFailure, String>> extractText(PlatformFile file) async {
    return guardedCall(() async {
      return await remoteDataSource.extractText(file);
    });
  }

  @override
  Future<Either<AppFailure, Map<String, dynamic>>> checkThenHumanize({
    required String text,
    required bool isArabic,
    required bool useGemini,
  }) async {
    return guardedCall(() async {
      return await remoteDataSource.checkThenHumanize(
        text: text,
        isArabic: isArabic,
        useGemini: useGemini,
      );
    });
  }
}
