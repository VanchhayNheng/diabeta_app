import 'dart:io';
import 'dart:convert';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final AudioPlayer _player = AudioPlayer();
  String? _recordingPath;
  bool _isRecording = false;
  bool _isInitialized = false;

  bool get isRecording => _isRecording;
  String? get recordingPath => _recordingPath;

  /// Initialize recorder
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _recorder.openRecorder();
    _isInitialized = true;
  }

  /// Request microphone permission
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Start recording
  Future<bool> startRecording() async {
    try {
      // Initialize if needed
      await initialize();

      // Check permission
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        throw Exception('Microphone permission denied');
      }

      // Check if already recording
      if (_isRecording) {
        await stopRecording();
      }

      // Get app directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _recordingPath = '${directory.path}/voice_$timestamp.aac';

      // Start recording
      await _recorder.startRecorder(
        toFile: _recordingPath,
        codec: Codec.aacADTS,
      );

      _isRecording = true;
      return true;
    } catch (e) {
      print('Error starting recording: $e');
      return false;
    }
  }

  /// Stop recording
  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) return null;

      await _recorder.stopRecorder();
      _isRecording = false;

      return _recordingPath;
    } catch (e) {
      print('Error stopping recording: $e');
      _isRecording = false;
      return null;
    }
  }

  /// Play audio file
  Future<void> playAudio(String path) async {
    try {
      await _player.play(DeviceFileSource(path));
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  /// Stop playing
  Future<void> stopPlaying() async {
    await _player.stop();
  }

  /// Convert audio file to base64
  Future<String> audioToBase64(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      return 'data:audio/aac;base64,${base64Encode(bytes)}';
    } catch (e) {
      print('Error converting audio to base64: $e');
      throw Exception('Failed to convert audio');
    }
  }

  /// Get audio duration
  Future<Duration?> getAudioDuration(String path) async {
    try {
      await _player.setSource(DeviceFileSource(path));
      return await _player.getDuration();
    } catch (e) {
      print('Error getting audio duration: $e');
      return null;
    }
  }

  /// Delete audio file
  Future<void> deleteAudio(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting audio: $e');
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    if (_isInitialized) {
      await _recorder.closeRecorder();
      _isInitialized = false;
    }
    await _player.dispose();
  }
}