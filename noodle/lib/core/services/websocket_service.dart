import 'dart:io';
import 'dart:typed_data';

class WebSocketService {
  WebSocket? _socket;
  static const String _audioEndMarker = '__AUDIO_END__';

  Function(Uint8List bytes)? onAudioChunkReceived;
  Function()? onAudioStreamEnd;
  Function(String error)? onErrorReceived;

  bool get isConnected =>
      _socket != null && _socket!.readyState == WebSocket.open;

  Future<void> connect({
    required String apiKey,
    required String deviceUuid,
    required String languageCode,
  }) async {
    if (isConnected) return;

    final uri = Uri(
      scheme: 'ws',
      host: '192.168.150.11',
      port: 8000,
      path: '/ws/noodle',
      queryParameters: {'api_key': apiKey, 'device_uuid': deviceUuid,'language_code': languageCode,},
    );

    _socket = await WebSocket.connect(uri.toString());
    print("WebSocket connected — device: $deviceUuid, lang: $languageCode");

    _socket!.listen(
      (message) {
        if (message is List<int>) {
          onAudioChunkReceived?.call(Uint8List.fromList(message));
        } else if (message is String) {
          if (message == _audioEndMarker) {
            onAudioStreamEnd?.call();
          } else {
            print("Received text: $message");
            onErrorReceived?.call(message);
          }
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

  void sendBytes(Uint8List bytes) => _socket?.add(bytes);
  void send(String message) => _socket?.add(message);

  Future<void> disconnect() async {
    await _socket?.close();
    _socket = null;
  }
}