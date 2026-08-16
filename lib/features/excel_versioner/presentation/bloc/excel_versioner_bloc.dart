import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/generate_excel_versions_usecase.dart';
import 'excel_versioner_event.dart';
import 'excel_versioner_state.dart';

class ExcelVersionerBloc
    extends Bloc<ExcelVersionerEvent, ExcelVersionerState> {
  final GenerateExcelVersionsUseCase generateExcelVersionsUseCase;

  ExcelVersionerBloc({
    required this.generateExcelVersionsUseCase,
  }) : super(const ExcelVersionerIdle()) {
    on<GenerateVersionsRequested>(_onGenerateVersionsRequested);
    on<ResetExcelVersioner>(_onReset);
  }

  Future<void> _onGenerateVersionsRequested(
    GenerateVersionsRequested event,
    Emitter<ExcelVersionerState> emit,
  ) async {
    emit(const ExcelVersionerUploading());
    emit(ExcelVersionerProcessing(
      currentVersion: 1,
      totalVersions: event.versionCount,
    ));

    final result = await generateExcelVersionsUseCase(
      GenerateExcelVersionsParams(
        file: event.file,
        prompt: event.prompt,
        versionCount: event.versionCount,
        changeStyle: event.changeStyle,
        changeNumbers: event.changeNumbers,
      ),
    );

    result.fold(
      (failure) => emit(ExcelVersionerFailure(message: failure.message)),
      (data) => emit(ExcelVersionerSuccess(
        versions: data.versions,
        zipUrl: data.zipUrl,
        processingTime: data.processingTime,
      )),
    );
  }

  void _onReset(
    ResetExcelVersioner event,
    Emitter<ExcelVersionerState> emit,
  ) {
    emit(const ExcelVersionerIdle());
  }
}
