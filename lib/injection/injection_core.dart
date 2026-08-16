part of 'injection_container.dart';

void _initCore() {
  locator.registerLazySingleton(() => Dio());
  locator.registerLazySingleton(() => InternetConnectionChecker.instance);
  locator.registerLazySingleton<NetworkService>(() {
    final networkService = NetworkService.instance;
    networkService.initialize();
    return networkService;
  });
  locator.registerLazySingleton(() => FirebaseAuth.instance);
  locator.registerLazySingleton(() => FirebaseFirestore.instance);
  locator.registerLazySingleton(() => AuthBootstrapService(locator()));
  locator.registerLazySingleton(() => CloudinaryService(locator()));
  locator.registerLazySingleton(
    () => UploadOrchestrator(
      cloudinaryService: locator(),
      firestore: locator(),
    ),
  );
}
