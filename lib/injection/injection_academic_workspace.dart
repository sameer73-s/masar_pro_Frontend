part of 'injection_container.dart';

void _initAcademicWorkspace() {
  locator.registerFactory(
    () => AcademicWorkspaceBloc(repository: locator()),
  );

  locator.registerLazySingleton<AcademicProjectRepository>(
    () => AcademicProjectRepositoryImpl(
      networkService: locator(),
      remoteDataSource: locator(),
    ),
  );

  locator.registerLazySingleton<AcademicProjectRemoteDataSource>(
    () => AcademicProjectRemoteDataSourceImpl(),
  );
}
