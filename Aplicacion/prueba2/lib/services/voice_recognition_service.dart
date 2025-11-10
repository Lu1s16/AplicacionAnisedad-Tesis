import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class VoiceRecognitionService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastRecognizedText = '';

  Future<bool> initializeSpeech() async {
    // Solicitar permiso de micrófono
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      return false;
    }

    // Inicializar speech to text
    final available = await _speech.initialize(
      onStatus: (status) => print('Status: $status'),
      onError: (error) => print('Error: $error'),
    );

    return available;
  }

  Future<void> startListening({
    required Function(String text) onResult,
    required Function() onListeningStarted,
    required Function() onListeningStopped,
  }) async {
    if (_isListening) return;

    _isListening = true;
    onListeningStarted();

    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          _lastRecognizedText = result.recognizedWords;
          onResult(_lastRecognizedText);
          _isListening = false;
          onListeningStopped();
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      localeId: 'es-ES', // Español
      cancelOnError: true,
      partialResults: true,
    );
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    
    await _speech.stop();
    _isListening = false;
  }

  bool get isListening => _isListening;
  String get lastRecognizedText => _lastRecognizedText;

  void dispose() {
    _speech.cancel();
  }
}