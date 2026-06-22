import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:noodle/core/services/audio_services.dart';
import 'package:noodle/core/services/websocket_service.dart';

class RespondUser extends ChangeNotifier {
  final AudioService _audioService =
      AudioService();

  late final WebSocketService _ws;

  StreamSubscription<Uint8List>?
      _micSubscription;

  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isPlaying = false;

  RespondUser() {
    _ws = WebSocketService();

    _ws.onAudioReceived =
        _handleAudioResponse;


    _audioService.onPlayerComplete.listen(
    (_) async {
      _isPlaying = false;

      await _ws.disconnect();

      notifyListeners();
    },
  );
  }

  
  bool get isRecording => _isRecording;

  bool get isProcessing => _isProcessing;

  bool get isPlaying => _isPlaying;

  String get statusText {
    if (_isRecording) {
      return "Dumping...";
    }

    if (_isProcessing) {
      return "I hear you. Wait.";
    }

    if (_isPlaying) {
      return "Noodle is speaking...";
    }

    return "Tap Dump";
  }

 Future<void> startDump() async {
  await _ws.connect();

  _isRecording = true;

  notifyListeners();

  final stream =
      await _audioService
          .startRecordingStream();

  _micSubscription =
      stream.listen((chunk) {
    _ws.sendBytes(chunk);
  });
}
 Future<void> stopDump() async {
  _isRecording = false;
  _isProcessing = true;

  notifyListeners();

  await _micSubscription?.cancel();

  await _audioService
      .stopRecordingStream();

  _ws.send("END");
}
 Future<void> _handleAudioResponse(
  Uint8List bytes,
) async {
  debugPrint(
    "Playing ${bytes.length} bytes",
  );

  _isProcessing = false;
  _isPlaying = true;

  notifyListeners();

  await _audioService.playAudioBytes(
    bytes,
  );

}
  @override
  void dispose() {
    _micSubscription?.cancel();

    _ws.disconnect();

    _audioService.dispose();

    super.dispose();
  }
}