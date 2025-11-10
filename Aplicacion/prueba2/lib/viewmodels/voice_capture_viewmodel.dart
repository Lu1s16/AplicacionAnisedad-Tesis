import 'package:flutter/foundation.dart';
import '../services/voice_recognition_service.dart';
import '../services/emotional_analysis_service.dart';
import '../services/audio_service.dart';
import '../repositories/sesion_voz_repository.dart';
import '../repositories/analisis_emocional_repository.dart';
import '../repositories/respuesta_asistente_repository.dart';
import '../repositories/ejercicio_realizado_repository.dart';
import '../models/sesion_voz.dart';
import '../models/analisis_emocional.dart';
import '../models/respuesta_asistente.dart';
import '../models/ejercicio_realizado.dart';
import "dart:convert";

class VoiceCaptureViewModel with ChangeNotifier {
  final VoiceRecognitionService _voiceService;
  final SesionVozRepository _sesionVozRepository;
  final EmotionalAnalysisService _emotionalAnalysisService;
  final AudioService _audioService;
  final AnalisisEmocionalRepository _analisisEmocionalRepository;
  final RespuestaAsistenteRepository _respuestaAsistenteRepository;
  final EjercicioRealizadoRepository _ejercicioRealizadoRepository;
  
  bool _isLoading = false;
  bool _isListening = false;
  bool _showAssistantResponse = false;
  String _recognizedText = '';
  String _assistantResponse = '';
  String _errorMessage = '';
  String _currentTechnique = '';
  Map<String, dynamic> _currentAnalysis = {};
  int? _currentSesionId;
  int? _currentUserId;

  VoiceCaptureViewModel({
    required VoiceRecognitionService voiceService,
    required SesionVozRepository sesionVozRepository,
    required EmotionalAnalysisService emotionalAnalysisService,
    required AudioService audioService,
    required AnalisisEmocionalRepository analisisEmocionalRepository,
    required RespuestaAsistenteRepository respuestaAsistenteRepository,
    required EjercicioRealizadoRepository ejercicioRealizadoRepository,
  }) : _voiceService = voiceService,
       _sesionVozRepository = sesionVozRepository,
       _emotionalAnalysisService = emotionalAnalysisService,
       _audioService = audioService,
       _analisisEmocionalRepository = analisisEmocionalRepository,
       _respuestaAsistenteRepository = respuestaAsistenteRepository,
       _ejercicioRealizadoRepository = ejercicioRealizadoRepository;

  // Getters
  bool get isLoading => _isLoading;
  bool get isListening => _isListening;
  bool get showAssistantResponse => _showAssistantResponse;
  String get recognizedText => _recognizedText;
  String get assistantResponse => _assistantResponse;
  String get errorMessage => _errorMessage;
  String get currentTechnique => _currentTechnique;
  Map<String, dynamic> get currentAnalysis => _currentAnalysis;

  // Inicializar el servicio de voz
  Future<bool> initializeVoiceRecognition() async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _voiceService.initializeSpeech();
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Error inicializando reconocimiento de voz: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Iniciar grabación y procesamiento
  Future<void> startRecording(int userId) async {
    if (_isListening) return;
    _currentUserId = userId;

    try {
      // Crear nueva sesión en la base de datos
      final nuevaSesion = SesionVoz(
        idUsuario: userId,
        fechaHoraInicio: DateTime.now(),
      );
      
      _currentSesionId = await _sesionVozRepository.crearSesionVoz(nuevaSesion);

      await _voiceService.startListening(
        onResult: (text) async {
          _recognizedText = text;
          _isListening = false;
          
          // Actualizar sesión con el texto transcrito
          if (_currentSesionId != null) {
            final sesionActualizada = SesionVoz(
              idSesion: _currentSesionId,
              idUsuario: userId,
              fechaHoraInicio: nuevaSesion.fechaHoraInicio,
              fechaHoraFin: DateTime.now(),
              audioDuracionSegundos: DateTime.now().difference(nuevaSesion.fechaHoraInicio).inSeconds,
              textoTranscrito: text,
            );
            
            await _sesionVozRepository.actualizarSesionVoz(sesionActualizada);
            
            // Procesar el texto y generar respuesta
            await _processTextAndGenerateResponse(text, _currentSesionId!);
          }
          
          notifyListeners();
        },
        onListeningStarted: () {
          _isListening = true;
          _errorMessage = '';
          _showAssistantResponse = false;
          notifyListeners();
        },
        onListeningStopped: () {
          _isListening = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = 'Error iniciando grabación: $e';
      notifyListeners();
    }
  }

  // Procesar texto y generar respuesta del asistente
  Future<void> _processTextAndGenerateResponse(String text, int sesionId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 1. Análisis emocional
      final analysis = _emotionalAnalysisService.analizarTexto(text);
      _currentAnalysis = analysis;

      // 2. Guardar análisis emocional en BD
      final analisisEmocional = AnalisisEmocional(
        idSesion: sesionId,
        nivelAnsiedad: analysis['nivelAnsiedad'],
        palabrasClaveDetectadas: jsonEncode(analysis['palabrasClaveDetectadas']),
      );
      
      await _analisisEmocionalRepository.crearAnalisisEmocional(analisisEmocional);

      // 3. Generar y guardar respuesta del asistente
      final tecnica = analysis['tecnicaRecomendada'];
      final respuestaTexto = _emotionalAnalysisService.generarRespuesta(
        analysis['nivelAnsiedad'], 
        tecnica['tecnica']
      );

      final respuestaAsistente = RespuestaAsistente(
        idSesion: sesionId,
        idTipoEjercicioRecomendado: tecnica['idTipoEjercicio'],
        respuestaTexto: respuestaTexto,
        tecnicaAplicada: tecnica['tecnica'],
      );

      await _respuestaAsistenteRepository.crearRespuestaAsistente(respuestaAsistente);

      // 4. Mostrar respuesta al usuario
      _assistantResponse = respuestaTexto;
      _currentTechnique = tecnica['tecnica'];
      _showAssistantResponse = true;

      _isLoading = false;
      notifyListeners();

    } catch (e) {
      _errorMessage = 'Error procesando texto: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Iniciar ejercicio guiado
  Future<void> startGuidedExercise() async {
    if (_currentUserId == null || _currentAnalysis.isEmpty) return;

    try {
      _isLoading = true;
      notifyListeners();

      final tecnica = _currentAnalysis['tecnicaRecomendada'];
      
      // Crear registro de ejercicio realizado
      final ejercicio = EjercicioRealizado(
        idUsuario: _currentUserId!,
        idTipoEjercicio: tecnica['idTipoEjercicio'],
        fechaHoraInicio: DateTime.now(),
        nivelAnsiedadInicial: _currentAnalysis['nivelAnsiedad'],
      );

      final ejercicioId = await _ejercicioRealizadoRepository.crearEjercicioRealizado(ejercicio);

      // Reproducir audio según la técnica
      switch (_currentTechnique) {
        case 'Respiración Profunda':
          await _audioService.playBreathingExercise();
          break;
        case 'Mindfulness':
          await _audioService.playMindfulnessBell();
          break;
        case 'Grounding':
          await _audioService.playGuidedInstruction(
            'Vamos a practicar la técnica de grounding. Enfócate en...'
          );
          break;
      }

      // Actualizar ejercicio como completado
      final ejercicioCompletado = EjercicioRealizado(
        idEjercicio: ejercicioId,
        idUsuario: _currentUserId!,
        idTipoEjercicio: tecnica['idTipoEjercicio'],
        fechaHoraInicio: ejercicio.fechaHoraInicio,
        fechaHoraFin: DateTime.now(),
        duracionRealSegundos: DateTime.now().difference(ejercicio.fechaHoraInicio).inSeconds,
        nivelAnsiedadInicial: _currentAnalysis['nivelAnsiedad'],
        nivelAnsiedadFinal: 'LEVE', // Asumimos mejora
        satisfaccionUsuario: 4,
      );

      await _ejercicioRealizadoRepository.actualizarEjercicioRealizado(ejercicioCompletado);

      _isLoading = false;
      notifyListeners();

    } catch (e) {
      _errorMessage = 'Error iniciando ejercicio: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Detener grabación
  Future<void> stopRecording() async {
    await _voiceService.stopListening();
    _isListening = false;
    notifyListeners();
  }

  // Limpiar estado
  void clearState() {
    _recognizedText = '';
    _assistantResponse = '';
    _errorMessage = '';
    _currentTechnique = '';
    _currentAnalysis = {};
    _currentSesionId = null;
    _showAssistantResponse = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _voiceService.dispose();
    _audioService.dispose();
    super.dispose();
  }
}