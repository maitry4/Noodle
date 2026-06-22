import 'dart:io';
import 'dart:typed_data';

class WebSocketService {
  WebSocket? _socket;

  Function(Uint8List bytes)? onAudioReceived;

  bool get isConnected =>
      _socket != null &&
      _socket!.readyState == WebSocket.open;

  Future<void> connect() async {
    if (isConnected) return;

    _socket = await WebSocket.connect(
      'ws://192.168.150.11:8000/ws/noodle',
    );

    print("WebSocket connected");

    _socket!.listen(
      (message) {
        if (message is List<int>) {
          final bytes =
              Uint8List.fromList(message);

          print(
            "Received audio: ${bytes.length}",
          );

          onAudioReceived?.call(bytes);
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