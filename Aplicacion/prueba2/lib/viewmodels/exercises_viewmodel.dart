import 'package:flutter/foundation.dart';
import '../models/tipo_ejercicio.dart';
import '../models/ejercicio_realizado.dart';
import '../repositories/tipo_ejercicio_repository.dart';
import '../repositories/ejercicio_realizado_repository.dart';
import '../services/exercise_guide_service.dart';

class ExercisesViewModel with ChangeNotifier {
  final TipoEjercicioRepository _tipoEjercicioRepository;
  final EjercicioRealizadoRepository _ejercicioRealizadoRepository;
  final ExerciseGuideService _exerciseGuideService;
  
  List<TipoEjercicio> _ejercicios = [];
  List<EjercicioRealizado> _historialEjercicios = [];
  bool _isLoading = false;
  bool _isExerciseActive = false;
  String _currentExerciseType = '';
  int _currentStep = 0;
  List<String> _currentInstructions = [];
  String _errorMessage = '';
  int? _currentExerciseId;
  
  // VARIABLES CRÍTICAS QUE FALTABAN
  int? _currentUserId;
  String _currentNivelAnsiedadInicial = 'LEVE';

  // Getter para el servicio de audio (necesario para la UI)
  ExerciseGuideService get exerciseGuideService => _exerciseGuideService;

  ExercisesViewModel({
    required TipoEjercicioRepository tipoEjercicioRepository,
    required EjercicioRealizadoRepository ejercicioRealizadoRepository,
    required ExerciseGuideService exerciseGuideService,
  }) : _tipoEjercicioRepository = tipoEjercicioRepository,
       _ejercicioRealizadoRepository = ejercicioRealizadoRepository,
       _exerciseGuideService = exerciseGuideService;

  // Getters
  List<TipoEjercicio> get ejercicios => _ejercicios;
  List<EjercicioRealizado> get historialEjercicios => _historialEjercicios;
  bool get isLoading => _isLoading;
  bool get isExerciseActive => _isExerciseActive;
  String get currentExerciseType => _currentExerciseType;
  int get currentStep => _currentStep;
  List<String> get currentInstructions => _currentInstructions;
  String get errorMessage => _errorMessage;
  bool get isTtsSpeaking => _exerciseGuideService.isTtsSpeaking;
  bool get isAudioPlaying => _exerciseGuideService.isPlaying;

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


  // Cargar ejercicios disponibles
  Future<void> loadEjercicios() async {
    _isLoading = true;
    notifyListeners();

    try {
      _ejercicios = await _tipoEjercicioRepository.obtenerTodosLosEjercicios();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Error cargando ejercicios: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<String> getInstructionsForExercise(String exerciseType) {
    return _exerciseInstructions[exerciseType] ?? [
      'Encuentra una posición cómoda',
      'Sigue las instrucciones del audio guía',
      'Mantén tu atención en el presente',
      'Respira profundamente'
    ];
  }

  // Cargar historial de ejercicios del usuario
  Future<void> loadHistorialEjercicios(int userId) async {
    try {
      _historialEjercicios = await _ejercicioRealizadoRepository.obtenerEjerciciosPorUsuario(userId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error cargando historial: $e';
      notifyListeners();
    }
  }

  // Iniciar un ejercicio
  Future<void> startExercise({
    required int userId,
    required int tipoEjercicioId,
    required String nivelAnsiedadInicial,
  }) async {
    if (_isExerciseActive) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Obtener información del tipo de ejercicio
      final tipoEjercicio = await _tipoEjercicioRepository.obtenerEjercicioPorId(tipoEjercicioId);
      if (tipoEjercicio == null) {
        throw Exception('Tipo de ejercicio no encontrado');
      }

      // GUARDAR VARIABLES CRÍTICAS
      _currentUserId = userId;
      _currentNivelAnsiedadInicial = nivelAnsiedadInicial;

      // Crear registro de ejercicio realizado
      final ejercicio = EjercicioRealizado(
        idUsuario: userId,
        idTipoEjercicio: tipoEjercicioId,
        fechaHoraInicio: DateTime.now(),
        nivelAnsiedadInicial: nivelAnsiedadInicial,
      );

      _currentExerciseId = await _ejercicioRealizadoRepository.crearEjercicioRealizado(ejercicio);

      // Configurar ejercicio actual
      _currentExerciseType = tipoEjercicio.nombre;
      _currentInstructions = _exerciseGuideService.getInstructionsForExercise(tipoEjercicio.nombre);
      _currentStep = 0;
      _isExerciseActive = true;
      _isLoading = false;

      notifyListeners();

      // Iniciar audio del ejercicio
      await _startExerciseAudio(tipoEjercicio.nombre);

    } catch (e) {
      _errorMessage = 'Error iniciando ejercicio: $e';
      _isLoading = false;
      _isExerciseActive = false;
      notifyListeners();
    }
  }

  // Iniciar audio según el tipo de ejercicio
  Future<void> _startExerciseAudio(String exerciseType) async {
    try {
      switch (exerciseType) {
        case 'Respiración':
          await _exerciseGuideService.playBreathingSound();
          break;
        case 'Mindfulness':
          await _exerciseGuideService.playMeditationBell();
          break;
        default:
          await _exerciseGuideService.playExerciseGuide(exerciseType);
      }

      // Marcar ejercicio como completado después del audio
      if (_currentExerciseId != null && _currentUserId != null) {
        await _completeExercise(_currentUserId!, _currentNivelAnsiedadInicial);
      }
    } catch (e) {
      _errorMessage = 'Error en audio del ejercicio: $e';
      notifyListeners();
    }
  }

  // Completar ejercicio
  Future<void> _completeExercise(int userId, String nivelAnsiedadInicial) async {
    if (_currentExerciseId == null) return;

    try {
      final ejercicioCompletado = EjercicioRealizado(
        idEjercicio: _currentExerciseId,
        idUsuario: userId,
        idTipoEjercicio: _getTipoEjercicioIdByName(_currentExerciseType),
        fechaHoraInicio: DateTime.now().subtract(Duration(minutes: 5)),
        fechaHoraFin: DateTime.now(),
        duracionRealSegundos: 300,
        nivelAnsiedadInicial: nivelAnsiedadInicial,
        nivelAnsiedadFinal: _calculateImprovedAnxietyLevel(nivelAnsiedadInicial),
        satisfaccionUsuario: 4,
      );

      await _ejercicioRealizadoRepository.actualizarEjercicioRealizado(ejercicioCompletado);

      // Actualizar historial
      await loadHistorialEjercicios(userId);

    } catch (e) {
      print('Error completando ejercicio: $e');
    } finally {
      _resetExerciseState();
    }
  }

  // Calcular nivel de ansiedad mejorado
  String _calculateImprovedAnxietyLevel(String nivelInicial) {
    switch (nivelInicial) {
      case 'GRAVE':
        return 'MODERADO';
      case 'MODERADO':
        return 'LEVE';
      case 'LEVE':
        return 'LEVE';
      default:
        return 'LEVE';
    }
  }

  // Obtener ID del tipo de ejercicio por nombre
  int _getTipoEjercicioIdByName(String nombre) {
    final ejercicio = _ejercicios.firstWhere(
      (e) => e.nombre == nombre,
      orElse: () => TipoEjercicio(
        idTipoEjercicio: 1,
        nombre: 'Respiración',
        descripcion: '',
        duracionRecomendadaMinutos: 5,
      ),
    );
    return ejercicio.idTipoEjercicio ?? 1;
  }

  // Método para obtener la instrucción actual
  String getCurrentInstruction() {
    if (_currentInstructions.isNotEmpty && _currentStep < _currentInstructions.length) {
      return _currentInstructions[_currentStep];
    }
    return 'Preparando ejercicio...';
  }

  // Avanzar al siguiente paso del ejercicio
  void nextStep() {
    if (_currentStep < _currentInstructions.length - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  // Paso anterior del ejercicio
  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  // Detener ejercicio actual
  Future<void> stopCurrentExercise() async {
    await _exerciseGuideService.stopAudio();
    _resetExerciseState();
  }

  // Reiniciar estado del ejercicio
  void _resetExerciseState() {
    _isExerciseActive = false;
    _currentExerciseType = '';
    _currentStep = 0;
    _currentInstructions = [];
    _currentExerciseId = null;
    _currentUserId = null;
    _currentNivelAnsiedadInicial = 'LEVE';
    notifyListeners();
  }

  // Registrar satisfacción del usuario
  Future<void> registerSatisfaction(int ejercicioId, int satisfaccion) async {
    try {
      final ejercicio = await _ejercicioRealizadoRepository.obtenerEjercicioPorId(ejercicioId);
      if (ejercicio != null) {
        final ejercicioActualizado = EjercicioRealizado(
          idEjercicio: ejercicioId,
          idUsuario: ejercicio.idUsuario,
          idTipoEjercicio: ejercicio.idTipoEjercicio,
          fechaHoraInicio: ejercicio.fechaHoraInicio,
          fechaHoraFin: ejercicio.fechaHoraFin,
          duracionRealSegundos: ejercicio.duracionRealSegundos,
          nivelAnsiedadInicial: ejercicio.nivelAnsiedadInicial,
          nivelAnsiedadFinal: ejercicio.nivelAnsiedadFinal,
          satisfaccionUsuario: satisfaccion,
        );

        await _ejercicioRealizadoRepository.actualizarEjercicioRealizado(ejercicioActualizado);
        
        // Actualizar historial
        await loadHistorialEjercicios(ejercicio.idUsuario);
      }
    } catch (e) {
      _errorMessage = 'Error registrando satisfacción: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _exerciseGuideService.dispose();
    super.dispose();
  }
}