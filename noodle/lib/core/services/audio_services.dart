import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;

  bool get isRecording => _isRecording;
  
  Stream<void> get onPlayerComplete => _audioPlayer.onPlayerComplete;

  Future<void> playAudioBytes(Uint8List bytes) async {
    await _audioPlayer.play(BytesSource(bytes));
  }

  Future<void> startRecording() async {
    if (_isRecording) return;

    final hasPermission = await _audioRecorder.hasPermission();

    if (!hasPermission) {
      throw Exception('Microphone permission denied');
    }

    final tempDir = await getTemporaryDirectory();

    final filePath = '${tempDir.path}/temp_audio.pcm';
    print("--------------------------------------------------------------------------------------------------------------------------------------here are the audio files I can use");
    print(AudioEncoder.values);
    await _audioRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
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
    _audioPlayer.dispose();
  }
}