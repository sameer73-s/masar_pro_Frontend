part of 'content_result_bloc.dart';

abstract class ContentResultState extends Equatable {
  const ContentResultState();
  @override
  List<Object?> get props => [];
}

class ContentResultInitial extends ContentResultState {}

class ContentImprovementLoading extends ContentResultState {}

class ContentImprovementSuccess extends ContentResultState {
  final Map<String, dynamic> result;
  const ContentImprovementSuccess(this.result);
  @override
  List<Object?> get props => [result];
}

class ContentResultFailure extends ContentResultState {
  final String message;
  const ContentResultFailure(this.message);
  @override
  List<Object?> get props => [message];
}
