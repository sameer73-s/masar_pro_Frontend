part of 'injection_container.dart';

void _initLongResearch() {
  // Bloc
  locator.registerFactory(
    () => ResearchBloc(repository: locator()),
  );

  // Repository
  locator.registerLazySingleton<LongResearchRepository>(
    () => LongResearchRepositoryImpl(remoteDatasource: locator()),
  );

  // Data sources
  locator.registerLazySingleton<LongResearchRemoteDatasource>(
    () => LongResearchRemoteDatasourceImpl(dio: locator()),
  );
}
