part of 'injection_container.dart';

void _initPublishing() {
  locator.registerFactory(
    () => PublishingBloc(repository: locator()),
  );

  locator.registerLazySingleton<PublishingRepository>(
    () => PublishingRepositoryImpl(
      networkService: locator(),
      remoteDataSource: locator(),
    ),
  );

  locator.registerLazySingleton<PublishingRemoteDataSource>(
    () => PublishingRemoteDataSourceImpl(),
  );
}
