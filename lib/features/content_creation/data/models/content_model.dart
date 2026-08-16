import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/content_entity.dart';

class PromptDetailsModel extends PromptDetailsEntity {
  const PromptDetailsModel({
    required super.prompt,
    required super.tone,
    required super.keywords,
    super.additionalContext,
  });

  factory PromptDetailsModel.fromMap(Map<String, dynamic> map) {
    return PromptDetailsModel(
      prompt: map['prompt'] ?? '',
      tone: map['tone'] ?? '',
      keywords: List<String>.from(map['keywords'] ?? []),
      additionalContext: map['additional_context'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'prompt': prompt,
      'tone': tone,
      'keywords': keywords,
      'additional_context': additionalContext,
    };
  }
}

class ContentModel extends ContentEntity {
  const ContentModel({
    required super.id,
    required super.taskType,
    required super.title,
    required PromptDetailsModel super.promptDetails,
    required super.referenceFiles,
    required super.generatedText,
    super.createdAt,
    super.userId,
  });

  factory ContentModel.fromEntity(ContentEntity entity) {
    return ContentModel(
      id: entity.id,
      taskType: entity.taskType,
      title: entity.title,
      promptDetails: PromptDetailsModel(
        prompt: entity.promptDetails.prompt,
        tone: entity.promptDetails.tone,
        keywords: entity.promptDetails.keywords,
        additionalContext: entity.promptDetails.additionalContext,
      ),
      referenceFiles: entity.referenceFiles,
      generatedText: entity.generatedText,
      createdAt: entity.createdAt,
      userId: entity.userId,
    );
  }

  factory ContentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    final promptDetailsMap = Map<String, dynamic>.from(data['prompt_details'] ?? {});
    final promptDetails = PromptDetailsModel.fromMap(promptDetailsMap);

    DateTime? createdAtDate;
    if (data['created_at'] != null) {
      if (data['created_at'] is Timestamp) {
        createdAtDate = (data['created_at'] as Timestamp).toDate();
      } else if (data['created_at'] is String) {
        createdAtDate = DateTime.tryParse(data['created_at']);
      }
    }

    return ContentModel(
      id: doc.id,
      taskType: data['task_type'] ?? '',
      title: data['title'] ?? '',
      promptDetails: promptDetails,
      referenceFiles: List<String>.from(data['reference_files'] ?? []),
      generatedText: data['generated_text'] ?? '',
      createdAt: createdAtDate,
      userId: data['user_id'],
    );
  }

  Map<String, dynamic> toFirestore() {
    final promptDetailsModel = PromptDetailsModel(
      prompt: promptDetails.prompt,
      tone: promptDetails.tone,
      keywords: promptDetails.keywords,
      additionalContext: promptDetails.additionalContext,
    );

    return {
      'id': id,
      'task_type': taskType,
      'title': title,
      'prompt_details': promptDetailsModel.toMap(),
      'reference_files': referenceFiles,
      'generated_text': generatedText,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'user_id': userId,
    };
  }
}
