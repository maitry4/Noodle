import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_pcm_sound/flutter_pcm_sound.dart';
import 'package:record/record.dart';

class AudioService {
  final AudioRecorder _audioRecorder = AudioRecorder();

  static const int _playbackSampleRate = 24000; // matches Gemini's audio output
  static const int _playbackChannels = 1;

  bool _hasFedFirstChunk = false;

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  bool _pcmSetup = false;
  bool _isPlaying = false;
  bool _streamEnded = false;
  final List<int> _playbackBuffer = [];

  final StreamController<void> _onPlaybackComplete =
      StreamController<void>.broadcast();
  Stream<void> get onPlayerComplete => _onPlaybackComplete.stream;

  Future<void> _ensurePcmSetup() async {
    if (_pcmSetup) return;
    await FlutterPcmSound.setup(
      sampleRate: _playbackSampleRate,
      channelCount: _playbackChannels,
    );
    FlutterPcmSound.setFeedThreshold(
      _playbackSampleRate ~/ 10,
    ); // ~100ms cushion
    FlutterPcmSound.setFeedCallback(_onFeed);
    _pcmSetup = true;
  }

  void _onFeed(int remainingFrames) {
  print('[PCM] _onFeed called, remainingFrames=$remainingFrames, bufferLen=${_playbackBuffer.length}');
  if (_playbackBuffer.isNotEmpty) {
    final samples = List<int>.from(_playbackBuffer);
    _playbackBuffer.clear();
    print('[PCM] feeding ${samples.length} samples');
    FlutterPcmSound.feed(PcmArrayInt16.fromList(samples));
    return;
  }

  if (_streamEnded && remainingFrames == 0 && _isPlaying) {
    print('[PCM] stream ended + buffer empty -> completing');
    _isPlaying = false;
    _onPlaybackComplete.add(null);
  }
}

  /// Call once, right when the first audio chunk of a response arrives.
  Future<void> startPlaybackStream() async {
    await _ensurePcmSetup();
    _playbackBuffer.clear();
    _streamEnded = false;
    _isPlaying = true;
    _hasFedFirstChunk = false;
    FlutterPcmSound.start();
  }

  /// Call for every chunk as it arrives from the websocket.
  void feedAudioChunk(Uint8List bytes) {
    print('[PCM] feedAudioChunk received ${bytes.length} bytes, buffer now ${_playbackBuffer.length + bytes.length ~/ 2}');
    final byteData = ByteData.sublistView(bytes);
    final sampleCount = bytes.length ~/ 2;
    final samples = <int>[];
    for (var i = 0; i < sampleCount; i++) {
      samples.add(byteData.getInt16(i * 2, Endian.little));
    }

    if (!_hasFedFirstChunk) {
      _hasFedFirstChunk = true;
      FlutterPcmSound.feed(PcmArrayInt16.fromList(samples));
    } else {
      _playbackBuffer.addAll(samples);
    }
  }

  /// Call when the backend signals no more chunks are coming.
  void markPlaybackStreamEnded() {
    _streamEnded = true;
    if (_playbackBuffer.isEmpty && _isPlaying) {
      // Nothing left queued — the feed callback may never fire again.
      // Give already-fed samples a moment to actually finish playing,
      // then signal completion ourselves.
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_streamEnded && _isPlaying) {
          _isPlaying = false;
          _onPlaybackComplete.add(null);
        }
      });
    }
  }

  Future<Stream<Uint8List>> startRecordingStream() async {
    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      throw Exception('Microphone permission denied');
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
    _onPlaybackComplete.close();
    if (_pcmSetup) FlutterPcmSound.release();
  }
}
