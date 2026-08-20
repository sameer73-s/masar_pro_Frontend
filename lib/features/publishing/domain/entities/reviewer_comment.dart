import 'package:equatable/equatable.dart';

import 'response_item.dart';

class ReviewerComment extends Equatable {
  final String id;
  final String submissionId;
  final String commentText;
  final String category;
  final String status;
  final ResponseItem? response;

  const ReviewerComment({
    required this.id,
    required this.submissionId,
    required this.commentText,
    this.category = 'MINOR',
    this.status = 'PENDING',
    this.response,
  });

  ReviewerComment copyWith({
    String? id,
    String? submissionId,
    String? commentText,
    String? category,
    String? status,
    ResponseItem? response,
  }) {
    return ReviewerComment(
      id: id ?? this.id,
      submissionId: submissionId ?? this.submissionId,
      commentText: commentText ?? this.commentText,
      category: category ?? this.category,
      status: status ?? this.status,
      response: response ?? this.response,
    );
  }

  @override
  List<Object?> get props => [
        id,
        submissionId,
        commentText,
        category,
        status,
        response,
      ];
}
