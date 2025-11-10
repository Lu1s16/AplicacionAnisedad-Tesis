import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  Future<void> playBreathingExercise() async {
    try {
      _isPlaying = true;
      // En una app real, aquí cargarías un archivo de audio
      // Por ahora usaremos un placeholder
      print('🔊 Reproduciendo ejercicio de respiración...');
      
      // Simular reproducción de audio
      await Future.delayed(Duration(seconds: 2));
      
    } catch (e) {
      print('Error reproduciendo audio: $e');
    } finally {
      _isPlaying = false;
    }
  }

  Future<void> playMindfulnessBell() async {
    try {
      _isPlaying = true;
      print('🔔 Reproduciendo sonido de mindfulness...');
      await Future.delayed(Duration(seconds: 1));
    } catch (e) {
      print('Error reproduciendo campana: $e');
    } finally {
      _isPlaying = false;
    }
  }

  Future<void> playGuidedInstruction(String instruction) async {
    try {
      _isPlaying = true;
      print('🎤 Instrucción de voz: $instruction');
      // En una app real, usarías TTS o audio pregrabado
      await Future.delayed(Duration(seconds: 3));
    } catch (e) {
      print('Error reproduciendo instrucción: $e');
    } finally {
      _isPlaying = false;
    }
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    _isPlaying = false;
  }

  bool get isPlaying => _isPlaying;

  void dispose() {
    _audioPlayer.dispose();
  }
}