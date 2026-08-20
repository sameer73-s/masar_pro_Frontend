import 'package:equatable/equatable.dart';

class ResponseItem extends Equatable {
  final String id;
  final String commentId;
  final String suggestedResponse;
  final String requiredChange;
  final String submissionId;

  const ResponseItem({
    required this.id,
    required this.commentId,
    required this.suggestedResponse,
    required this.requiredChange,
    this.submissionId = '',
  });

  @override
  List<Object?> get props => [
        id,
        commentId,
        suggestedResponse,
        requiredChange,
        submissionId,
      ];
}
