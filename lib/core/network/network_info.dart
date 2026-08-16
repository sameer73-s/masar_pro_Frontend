import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;
  NetworkInfoImpl(this.connectionChecker);

  /// Fail-open: if the checker throws or times out, treat as connected so
  /// callers can attempt the request and map real Dio errors instead.
  @override
  Future<bool> get isConnected async {
    try {
      return await connectionChecker.hasConnection;
    } catch (_) {
      return true;
    }
  }
}
