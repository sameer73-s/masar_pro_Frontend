import '../entities/order_entity.dart';
import '../repositories/parser_repository.dart';

class GetSavedOrdersUseCase {
  final ParserRepository repository;

  GetSavedOrdersUseCase(this.repository);

  Stream<List<OrderEntity>> call() {
    return repository.getSavedOrders();
  }
}
