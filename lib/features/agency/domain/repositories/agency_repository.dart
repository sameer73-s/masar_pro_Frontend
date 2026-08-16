import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/either.dart';
import '../entities/agency_task.dart';

abstract class AgencyRepository {
  Future<Either<AppFailure, List<AgencyTask>>> getTasks();

  Future<Either<AppFailure, AgencyTask>> getTaskDetails(String id);

  Future<Either<AppFailure, AgencyTask>> quoteTask(String id, int price);

  Future<Either<AppFailure, AgencyTask>> approveTask(String id);

  Future<Either<AppFailure, AgencyTask>> rejectTask(String id);

  Future<Either<AppFailure, AgencyTask>> processTask(
    String id,
    String workflow,
    Map<String, dynamic> params,
  );

  Future<Either<AppFailure, AgencyTask>> createTaskFromUrls({
    required String clientId,
    required List<String> fileUrls,
    String status = 'ANALYZED',
    String? orderId,
    String? subject,
    String? taskType,
  });
}
