import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'config/shared_preference.dart';
import 'core/network/api_client.dart';
import 'core/services/auth_bootstrap_service.dart';
import 'features/smart_parser/data/models/order_model.dart';
import 'features/long_research/data/models/research_job_model.dart';
import 'features/archive/data/models/student_model.dart';
import 'features/archive/data/models/archived_order_model.dart';
import 'injection/injection_container.dart' as di;
import 'features/smart_parser/presentation/dashboard/views/dashboard_page.dart';
import 'features/smart_parser/presentation/smart_parser/views/smart_parser_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SharedPreferences must be ready before DI / ApiClient / auth headers.
  await SharedPref.instance.initialize();

  // Initialize Firebase first
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully.');
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  // Initialize DI locator
  await di.init();

  // Wire ApiClient to flavor base URL + navigator (used by datasources statically)
  ApiClient.init(navigatorKey: navigatorKey);

  // Ensure user is signed in anonymously before any UI or Firestore interaction
  try {
    final authBootstrapService = di.locator<AuthBootstrapService>();
    await authBootstrapService.ensureSignedIn();
  } catch (e) {
    debugPrint('Failed to run auth bootstrap: $e');
  }

  await EasyLocalization.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(OrderModelAdapter());
  Hive.registerAdapter(ResearchJobModelAdapter());
  Hive.registerAdapter(StudentModelAdapter());
  Hive.registerAdapter(ArchivedOrderModelAdapter());

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      useOnlyLangCode: true,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<List<SharedMediaFile>> _mediaStreamSubscription;

  @override
  void initState() {
    super.initState();
    _initSharingIntentListeners();
  }

  void _initSharingIntentListeners() {
    // ── Foreground / app-in-memory stream ──────────────────────────────────
    // In v1.8.1+, getTextStream/getInitialText were removed.
    // All shared data (text, images, PDFs, URLs) now comes through the unified
    // media stream. Text shares arrive with type == SharedMediaType.text and
    // their content is in the `path` field.
    _mediaStreamSubscription = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        _handleSharedMedia(value);
      }
    }, onError: (err) {
      debugPrint('getMediaStream error: $err');
    });

    // ── Cold-start / app-was-closed ────────────────────────────────────────
    // Use a post-frame callback so the navigator is mounted before we push.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ReceiveSharingIntent.instance
          .getInitialMedia()
          .then((List<SharedMediaFile> value) {
        if (value.isNotEmpty) {
          _handleSharedMedia(value, isInitial: true);
        }
      });
    });
  }

  /// Dispatches shared media to the correct navigation handler.
  /// Text shares (SharedMediaType.text) are routed with [initialText].
  /// Everything else is converted to [PlatformFile] and routed with [initialFiles].
  void _handleSharedMedia(List<SharedMediaFile> files,
      {bool isInitial = false}) {
    // Separate text shares from file shares
    final textShares = files
        .where((f) => f.type == SharedMediaType.text)
        .map((f) => f.path)
        .join('\n')
        .trim();

    final fileShares = files
        .where((f) => f.type != SharedMediaType.text)
        .map((f) => PlatformFile(
              path: f.path,
              name: f.path.split('/').last,
              size: 0,
            ))
        .toList();

    if (textShares.isNotEmpty) {
      _navigateToSmartParser(initialText: textShares);
    }
    if (fileShares.isNotEmpty) {
      _navigateToSmartParser(initialFiles: fileShares);
    }

    // Prevent re-processing the same cold-start intent on resume
    if (isInitial) {
      ReceiveSharingIntent.instance.reset();
    }
  }

  /// Pushes [SmartParserScreen] with optional pre-populated data.
  /// Retries up to 10 times (50 ms apart) when the navigator is not yet ready,
  /// which can happen during a cold-start share before the widget tree is built.
  void _navigateToSmartParser({
    String? initialText,
    List<PlatformFile>? initialFiles,
    int retryCount = 0,
  }) {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (_) => SmartParserScreen(
            initialText: initialText,
            initialFiles: initialFiles,
          ),
        ),
      );
    } else if (retryCount < 10) {
      // Navigator not ready yet — retry after a short delay
      Future.delayed(const Duration(milliseconds: 50), () {
        _navigateToSmartParser(
          initialText: initialText,
          initialFiles: initialFiles,
          retryCount: retryCount + 1,
        );
      });
    } else {
      debugPrint('_navigateToSmartParser: navigator never became ready after retries.');
    }
  }

  @override
  void dispose() {
    _mediaStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'Masar Pro',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      localeResolutionCallback: (_, _) => context.locale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}
