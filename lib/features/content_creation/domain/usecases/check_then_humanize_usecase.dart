import '../../../../core/errors/either.dart';
import '../../../../core/errors/app_failure.dart';
import '../repositories/content_creation_repository.dart';

class CheckThenHumanizeParams {
  final String text;
  final bool isArabic;
  final bool useGemini;

  const CheckThenHumanizeParams({
    required this.text,
    required this.isArabic,
    required this.useGemini,
  });
}

class CheckThenHumanizeUseCase {
  final ContentCreationRepository repository;

  CheckThenHumanizeUseCase(this.repository);

  Future<Either<AppFailure, Map<String, dynamic>>> call(CheckThenHumanizeParams params) async {
    return await repository.checkThenHumanize(
      text: params.text,
      isArabic: params.isArabic,
      useGemini: params.useGemini,
    );
  }
}
