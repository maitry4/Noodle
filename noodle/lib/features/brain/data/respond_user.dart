// ignore: dangling_library_doc_comments
/// This file takes audio saves it and sends it to backend based on hive settings (with or without api key) and then provides result back to the floating char again. all in all it interacts with all the hive services.
import 'package:flutter/material.dart';

import 'package:noodle/core/services/audio_services.dart';
import 'package:noodle/core/services/backend_services.dart';

class RespondUser extends ChangeNotifier {
  final AudioService _audioService = AudioService();
  final BackendService _backendService = BackendService();

  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isPlaying = false;

  RespondUser() {
    _audioService.onPlayerComplete.listen((_) {
      _isPlaying = false;
      notifyListeners();
    });
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
    _isRecording = true;
    notifyListeners();

    await _audioService.startRecording();
  }

  Future<void> stopDump() async {
    _isRecording = false;
    _isProcessing = true;

    notifyListeners();

    final audioPath = await _audioService.stopRecording();
    debugPrint("AUDIO PATH: $audioPath");
    if (audioPath == null) {
      _isProcessing = false;
      notifyListeners();
      return;
    }

    try {
      final audioBytes = await _backendService.processAudio(audioPath);

      debugPrint("NOODLE RESPONSE: Received ${audioBytes.length} bytes");

      _isProcessing = false;
      _isPlaying = true;
      notifyListeners();

      await _audioService.playAudioBytes(audioBytes);
      await _audioService.deleteTempFile(audioPath);
    } catch (e) {
      debugPrint("Error processing dump: $e");
      _isProcessing = false;
      _isPlaying = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}