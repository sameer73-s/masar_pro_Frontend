import '../errors/either.dart';
import '../errors/app_failure.dart';

abstract class UseCase<T, Params> {
  Future<Either<AppFailure, T>> call(Params params);
}

class NoParams {
  const NoParams();
}
