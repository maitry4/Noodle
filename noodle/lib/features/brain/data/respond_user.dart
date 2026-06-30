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
  Timer? _maxDurationTimer;
  static const Duration _maxRecordingDuration = Duration(seconds: 60);

  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isPlaying = false;
  bool _isBusy = false;
  String? _errorText;

  String _languageCode = 'en-US'; // default
  String get languageCode => _languageCode;

  void setLanguage(String code) {
    if (_languageCode == code) return;
    _languageCode = code;
    notifyListeners();
  }

  RespondUser() {
  _ws = WebSocketService();

  _ws.onAudioChunkReceived = (bytes) async {
    if (!_isPlaying) {
      _isProcessing = false;
      _isPlaying = true;
      notifyListeners();
      await _audioService.startPlaybackStream();
    }
    _audioService.feedAudioChunk(bytes);
  };

  _ws.onAudioStreamEnd = () {
    _audioService.markPlaybackStreamEnded();
  };

  _ws.onErrorReceived = (message) async {
    await _micSubscription?.cancel();
    _micSubscription = null;
    _maxDurationTimer?.cancel();
    _maxDurationTimer = null;
    await _audioService.stopRecordingStream();

    _isRecording = false;
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
  if (_isRecording || _isProcessing || _isPlaying || _isBusy) return;
  _isBusy = true;
  _errorText = null;
  _isRecording = true;
  notifyListeners();

  try {
    final settings = await _secureStorage.getUserSettings();
    final apiKey = settings.geminiApiKey ?? '';
    final deviceUuid = await DeviceUuidService.getDeviceUuid();

    await _ws.connect(apiKey: apiKey, deviceUuid: deviceUuid, languageCode: languageCode);

    final stream = await _audioService.startRecordingStream();
    _micSubscription = stream.listen((chunk) => _ws.sendBytes(chunk));

    _maxDurationTimer = Timer(_maxRecordingDuration, () {
      if (_isRecording) stopDump();
    });
  } catch (e) {
    _isRecording = false;
    _errorText = 'Could not start recording: $e';
    await _ws.disconnect();
  } finally {
    _isBusy = false;
    notifyListeners();
  }
}

Future<void> stopDump() async {
  if (!_isRecording || _isBusy) return;
  _isBusy = true;
  _maxDurationTimer?.cancel();
  _maxDurationTimer = null;
  _isRecording = false;
  _isProcessing = true;
  notifyListeners();

  try {
    await _micSubscription?.cancel();
    await _audioService.stopRecordingStream();
    _ws.send("END");
  } catch (e) {
    _isProcessing = false;
    _errorText = 'Could not stop recording: $e';
  } finally {
    _isBusy = false;
    notifyListeners();
  }
}

  @override
  void dispose() {
    _micSubscription?.cancel();
    _maxDurationTimer?.cancel();
    _ws.disconnect();
    _audioService.dispose();
    super.dispose();
  }
}
