part of 'task_form_bloc.dart';

abstract class TaskFormEvent extends Equatable {
  const TaskFormEvent();
  @override
  List<Object?> get props => [];
}

class CreateContentRequested extends TaskFormEvent {
  final String taskType;
  final String title;
  final Map<String, dynamic> optionalFields;

  const CreateContentRequested({
    required this.taskType,
    required this.title,
    required this.optionalFields,
  });

  @override
  List<Object?> get props => [taskType, title, optionalFields];
}

class ExtractTextRequested extends TaskFormEvent {
  final PlatformFile file;
  const ExtractTextRequested(this.file);
  @override
  List<Object?> get props => [file];
}

class UploadReferenceFileRequested extends TaskFormEvent {
  final String contentId;
  final File file;
  const UploadReferenceFileRequested({required this.contentId, required this.file});
  @override
  List<Object?> get props => [contentId, file];
}

class GenerateContentRequested extends TaskFormEvent {
  final String contentId;
  final String taskType;
  final String title;
  final PromptDetailsEntity promptDetails;
  final List<String> referenceFiles;

  const GenerateContentRequested({
    required this.contentId,
    required this.taskType,
    required this.title,
    required this.promptDetails,
    required this.referenceFiles,
  });

  @override
  List<Object?> get props => [contentId, taskType, title, promptDetails, referenceFiles];
}

class _UploadProgressUpdatedInternal extends TaskFormEvent {
  final double progress;
  const _UploadProgressUpdatedInternal(this.progress);
  @override
  List<Object?> get props => [progress];
}
