import 'package:masar_pro/network_service/network_service.dart';

import '../errors/either.dart';
import '../errors/app_failure.dart';

abstract class BaseRepository {
  final NetworkService networkService;

  const BaseRepository({required this.networkService});

  /// Runs [apiCall], mapping unexpected throws to [AppFailure.server].
  ///
  /// Connectivity is **not** used as a hard gate: `connectivity_plus` /
  /// stale [NetworkService.isConnected] flags often false-negative on
  /// desktop/emulators. Real reachability errors are mapped by [ApiClient]
  /// to [AppFailure.connection] or [AppFailure.server].
  Future<Either<AppFailure, T>> guardedCall<T>(
    Future<Either<AppFailure, T>> Function() apiCall,
  ) async {
    try {
      return await apiCall();
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }
}
