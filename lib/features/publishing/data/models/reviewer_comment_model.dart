import '../../domain/entities/reviewer_comment.dart';
import 'response_item_model.dart';

class ReviewerCommentModel extends ReviewerComment {
  const ReviewerCommentModel({
    required super.id,
    required super.submissionId,
    required super.commentText,
    super.category,
    super.status,
    super.response,
  });

  factory ReviewerCommentModel.fromJson(Map<String, dynamic> json) {
    final commentRaw = json['comment'];
    final commentMap = commentRaw is Map
        ? Map<String, dynamic>.from(commentRaw)
        : json;

    final responseRaw = json['response'];
    final response = responseRaw is Map
        ? ResponseItemModel.fromJson(Map<String, dynamic>.from(responseRaw))
        : null;

    return ReviewerCommentModel(
      id: commentMap['id']?.toString() ?? '',
      submissionId:
          (commentMap['submission_id'] ?? commentMap['submissionId'])
              ?.toString() ??
          '',
      commentText:
          (commentMap['comment_text'] ?? commentMap['commentText'])
              ?.toString() ??
          '',
      category: commentMap['category']?.toString() ?? 'MINOR',
      status: commentMap['status']?.toString() ?? 'PENDING',
      response: response,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'submission_id': submissionId,
      'comment_text': commentText,
      'category': category,
      'status': status,
      if (response != null)
        'response': {
          'id': response!.id,
          'comment_id': response!.commentId,
          'suggested_response': response!.suggestedResponse,
          'required_change': response!.requiredChange,
        },
    };
  }
}
