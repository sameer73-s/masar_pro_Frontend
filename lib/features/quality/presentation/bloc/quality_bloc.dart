import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/quality_usecases.dart';
import 'quality_event.dart';
import 'quality_state.dart';

class QualityBloc extends Bloc<QualityEvent, QualityState> {
  final QualityRunPipelineUseCase runPipelineUseCase;
  final QualityHumanizeOnlyUseCase humanizeOnlyUseCase;
  final QualityAuditOnlyUseCase auditOnlyUseCase;
  final QualityExtractTextUseCase extractTextUseCase;
  final QualityCheckThenHumanizeUseCase checkThenHumanizeUseCase;

  QualityBloc({
    required this.runPipelineUseCase,
    required this.humanizeOnlyUseCase,
    required this.auditOnlyUseCase,
    required this.extractTextUseCase,
    required this.checkThenHumanizeUseCase,
  }) : super(QualityInitial()) {
    on<RunPipelineEvent>(_onRunPipeline);
    on<HumanizeOnlyEvent>(_onHumanizeOnly);
    on<AuditOnlyEvent>(_onAuditOnly);
    on<ExtractTextEvent>(_onExtractText);
    on<CheckThenHumanizeEvent>(_onCheckThenHumanize);
    on<ResetQualityEvent>(_onReset);
  }

  Future<void> _onRunPipeline(
    RunPipelineEvent event,
    Emitter<QualityState> emit,
  ) async {
    emit(QualityHumanizing());

    if (event.runAudit) {
      final humanizeResultEither = await humanizeOnlyUseCase(
        text: event.text,
        mode: event.mode,
        language: event.language,
        useGemini: event.useGemini,
      );

      await humanizeResultEither.fold(
        (failure) async {
          emit(QualityFailure(message: failure.message));
        },
        (humanizeResult) async {
          emit(QualityAuditing(humanizeResult: humanizeResult));
          final auditResultEither = await auditOnlyUseCase(
            text: humanizeResult.humanizedText,
          );

          auditResultEither.fold(
            (failure) => emit(QualityFailure(message: failure.message)),
            (auditResult) => emit(QualitySuccess(
              humanizeResult: humanizeResult,
              auditResult: auditResult,
            )),
          );
        },
      );
    } else {
      final result = await humanizeOnlyUseCase(
        text: event.text,
        mode: event.mode,
        language: event.language,
        useGemini: event.useGemini,
      );

      result.fold(
        (failure) => emit(QualityFailure(message: failure.message)),
        (humanizeResult) => emit(QualitySuccess(humanizeResult: humanizeResult)),
      );
    }
  }

  Future<void> _onHumanizeOnly(
    HumanizeOnlyEvent event,
    Emitter<QualityState> emit,
  ) async {
    emit(QualityHumanizing());

    final result = await humanizeOnlyUseCase(
      text: event.text,
      mode: event.mode,
      language: event.language,
      useGemini: event.useGemini,
    );

    result.fold(
      (failure) => emit(QualityFailure(message: failure.message)),
      (humanizeResult) => emit(QualitySuccess(humanizeResult: humanizeResult)),
    );
  }

  Future<void> _onAuditOnly(
    AuditOnlyEvent event,
    Emitter<QualityState> emit,
  ) async {
    final previousHumanize =
        state is QualitySuccess ? (state as QualitySuccess).humanizeResult : null;

    emit(QualityAuditing(humanizeResult: previousHumanize));

    final result = await auditOnlyUseCase(
      text: event.text,
      timeoutSeconds: event.timeoutSeconds,
    );

    result.fold(
      (failure) => emit(QualityFailure(message: failure.message)),
      (auditResult) {
        if (previousHumanize != null) {
          emit(QualitySuccess(
            humanizeResult: previousHumanize,
            auditResult: auditResult,
          ));
        } else {
          emit(QualityAuditSuccess(auditResult: auditResult));
        }
      },
    );
  }

  Future<void> _onExtractText(
    ExtractTextEvent event,
    Emitter<QualityState> emit,
  ) async {
    emit(QualityExtractingText());

    final result = await extractTextUseCase(event.file);

    result.fold(
      (failure) => emit(QualityFailure(message: failure.message)),
      (text) => emit(QualityTextExtracted(text: text)),
    );
  }

  Future<void> _onCheckThenHumanize(
    CheckThenHumanizeEvent event,
    Emitter<QualityState> emit,
  ) async {
    emit(QualityHumanizing());

    final result = await checkThenHumanizeUseCase(
      text: event.text,
      isArabic: event.isArabic,
      useGemini: event.useGemini,
    );

    result.fold(
      (failure) => emit(QualityFailure(message: failure.message)),
      (data) => emit(QualityCheckThenHumanizeSuccess(result: data)),
    );
  }

  void _onReset(ResetQualityEvent event, Emitter<QualityState> emit) {
    emit(QualityInitial());
  }
}
