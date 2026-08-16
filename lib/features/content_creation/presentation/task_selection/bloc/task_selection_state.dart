part of 'task_selection_bloc.dart';

abstract class TaskSelectionState extends Equatable {
  const TaskSelectionState();
  @override
  List<Object?> get props => [];
}

class TaskSelectionInitial extends TaskSelectionState {}

class ContentOrdersUpdated extends TaskSelectionState {
  final List<ContentEntity> contents;
  const ContentOrdersUpdated(this.contents);
  @override
  List<Object?> get props => [contents];
}

class TaskSelectionFailure extends TaskSelectionState {
  final String message;
  const TaskSelectionFailure(this.message);
  @override
  List<Object?> get props => [message];
}
