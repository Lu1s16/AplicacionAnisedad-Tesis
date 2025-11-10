import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

class ExerciseGuideService {
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isTtsSpeaking = false;

  // Instrucciones para diferentes tipos de ejercicios
  final Map<String, List<String>> _exerciseInstructions = {
    'Respiración': [
      'Encuentra una posición cómoda, sentado o acostado',
      'Coloca una mano sobre tu pecho y la otra sobre tu abdomen',
      'Inhala profundamente por la nariz durante 4 segundos',
      'Mantén la respiración durante 4 segundos',
      'Exhala lentamente por la boca durante 6 segundos',
      'Repite este ciclo 5 veces',
      'Concéntrate en el movimiento de tu respiración'
    ],
    'Mindfulness': [
      'Siéntate en una posición cómoda con la espalda recta',
      'Cierra los ojos suavemente',
      'Lleva tu atención a la sensación de tu respiración',
      'No intentes cambiar tu respiración, solo obsérvala',
      'Si tu mente se distrae, gentilmente regresa a la respiración',
      'Expande tu conciencia a los sonidos a tu alrededor',
      'Permanece en este estado de atención plena'
    ],
  };

  // Sonidos de ambiente para cada ejercicio
  final Map<String, String> _exerciseAmbientSounds = {
    'Respiración': 'assets/sounds/ocean_waves.mp3', // Ejemplo
    'Mindfulness': 'assets/sounds/meditation_bell.mp3',
  };

  ExerciseGuideService() {
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    // Configurar TTS para español
    await _flutterTts.setLanguage("es-ES");
    await _flutterTts.setSpeechRate(0.5); // Velocidad moderada
    await _flutterTts.setPitch(1.0); // Tono normal
    await _flutterTts.setVolume(1.0); // Volumen máximo

    // Configurar callbacks
    _flutterTts.setStartHandler(() {
      _isTtsSpeaking = true;
      _isPlaying = true;
    });

    _flutterTts.setCompletionHandler(() {
      _isTtsSpeaking = false;
    });

    _flutterTts.setErrorHandler((msg) {
      _isTtsSpeaking = false;
      _isPlaying = false;
      print('Error TTS: $msg');
    });
  }

  // Reproducir guía completa de ejercicio con TTS
  Future<void> playExerciseGuide(String exerciseType) async {
    if (_isPlaying) return;

    try {
      _isPlaying = true;
      
      final instructions = _exerciseInstructions[exerciseType] ?? [];
      
      // Reproducir sonido de ambiente (si está disponible)
      await _playAmbientSound(exerciseType);
      
      // Esperar un momento antes de empezar las instrucciones
      await Future.delayed(Duration(seconds: 2));
      
      // Reproducir cada instrucción con TTS
      for (int i = 0; i < instructions.length; i++) {
        if (!_isPlaying) break; // Permitir cancelación
        
        print('🔊 Instrucción ${i + 1}: ${instructions[i]}');
        await _speakInstruction(instructions[i]);
        
        // Pausa entre instrucciones (excepto la última)
        if (i < instructions.length - 1) {
          await Future.delayed(Duration(seconds: 3));
        }
      }
      
      // Mensaje final de conclusión
      await _speakInstruction('Ejercicio completado. Buen trabajo.');
      
    } catch (e) {
      print('Error en guía de ejercicio: $e');
      rethrow;
    } finally {
      await stopAudio();
    }
  }

  // Reproducir una instrucción específica con TTS
  Future<void> _speakInstruction(String instruction) async {
    if (!_isPlaying) return;
    
    try {
      await _flutterTts.speak(instruction);
      
      // Esperar a que termine de hablar
      while (_isTtsSpeaking && _isPlaying) {
        await Future.delayed(Duration(milliseconds: 100));
      }
    } catch (e) {
      print('Error reproduciendo instrucción: $e');
    }
  }

  // Reproducir sonido de ambiente para el ejercicio
  Future<void> _playAmbientSound(String exerciseType) async {
    try {
      final soundPath = _exerciseAmbientSounds[exerciseType];
      if (soundPath != null) {
        // En una app real, cargarías el archivo de audio
        // Por ahora simulamos el sonido
        print('🎵 Reproduciendo sonido ambiente para $exerciseType');
        
        // Simular reproducción de audio de fondo
        _audioPlayer.play(AssetSource(soundPath));
      }
    } catch (e) {
      print('Error reproduciendo sonido ambiente: $e');
    }
  }

  // Reproducir sonido de respiración guiada
  Future<void> playBreathingSound() async {
    try {
      _isPlaying = true;
      
      // Instrucciones de respiración con timing específico
      await _speakInstruction('Preparándonos para la respiración profunda');
      await Future.delayed(Duration(seconds: 2));
      
      // Ciclo de respiración 4-4-6
      for (int i = 0; i < 5 && _isPlaying; i++) {
        await _speakInstruction('Inhala profundamente por la nariz');
        await Future.delayed(Duration(seconds: 4));
        
        await _speakInstruction('Mantén la respiración');
        await Future.delayed(Duration(seconds: 4));
        
        await _speakInstruction('Exhala lentamente por la boca');
        await Future.delayed(Duration(seconds: 6));
        
        if (i < 4) {
          await _speakInstruction('Preparándonos para la siguiente respiración');
          await Future.delayed(Duration(seconds: 2));
        }
      }
      
      if (_isPlaying) {
        await _speakInstruction('Respiración completada. Buen trabajo.');
      }
      
    } catch (e) {
      print('Error en sonido de respiración: $e');
      rethrow;
    } finally {
      _isPlaying = false;
    }
  }

  // Reproducir campana de meditación
  Future<void> playMeditationBell() async {
    try {
      _isPlaying = true;
      
      await _speakInstruction('Iniciando meditación mindfulness');
      await Future.delayed(Duration(seconds: 2));
      
      // Campana al inicio
      await _speakInstruction('Escucha el sonido de la campana');
      print('🔔 Sonido de campana de meditación');
      await Future.delayed(Duration(seconds: 3));
      
      // Instrucciones de mindfulness
      final mindfulnessInstructions = _exerciseInstructions['Mindfulness'] ?? [];
      for (final instruction in mindfulnessInstructions) {
        if (!_isPlaying) break;
        await _speakInstruction(instruction);
        await Future.delayed(Duration(seconds: 10)); // Pausas más largas para mindfulness
      }
      
      // Campana al final
      if (_isPlaying) {
        await _speakInstruction('Escucha el sonido final de la campana');
        print('🔔 Sonido final de campana');
        await Future.delayed(Duration(seconds: 3));
        await _speakInstruction('Meditación completada');
      }
      
    } catch (e) {
      print('Error en campana de meditación: $e');
      rethrow;
    } finally {
      _isPlaying = false;
    }
  }


  // Detener todo el audio
  Future<void> stopAudio() async {
    _isPlaying = false;
    _isTtsSpeaking = false;
    
    try {
      await _flutterTts.stop();
      await _audioPlayer.stop();
    } catch (e) {
      print('Error deteniendo audio: $e');
    }
  }

  // Pausar audio
  Future<void> pauseAudio() async {
    try {
      await _flutterTts.stop();
      await _audioPlayer.pause();
      _isPlaying = false;
      _isTtsSpeaking = false;
    } catch (e) {
      print('Error pausando audio: $e');
    }
  }

  // Verificar si está reproduciendo
  bool get isPlaying => _isPlaying;
  bool get isTtsSpeaking => _isTtsSpeaking;

  // Obtener instrucciones para mostrar en UI
  List<String> getInstructionsForExercise(String exerciseType) {
    return _exerciseInstructions[exerciseType] ?? [
      'Encuentra una posición cómoda',
      'Sigue las instrucciones del audio guía',
      'Mantén tu atención en el presente',
      'Respira profundamente'
    ];
  }

  void dispose() {
    _flutterTts.stop();
    _audioPlayer.dispose();
  }
}