part of 'injection_container.dart';

void _initExcelVersioner() {
  // Bloc
  locator.registerFactory(
    () => ExcelVersionerBloc(
      generateExcelVersionsUseCase: locator(),
    ),
  );

  // Use cases
  locator.registerLazySingleton(() => GenerateExcelVersionsUseCase(locator()));

  // Repository
  locator.registerLazySingleton<ExcelVersionerRepository>(
    () => ExcelVersionerRepositoryImpl(
      networkService: locator(),
      remoteDataSource: locator(),
    ),
  );

  // Data sources
  locator.registerLazySingleton<ExcelVersionerRemoteDataSource>(
    () => ExcelVersionerRemoteDataSourceImpl(),
  );
}
