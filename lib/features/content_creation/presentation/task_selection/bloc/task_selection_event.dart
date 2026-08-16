part of 'task_selection_bloc.dart';

abstract class TaskSelectionEvent extends Equatable {
  const TaskSelectionEvent();
  @override
  List<Object?> get props => [];
}

class WatchSavedContents extends TaskSelectionEvent {
  const WatchSavedContents();
}
