import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<WebSocketChannel> connectAuthenticatedSubmissionSocket(
  Uri uri, {
  required Map<String, String> headers,
}) async {
  final channel = IOWebSocketChannel.connect(
    uri,
    headers: headers,
    connectTimeout: const Duration(seconds: 30),
    pingInterval: const Duration(seconds: 20),
  );
  await channel.ready;
  return channel;
}
