import 'package:web_socket_channel/web_socket_channel.dart';

Future<WebSocketChannel> connectAuthenticatedSubmissionSocket(
  Uri uri, {
  required Map<String, String> headers,
}) {
  return Future<WebSocketChannel>.error(
    UnsupportedError('This platform does not support submission monitoring.'),
  );
}
