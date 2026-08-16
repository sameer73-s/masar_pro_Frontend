part of 'injection_container.dart';

void _initContentCreation() {
  // Blocs (split from legacy ContentCreationBloc)
  locator.registerFactory(
    () => TaskSelectionBloc(
      getSavedContentsUseCase: locator(),
    ),
  );
  locator.registerFactory(
    () => TaskFormBloc(
      createContentUseCase: locator(),
      extractTextUseCase: locator(),
      repository: locator(),
    ),
  );
  locator.registerFactory(
    () => ContentResultBloc(
      checkThenHumanizeUseCase: locator(),
    ),
  );

  // Use cases
  locator.registerLazySingleton(() => CreateContentUseCase(locator()));
  locator.registerLazySingleton(() => ExtractTextUseCase(locator()));
  locator.registerLazySingleton(() => CheckThenHumanizeUseCase(locator()));
  locator.registerLazySingleton(() => GetSavedContentsUseCase(locator()));

  // Repository
  locator.registerLazySingleton<ContentCreationRepository>(
    () => ContentCreationRepositoryImpl(
      networkService: locator(),
      firestoreDataSource: locator(),
      generateContentUseCase: locator(),
      remoteDataSource: locator(),
    ),
  );

  // Data sources (remote uses ApiClient statically — no Dio ctor)
  locator.registerLazySingleton<ContentCreationRemoteDataSource>(
    () => ContentCreationRemoteDataSourceImpl(),
  );
  locator.registerLazySingleton<ContentFirestoreDataSource>(
    () => ContentFirestoreDataSourceImpl(
      firestore: locator(),
      auth: locator(),
      uploadOrchestrator: locator(),
    ),
  );
}
