import 'package:equatable/equatable.dart';

class PromptDetailsEntity extends Equatable {
  final String prompt;
  final String tone;
  final List<String> keywords;
  final String? additionalContext;

  const PromptDetailsEntity({
    required this.prompt,
    required this.tone,
    required this.keywords,
    this.additionalContext,
  });

  @override
  List<Object?> get props => [prompt, tone, keywords, additionalContext];
}

class ContentEntity extends Equatable {
  final String id;
  final String taskType;
  final String title;
  final PromptDetailsEntity promptDetails;
  final List<String> referenceFiles;
  final String generatedText;
  final DateTime? createdAt;
  final String? userId;

  const ContentEntity({
    required this.id,
    required this.taskType,
    required this.title,
    required this.promptDetails,
    required this.referenceFiles,
    required this.generatedText,
    this.createdAt,
    this.userId,
  });

  @override
  List<Object?> get props => [
        id,
        taskType,
        title,
        promptDetails,
        referenceFiles,
        generatedText,
        createdAt,
        userId,
      ];
}

class ContentGenerationResult extends Equatable {
  final ContentEntity content;
  final Map<String, dynamic> rawResult;

  const ContentGenerationResult({
    required this.content,
    required this.rawResult,
  });

  @override
  List<Object?> get props => [content, rawResult];
}
