import 'dart:io';
import 'dart:typed_data';

class WebSocketService {
  WebSocket? _socket;

  Function(Uint8List bytes)? onAudioReceived;
  Function(String error)? onErrorReceived;

  bool get isConnected =>
      _socket != null && _socket!.readyState == WebSocket.open;

  Future<void> connect({
    required String apiKey,
    required String deviceUuid,
  }) async {
    if (isConnected) return;

    final uri = Uri(
      scheme: 'ws',
      host: '192.168.150.11',
      port: 8000,
      path: '/ws/noodle',
      queryParameters: {
        'api_key': apiKey,
        'device_uuid': deviceUuid,
      },
    );

    _socket = await WebSocket.connect(uri.toString());

    print("WebSocket connected — device: $deviceUuid");

    _socket!.listen(
      (message) {
        if (message is List<int>) {
          final bytes = Uint8List.fromList(message);
          print("Received audio: ${bytes.length} bytes");
          onAudioReceived?.call(bytes);
        } else if (message is String) {
          print("Received text: $message");
          onErrorReceived?.call(message);
        }
      },
      onDone: () {
        print("Socket closed");
        _socket = null;
      },
      onError: (e) {
        print("Socket error: $e");
        _socket = null;
      },
    );
  }

  void sendBytes(Uint8List bytes) {
    _socket?.add(bytes);
  }

  void send(String message) {
    _socket?.add(message);
  }

  Future<void> disconnect() async {
    await _socket?.close();
    _socket = null;
  }
}