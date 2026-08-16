import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/either.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_headers.dart';
import '../models/agency_task_model.dart';

abstract class AgencyRemoteDataSource {
  Future<Either<AppFailure, List<AgencyTaskModel>>> getTasks();

  Future<Either<AppFailure, AgencyTaskModel>> getTaskDetails(String id);

  Future<Either<AppFailure, AgencyTaskModel>> quoteTask(String id, int price);

  Future<Either<AppFailure, AgencyTaskModel>> approveTask(String id);

  Future<Either<AppFailure, AgencyTaskModel>> rejectTask(String id);

  Future<Either<AppFailure, AgencyTaskModel>> processTask(
    String id,
    String workflow,
    Map<String, dynamic> params,
  );

  /// Bridge Smart Parser → Agency Active Tasks.
  Future<Either<AppFailure, AgencyTaskModel>> createTaskFromUrls({
    required String clientId,
    required List<String> fileUrls,
    String status = 'ANALYZED',
    String? orderId,
    String? subject,
    String? taskType,
  });
}

class AgencyRemoteDataSourceImpl implements AgencyRemoteDataSource {
  AgencyRemoteDataSourceImpl();

  Future<Map<String, String>> _authHeaders() =>
      ApiHeaders.authenticatedAsync();

  @override
  Future<Either<AppFailure, List<AgencyTaskModel>>> getTasks() async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.get,
        endPoint: '/api/v1/tasks',
        headers: await _authHeaders(),
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) {
          final list = _asMapList(data);
          return Either.right(
            list.map(AgencyTaskModel.fromJson).toList(),
          );
        },
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, AgencyTaskModel>> getTaskDetails(String id) async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.get,
        endPoint: '/api/v1/tasks/$id',
        headers: await _authHeaders(),
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(
          AgencyTaskModel.fromJson(Map<String, dynamic>.from(data as Map)),
        ),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, AgencyTaskModel>> quoteTask(
    String id,
    int price,
  ) async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '/api/v1/tasks/$id/quote',
        headers: await _authHeaders(),
        body: {'price': price},
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(
          AgencyTaskModel.fromJson(Map<String, dynamic>.from(data as Map)),
        ),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, AgencyTaskModel>> approveTask(String id) async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '/api/v1/tasks/$id/approve',
        headers: await _authHeaders(),
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(
          AgencyTaskModel.fromJson(Map<String, dynamic>.from(data as Map)),
        ),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, AgencyTaskModel>> rejectTask(String id) async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '/api/v1/tasks/$id/reject',
        headers: await _authHeaders(),
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(
          AgencyTaskModel.fromJson(Map<String, dynamic>.from(data as Map)),
        ),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, AgencyTaskModel>> processTask(
    String id,
    String workflow,
    Map<String, dynamic> params,
  ) async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '/api/v1/tasks/$id/process',
        headers: await _authHeaders(),
        body: {
          'workflow': workflow,
          'params': params,
        },
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) {
          final map = Map<String, dynamic>.from(data as Map);
          // ProcessTaskResponse wraps the task: { "task": {...}, "arq_job_id": ... }
          final taskJson = map['task'] is Map
              ? Map<String, dynamic>.from(map['task'] as Map)
              : map;
          return Either.right(AgencyTaskModel.fromJson(taskJson));
        },
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, AgencyTaskModel>> createTaskFromUrls({
    required String clientId,
    required List<String> fileUrls,
    String status = 'ANALYZED',
    String? orderId,
    String? subject,
    String? taskType,
  }) async {
    try {
      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '/api/v1/tasks/from-urls',
        headers: await _authHeaders(),
        body: {
          'client_id': clientId,
          'file_urls': fileUrls,
          'status': status,
          if (orderId != null) 'order_id': orderId,
          if (subject != null) 'subject': subject,
          if (taskType != null) 'task_type': taskType,
        },
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) {
          final map = Map<String, dynamic>.from(data as Map);
          final taskJson = map['task'] is Map
              ? Map<String, dynamic>.from(map['task'] as Map)
              : map;
          return Either.right(AgencyTaskModel.fromJson(taskJson));
        },
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }

  List<Map<String, dynamic>> _asMapList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (data is Map) {
      final nested = data['tasks'] ?? data['data'] ?? data['items'];
      if (nested is List) {
        return nested
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    return const [];
  }
}
