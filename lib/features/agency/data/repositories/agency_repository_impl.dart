import '../../../../core/base/base_repository.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/either.dart';
import '../../domain/entities/agency_task.dart';
import '../../domain/repositories/agency_repository.dart';
import '../datasources/agency_remote_datasource.dart';

class AgencyRepositoryImpl extends BaseRepository implements AgencyRepository {
  final AgencyRemoteDataSource remoteDataSource;

  AgencyRepositoryImpl({
    required super.networkService,
    required this.remoteDataSource,
  });

  @override
  Future<Either<AppFailure, List<AgencyTask>>> getTasks() async {
    return guardedCall(() async {
      final result = await remoteDataSource.getTasks();
      return result.fold(
        (failure) => Either.left(failure),
        (models) => Either.right(models.cast<AgencyTask>()),
      );
    });
  }

  @override
  Future<Either<AppFailure, AgencyTask>> getTaskDetails(String id) async {
    return guardedCall(() async {
      final result = await remoteDataSource.getTaskDetails(id);
      return result.fold(
        (failure) => Either.left(failure),
        (model) => Either.right(model),
      );
    });
  }

  @override
  Future<Either<AppFailure, AgencyTask>> quoteTask(String id, int price) async {
    return guardedCall(() async {
      final result = await remoteDataSource.quoteTask(id, price);
      return result.fold(
        (failure) => Either.left(failure),
        (model) => Either.right(model),
      );
    });
  }

  @override
  Future<Either<AppFailure, AgencyTask>> approveTask(String id) async {
    return guardedCall(() async {
      final result = await remoteDataSource.approveTask(id);
      return result.fold(
        (failure) => Either.left(failure),
        (model) => Either.right(model),
      );
    });
  }

  @override
  Future<Either<AppFailure, AgencyTask>> rejectTask(String id) async {
    return guardedCall(() async {
      final result = await remoteDataSource.rejectTask(id);
      return result.fold(
        (failure) => Either.left(failure),
        (model) => Either.right(model),
      );
    });
  }

  @override
  Future<Either<AppFailure, AgencyTask>> processTask(
    String id,
    String workflow,
    Map<String, dynamic> params,
  ) async {
    return guardedCall(() async {
      final result = await remoteDataSource.processTask(id, workflow, params);
      return result.fold(
        (failure) => Either.left(failure),
        (model) => Either.right(model),
      );
    });
  }

  @override
  Future<Either<AppFailure, AgencyTask>> retryTask(String id) async {
    return guardedCall(() async {
      final result = await remoteDataSource.retryTask(id);
      return result.fold(
        (failure) => Either.left(failure),
        (model) => Either.right(model),
      );
    });
  }

  @override
  Future<Either<AppFailure, void>> deleteTask(String id) async {
    return guardedCall(() async {
      return remoteDataSource.deleteTask(id);
    });
  }

  @override
  Future<Either<AppFailure, AgencyTask>> createTaskFromUrls({
    required String clientId,
    required List<String> fileUrls,
    String status = 'ANALYZED',
    String? orderId,
    String? subject,
    String? taskType,
  }) async {
    return guardedCall(() async {
      final result = await remoteDataSource.createTaskFromUrls(
        clientId: clientId,
        fileUrls: fileUrls,
        status: status,
        orderId: orderId,
        subject: subject,
        taskType: taskType,
      );
      return result.fold(
        (failure) => Either.left(failure),
        (model) => Either.right(model),
      );
    });
  }
}
