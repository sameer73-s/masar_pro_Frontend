import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/content_entity.dart';
import '../../../domain/usecases/get_saved_contents_usecase.dart';

part 'task_selection_event.dart';
part 'task_selection_state.dart';

class TaskSelectionBloc extends Bloc<TaskSelectionEvent, TaskSelectionState> {
  final GetSavedContentsUseCase getSavedContentsUseCase;

  TaskSelectionBloc({required this.getSavedContentsUseCase}) : super(TaskSelectionInitial()) {
    on<WatchSavedContents>(_onWatchSavedContents);
  }

  Future<void> _onWatchSavedContents(
    WatchSavedContents event,
    Emitter<TaskSelectionState> emit,
  ) async {
    await emit.forEach<List<ContentEntity>>(
      getSavedContentsUseCase(),
      onData: (contents) => ContentOrdersUpdated(contents),
      onError: (error, stackTrace) => TaskSelectionFailure(error.toString()),
    );
  }
}
