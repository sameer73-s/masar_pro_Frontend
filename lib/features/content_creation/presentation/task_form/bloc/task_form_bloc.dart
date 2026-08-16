import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import '../../../domain/entities/content_entity.dart';
import '../../../domain/repositories/content_creation_repository.dart';
import '../../../domain/usecases/create_content_usecase.dart';
import '../../../domain/usecases/extract_text_usecase.dart';

part 'task_form_event.dart';
part 'task_form_state.dart';

class TaskFormBloc extends Bloc<TaskFormEvent, TaskFormState> {
  final CreateContentUseCase createContentUseCase;
  final ExtractTextUseCase extractTextUseCase;
  final ContentCreationRepository repository;

  TaskFormBloc({
    required this.createContentUseCase,
    required this.extractTextUseCase,
    required this.repository,
  }) : super(TaskFormInitial()) {
    on<CreateContentRequested>(_onCreateContentRequested);
    on<ExtractTextRequested>(_onExtractTextRequested);
    on<UploadReferenceFileRequested>(_onUploadReferenceFileRequested);
    on<GenerateContentRequested>(_onGenerateContentRequested);
    on<_UploadProgressUpdatedInternal>(_onUploadProgressUpdatedInternal);
  }

  Future<void> _onCreateContentRequested(CreateContentRequested event, Emitter<TaskFormState> emit) async {
    emit(ContentCreationLoading());
    final result = await createContentUseCase(
      CreateContentParams(
        taskType: event.taskType,
        title: event.title,
        optionalFields: event.optionalFields,
      ),
    );
    result.fold(
      (failure) => emit(ContentCreationFailure(failure.message)),
      (data) => emit(ContentCreationSuccess(data)),
    );
  }

  Future<void> _onExtractTextRequested(ExtractTextRequested event, Emitter<TaskFormState> emit) async {
    emit(TextExtractionLoading());
    final result = await extractTextUseCase(event.file);
    result.fold(
      (failure) => emit(ContentCreationFailure(failure.message)),
      (data) => emit(TextExtractionSuccess(data)),
    );
  }

  Future<void> _onUploadReferenceFileRequested(UploadReferenceFileRequested event, Emitter<TaskFormState> emit) async {
    emit(const UploadInProgress(0.0));
    final result = await repository.uploadReferenceFile(
      event.contentId,
      event.file,
      onProgress: (progress) {
        add(_UploadProgressUpdatedInternal(progress));
      },
    );
    result.fold(
      (failure) => emit(UploadFailure(failure.message)),
      (data) => emit(UploadSuccess(data)),
    );
  }

  void _onUploadProgressUpdatedInternal(_UploadProgressUpdatedInternal event, Emitter<TaskFormState> emit) {
    emit(UploadInProgress(event.progress));
  }

  Future<void> _onGenerateContentRequested(GenerateContentRequested event, Emitter<TaskFormState> emit) async {
    emit(ContentCreationLoading());
    final result = await repository.generateAndSaveContent(
      contentId: event.contentId,
      taskType: event.taskType,
      title: event.title,
      promptDetails: event.promptDetails,
      referenceFiles: event.referenceFiles,
    );
    result.fold(
      (failure) {
        emit(ContentCreationFailure(failure.message));
      },
      (data) {
        emit(ContentGenerationSuccess(data.content, data.rawResult, event.taskType, event.title));
      },
    );
  }
}
