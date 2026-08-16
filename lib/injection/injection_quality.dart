part of 'injection_container.dart';

void _initQuality() {
  // Bloc
  locator.registerFactory(
    () => QualityBloc(
      runPipelineUseCase: locator(),
      humanizeOnlyUseCase: locator(),
      auditOnlyUseCase: locator(),
      extractTextUseCase: locator(),
      checkThenHumanizeUseCase: locator(),
    ),
  );

  // Use cases
  locator.registerLazySingleton(() => QualityRunPipelineUseCase(locator()));
  locator.registerLazySingleton(() => QualityHumanizeOnlyUseCase(locator()));
  locator.registerLazySingleton(() => QualityAuditOnlyUseCase(locator()));
  locator.registerLazySingleton(() => QualityExtractTextUseCase(locator()));
  locator.registerLazySingleton(() => QualityCheckThenHumanizeUseCase(locator()));

  // Repository
  locator.registerLazySingleton<QualityRepository>(
    () => QualityRepositoryImpl(
      networkService: locator(),
      remoteDataSource: locator(),
    ),
  );

  // Data sources
  locator.registerLazySingleton<QualityRemoteDataSource>(
    () => QualityRemoteDataSourceImpl(),
  );
}
