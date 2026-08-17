import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/parser_repository.dart';
import '../../../domain/usecases/analyze_input_usecase.dart';
import 'smart_parser_event.dart';
import 'smart_parser_state.dart';

class SmartParserBloc extends Bloc<SmartParserEvent, SmartParserState> {
  final AnalyzeInputUseCase analyzeInputUseCase;
  final ParserRepository parserRepository;

  SmartParserBloc({
    required this.analyzeInputUseCase,
    required this.parserRepository,
  }) : super(SmartParserInitial()) {
    on<AnalyzeInputRequested>(_onAnalyzeInputRequested);
    on<UploadAttachmentRequested>(_onUploadAttachmentRequested);
    on<UploadProgressUpdatedInternal>(_onUploadProgressUpdatedInternal);
  }

  Future<void> _onAnalyzeInputRequested(
    AnalyzeInputRequested event,
    Emitter<SmartParserState> emit,
  ) async {
    emit(SmartParserLoading());
    final result = await analyzeInputUseCase(
      AnalyzeInputParams(
        text: event.text,
        files: event.files,
        preUploadedUrls: event.preUploadedUrls,
      ),
    );

    result.fold(
      (failure) => emit(SmartParserFailure(failure.message)),
      (order) {
        if (order.status == 'error' || order.subject == 'AI Processing Failed') {
          final message = order.missingInfo?.trim();
          emit(SmartParserFailure(
            (message != null && message.isNotEmpty)
                ? message
                : 'AI processing failed. Please try again.',
          ));
          return;
        }

        // If isReady is false the order has dynamic fields to fill first.
        final hasMissingInfo = !order.isReady ||
            (order.missingInfo != null && order.missingInfo!.isNotEmpty);

        emit(SmartParserSuccess(order, hasMissingInfo: hasMissingInfo));
      },
    );
  }

  Future<void> _onUploadAttachmentRequested(
    UploadAttachmentRequested event,
    Emitter<SmartParserState> emit,
  ) async {
    emit(const UploadInProgress(0.0));
    final result = await parserRepository.uploadAttachment(
      event.orderId,
      event.file,
      onProgress: (progress) {
        add(UploadProgressUpdatedInternal(progress));
      },
    );

    result.fold(
      (failure) => emit(UploadFailure(failure.message)),
      (secureUrl) => emit(UploadSuccess(secureUrl)),
    );
  }

  void _onUploadProgressUpdatedInternal(
    UploadProgressUpdatedInternal event,
    Emitter<SmartParserState> emit,
  ) {
    emit(UploadInProgress(event.progress));
  }
}
