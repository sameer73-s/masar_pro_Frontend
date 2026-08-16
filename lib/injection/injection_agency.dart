part of 'injection_container.dart';

void _initAgency() {
  // Bloc
  locator.registerFactory(
    () => AgencyBloc(repository: locator()),
  );

  // Repository
  locator.registerLazySingleton<AgencyRepository>(
    () => AgencyRepositoryImpl(
      networkService: locator(),
      remoteDataSource: locator(),
    ),
  );

  // Data sources
  locator.registerLazySingleton<AgencyRemoteDataSource>(
    () => AgencyRemoteDataSourceImpl(),
  );
}
