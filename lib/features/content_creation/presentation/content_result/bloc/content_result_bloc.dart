import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/usecases/check_then_humanize_usecase.dart';

part 'content_result_event.dart';
part 'content_result_state.dart';

class ContentResultBloc extends Bloc<ContentResultEvent, ContentResultState> {
  final CheckThenHumanizeUseCase checkThenHumanizeUseCase;

  ContentResultBloc({required this.checkThenHumanizeUseCase}) : super(ContentResultInitial()) {
    on<ImproveContentRequested>(_onImproveContentRequested);
  }

  Future<void> _onImproveContentRequested(ImproveContentRequested event, Emitter<ContentResultState> emit) async {
    emit(ContentImprovementLoading());
    final result = await checkThenHumanizeUseCase(
      CheckThenHumanizeParams(
        text: event.text,
        isArabic: event.isArabic,
        useGemini: event.useGemini,
      ),
    );
    result.fold(
      (failure) => emit(ContentResultFailure(failure.message)),
      (data) => emit(ContentImprovementSuccess(data)),
    );
  }
}
