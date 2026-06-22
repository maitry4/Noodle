import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';

class AudioService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;

  bool get isRecording => _isRecording;

  Stream<void> get onPlayerComplete =>
      _audioPlayer.onPlayerComplete;

  Future<void> playAudioBytes(
    Uint8List bytes,
  ) async {
    await _audioPlayer.play(
      BytesSource(bytes),
    );
  }

  Future<Stream<Uint8List>>
      startRecordingStream() async {
    final hasPermission =
        await _audioRecorder.hasPermission();

    if (!hasPermission) {
      throw Exception(
        'Microphone permission denied',
      );
    }

    _isRecording = true;

    return _audioRecorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ),
    );
  }

  Future<void> stopRecordingStream() async {
    if (!_isRecording) return;

    await _audioRecorder.stop();

    _isRecording = false;
  }

  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
  }
}