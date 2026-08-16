part of 'injection_container.dart';

void _initSmartParser() {
  // Bloc
  locator.registerFactory(
    () => DashboardBloc(
      getSavedOrdersUseCase: locator(),
    ),
  );
  locator.registerFactory(
    () => OrderDetailsBloc(
      saveOrderUseCase: locator(),
      generateContentUseCase: locator(),
    ),
  );
  locator.registerFactory(
    () => SmartParserBloc(
      analyzeInputUseCase: locator(),
      parserRepository: locator(),
    ),
  );

  // Use cases
  locator.registerLazySingleton(() => AnalyzeInputUseCase(locator()));
  locator.registerLazySingleton(() => SaveOrderUseCase(locator(), locator()));
  locator.registerLazySingleton(() => GenerateContentUseCase(locator()));
  locator.registerLazySingleton(() => GetSavedOrdersUseCase(locator()));

  // Repository
  locator.registerLazySingleton<ParserRepository>(
    () => ParserRepositoryImpl(
      networkService: locator(),
      remoteDataSource: locator(),
      localDataSource: locator(),
      firestoreDataSource: locator(),
    ),
  );

  // Data sources
  locator.registerLazySingleton<ParserFirestoreDataSource>(
    () => ParserFirestoreDataSourceImpl(
      firestore: locator(),
      auth: locator(),
      uploadOrchestrator: locator(),
    ),
  );
  locator.registerLazySingleton<ParserRemoteDataSource>(
    () => ParserRemoteDataSourceImpl(
      firestoreDataSource: locator(),
    ),
  );
  locator.registerLazySingleton<ContentGenerationDataSource>(
    () => ContentGenerationDataSourceImpl(),
  );
  locator.registerLazySingleton<ParserLocalDataSource>(
    () => ParserLocalDataSourceImpl(),
  );
}
