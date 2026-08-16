import 'package:masar_pro/core/shared/content_generation/data/datasources/content_generation_datasource.dart';

class GenerateContentParams {
  final String orderId;
  final Map<String, dynamic> formValues;
  final Map<String, dynamic> orderData;

  const GenerateContentParams({
    required this.orderId,
    required this.formValues,
    required this.orderData,
  });
}

class GenerateContentUseCase {
  final ContentGenerationDataSource dataSource;

  GenerateContentUseCase(this.dataSource);

  Future<Map<String, dynamic>> call(GenerateContentParams params) async {
    return await dataSource.generateContent(
      orderId: params.orderId,
      formValues: params.formValues,
      orderData: params.orderData,
    );
  }
}
