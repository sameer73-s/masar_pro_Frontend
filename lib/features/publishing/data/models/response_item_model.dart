import '../../domain/entities/response_item.dart';

class ResponseItemModel extends ResponseItem {
  const ResponseItemModel({
    required super.id,
    required super.commentId,
    required super.suggestedResponse,
    required super.requiredChange,
    super.submissionId,
  });

  factory ResponseItemModel.fromJson(Map<String, dynamic> json) {
    return ResponseItemModel(
      id: json['id']?.toString() ?? '',
      commentId: (json['comment_id'] ?? json['commentId'])?.toString() ?? '',
      suggestedResponse:
          (json['suggested_response'] ?? json['suggestedResponse'])
              ?.toString() ??
          '',
      requiredChange:
          (json['required_change'] ?? json['requiredChange'])?.toString() ?? '',
      submissionId:
          (json['submission_id'] ?? json['submissionId'])?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'comment_id': commentId,
      'suggested_response': suggestedResponse,
      'required_change': requiredChange,
      'submission_id': submissionId,
    };
  }
}
