import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/either.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_headers.dart';
import '../models/generate_versions_result_model.dart';

abstract class ExcelVersionerRemoteDataSource {
  Future<Either<AppFailure, GenerateVersionsResultModel>> generateVersions({
    required PlatformFile file,
    required String prompt,
    required int versionCount,
    required bool changeStyle,
    required bool changeNumbers,
  });
}

class ExcelVersionerRemoteDataSourceImpl
    implements ExcelVersionerRemoteDataSource {
  ExcelVersionerRemoteDataSourceImpl();

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  Future<MultipartFile> _toMultipartFile(PlatformFile file) async {
    if (file.path != null) {
      return MultipartFile.fromFile(file.path!, filename: file.name);
    }
    if (file.bytes != null) {
      return MultipartFile.fromBytes(file.bytes!, filename: file.name);
    }
    throw Exception('الملف المختار فارغ أو غير صالح.');
  }

  @override
  Future<Either<AppFailure, GenerateVersionsResultModel>> generateVersions({
    required PlatformFile file,
    required String prompt,
    required int versionCount,
    required bool changeStyle,
    required bool changeNumbers,
  }) async {
    try {
      final multipartFile = await _toMultipartFile(file);
      final formData = FormData.fromMap({
        'file': multipartFile,
        'prompt': prompt,
        'version_count': versionCount,
        'change_style': changeStyle,
        'change_numbers': changeNumbers,
      });

      final response = await ApiClient.request(
        requestType: RequestType.post,
        endPoint: '/api/excel/generate-versions',
        headers: await ApiHeaders.authenticatedAsync(),
        body: formData,
      );

      return response.fold(
        (failure) => Either.left(failure),
        (data) => Either.right(
          GenerateVersionsResultModel.fromJson(_asMap(data)),
        ),
      );
    } catch (e) {
      return Either.left(AppFailure.server(message: e.toString()));
    }
  }
}
