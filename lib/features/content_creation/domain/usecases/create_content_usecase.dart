import '../../../../core/errors/either.dart';
import '../../../../core/errors/app_failure.dart';
import '../repositories/content_creation_repository.dart';

class CreateContentParams {
  final String taskType;
  final String title;
  final Map<String, dynamic> optionalFields;

  const CreateContentParams({
    required this.taskType,
    required this.title,
    required this.optionalFields,
  });
}

class CreateContentUseCase {
  final ContentCreationRepository repository;

  CreateContentUseCase(this.repository);

  Future<Either<AppFailure, Map<String, dynamic>>> call(CreateContentParams params) async {
    return await repository.createContent(
      taskType: params.taskType,
      title: params.title,
      optionalFields: params.optionalFields,
    );
  }
}
