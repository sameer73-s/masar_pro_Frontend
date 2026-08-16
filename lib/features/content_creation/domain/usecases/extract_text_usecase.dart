import 'package:file_picker/file_picker.dart';
import '../../../../core/errors/either.dart';
import '../../../../core/errors/app_failure.dart';
import '../repositories/content_creation_repository.dart';

class ExtractTextUseCase {
  final ContentCreationRepository repository;

  ExtractTextUseCase(this.repository);

  Future<Either<AppFailure, String>> call(PlatformFile file) async {
    return await repository.extractText(file);
  }
}
