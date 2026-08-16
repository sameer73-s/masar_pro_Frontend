import '../entities/content_entity.dart';
import '../repositories/content_creation_repository.dart';

class GetSavedContentsUseCase {
  final ContentCreationRepository repository;

  GetSavedContentsUseCase(this.repository);

  Stream<List<ContentEntity>> call() {
    return repository.getSavedContents();
  }
}
