import 'package:web_socket_channel/web_socket_channel.dart';

Future<WebSocketChannel> connectAuthenticatedSubmissionSocket(
  Uri uri, {
  required Map<String, String> headers,
}) {
  return Future<WebSocketChannel>.error(
    UnsupportedError(
      'Authenticated submission monitoring on Flutter Web requires a short-lived WebSocket ticket endpoint.',
    ),
  );
}
