import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:noodle/core/services/audio_services.dart';
import 'package:noodle/core/services/device_uuid.dart';
import 'package:noodle/core/services/secure_storage_service.dart';
import 'package:noodle/core/services/websocket_service.dart';

class RespondUser extends ChangeNotifier {
  final AudioService _audioService = AudioService();
  final SecureStorageService _secureStorage = SecureStorageService();

  late final WebSocketService _ws;

  StreamSubscription<Uint8List>? _micSubscription;

  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isPlaying = false;
  String? _errorText;

  RespondUser() {
    _ws = WebSocketService();

    _ws.onAudioReceived = (bytes) async {
      if (bytes.isEmpty) {
        _isProcessing = false;
        _errorText = "Sorry, I couldn't hear you. Try again!";
        await _ws.disconnect();
        notifyListeners();
        return;
      }
      await _handleAudioResponse(bytes);
    };

    _ws.onErrorReceived = (message) {
      _isProcessing = false;
      _isPlaying = false;
      _errorText = message;
      notifyListeners();
    };

    _audioService.onPlayerComplete.listen((_) async {
      _isPlaying = false;
      await _ws.disconnect();
      notifyListeners();
    });
  }

  bool get isRecording => _isRecording;
  bool get isProcessing => _isProcessing;
  bool get isPlaying => _isPlaying;
  String? get errorText => _errorText;

  void clearError() {
    _errorText = null;
    notifyListeners();
  }

  String get statusText {
    if (_isRecording) return "Dumping...";
    if (_isProcessing) return "Wait a minute. Let me process";
    if (_isPlaying) return "Speaking...";
    return "what's eating you?";
  }

  Future<void> startDump() async {
    _errorText = null;

    final settings = await _secureStorage.getUserSettings();
    final apiKey = settings.geminiApiKey ?? '';
    final deviceUuid = await DeviceUuidService.getDeviceUuid();

    await _ws.connect(apiKey: apiKey, deviceUuid: deviceUuid);

    _isRecording = true;
    notifyListeners();

    final stream = await _audioService.startRecordingStream();

    _micSubscription = stream.listen((chunk) {
      _ws.sendBytes(chunk);
    });
  }

  Future<void> stopDump() async {
    _isRecording = false;
    _isProcessing = true;
    notifyListeners();

    await _micSubscription?.cancel();
    await _audioService.stopRecordingStream();

    _ws.send("END");
  }

  Future<void> _handleAudioResponse(Uint8List bytes) async {
    debugPrint("Playing ${bytes.length} bytes");

    _isProcessing = false;
    _isPlaying = true;
    notifyListeners();

    await _audioService.playAudioBytes(bytes);
  }

  @override
  void dispose() {
    _micSubscription?.cancel();
    _ws.disconnect();
    _audioService.dispose();
    super.dispose();
  }
}