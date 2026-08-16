import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/errors/either.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/parser_repository.dart';

class AnalyzeInputParams extends Equatable {
  final String text;
  final List<PlatformFile> files;
  final List<String>? preUploadedUrls;

  const AnalyzeInputParams({
    required this.text,
    required this.files,
    this.preUploadedUrls,
  });

  @override
  List<Object?> get props => [text, files, preUploadedUrls];
}

class AnalyzeInputUseCase implements UseCase<Either<AppFailure, OrderEntity>, AnalyzeInputParams> {
  final ParserRepository repository;

  AnalyzeInputUseCase(this.repository);

  @override
  Future<Either<AppFailure, OrderEntity>> call(AnalyzeInputParams params) async {
    return await repository.analyzeInput(
      text: params.text,
      files: params.files,
      preUploadedUrls: params.preUploadedUrls,
    );
  }
}
