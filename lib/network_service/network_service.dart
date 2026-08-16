import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  NetworkService._();
  static final NetworkService instance = NetworkService._();

  final Connectivity _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get connectionStatus => _controller.stream;
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  void initialize() {
    // Seed with current status (stream alone can emit late / flaky on desktop).
    unawaited(_refreshConnectivity());
    _connectivity.onConnectivityChanged.listen((result) {
      _isConnected = _hasUsableLink(result);
      _controller.add(_isConnected);
    });
  }

  Future<void> _refreshConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isConnected = _hasUsableLink(result);
      if (!_controller.isClosed) {
        _controller.add(_isConnected);
      }
    } catch (_) {
      // Fail open — prefer attempting HTTP over blocking the app.
      _isConnected = true;
    }
  }

  /// Empty results or unknown platform quirks → treat as online (fail open).
  static bool _hasUsableLink(List<ConnectivityResult> result) {
    if (result.isEmpty) return true;
    return result.any((r) => r != ConnectivityResult.none);
  }

  void dispose() => _controller.close();
}
