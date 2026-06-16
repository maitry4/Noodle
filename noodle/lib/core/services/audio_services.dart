import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioService {
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool _isRecording = false;

  bool get isRecording => _isRecording;

  Future<void> startRecording() async {
    if (_isRecording) return;

    final hasPermission = await _audioRecorder.hasPermission();

    if (!hasPermission) {
      throw Exception('Microphone permission denied');
    }

    final tempDir = await getTemporaryDirectory();

    final filePath = '${tempDir.path}/temp_audio.m4a';

    await _audioRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 64000,
        sampleRate: 16000,
      ),
      path: filePath,
    );

    _isRecording = true;
  }

  Future<String?> stopRecording() async {
    debugPrint("stopRecording() called");
    if (!_isRecording) {
      debugPrint("already stopped");
      return null;
    }

    try {
      final path = await _audioRecorder.stop();
      debugPrint("saved file: $path");
      _isRecording = false;
      return path;
    } catch (e) {
      _isRecording = false;
      rethrow;
    }
  }

  Future<void> deleteTempFile(String filePath) async {
    try {
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  void dispose() {
  _isRecording = false;
  _audioRecorder.dispose();
}
}