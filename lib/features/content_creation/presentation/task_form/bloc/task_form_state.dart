part of 'task_form_bloc.dart';

abstract class TaskFormState extends Equatable {
  const TaskFormState();
  @override
  List<Object?> get props => [];
}

class TaskFormInitial extends TaskFormState {}

class ContentCreationLoading extends TaskFormState {}

class ContentCreationSuccess extends TaskFormState {
  final Map<String, dynamic> result;
  const ContentCreationSuccess(this.result);
  @override
  List<Object?> get props => [result];
}

class ContentCreationFailure extends TaskFormState {
  final String message;
  const ContentCreationFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class TextExtractionLoading extends TaskFormState {}

class TextExtractionSuccess extends TaskFormState {
  final String extractedText;
  const TextExtractionSuccess(this.extractedText);
  @override
  List<Object?> get props => [extractedText];
}

class UploadInProgress extends TaskFormState {
  final double progress;
  const UploadInProgress(this.progress);
  @override
  List<Object?> get props => [progress];
}

class UploadSuccess extends TaskFormState {
  final String secureUrl;
  const UploadSuccess(this.secureUrl);
  @override
  List<Object?> get props => [secureUrl];
}

class UploadFailure extends TaskFormState {
  final String message;
  const UploadFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class ContentGenerationRejected extends TaskFormState {
  final String reason;
  const ContentGenerationRejected(this.reason);
  @override
  List<Object?> get props => [reason];
}

class ContentGenerationSuccess extends TaskFormState {
  final ContentEntity content;
  final Map<String, dynamic> rawResult;
  final String taskType;
  final String title;

  const ContentGenerationSuccess(
    this.content,
    this.rawResult,
    this.taskType,
    this.title,
  );

  @override
  List<Object?> get props => [content, rawResult, taskType, title];
}
