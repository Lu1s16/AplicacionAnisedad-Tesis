import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/exercises_viewmodel.dart';
import '../repositories/tipo_ejercicio_repository.dart';
import '../repositories/ejercicio_realizado_repository.dart';
import "../services/exercise_guide_service.dart";

class ActiveExerciseScreen extends StatefulWidget {
  final int userId;
  final String exerciseType;

  const ActiveExerciseScreen({
    Key? key,
    required this.userId,
    required this.exerciseType,
  }) : super(key: key);

  @override
  _ActiveExerciseScreenState createState() => _ActiveExerciseScreenState();
}

class _ActiveExerciseScreenState extends State<ActiveExerciseScreen> {
  late ExercisesViewModel _viewModel;
  int _currentTime = 0;
  late String _currentInstruction;

  @override
  void initState() {
    super.initState();
    _viewModel = ExercisesViewModel(
      tipoEjercicioRepository: TipoEjercicioRepository(),
      ejercicioRealizadoRepository: EjercicioRealizadoRepository(),
      exerciseGuideService: ExerciseGuideService(),
    );
    _startExercise();
  }

  void _startExercise() {
    // Configurar instrucciones iniciales
    final instructions = _viewModel.getInstructionsForExercise(
      widget.exerciseType,
    );
    if (instructions.isNotEmpty) {
      _currentInstruction = instructions[0];
    }

    // Simular progreso del ejercicio
    _startTimer();
  }

  void _startTimer() {
    // Simular temporizador del ejercicio
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _currentTime++;
        });
        _startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: _getBackgroundColor(),
        appBar: AppBar(
          title: Text('Ejercicio en Progreso'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () => _showExitConfirmation(context),
          ),
        ),
        body: Consumer<ExercisesViewModel>(
          builder: (context, viewModel, child) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Header con información del ejercicio
                  _buildExerciseHeader(),
                  SizedBox(height: 40),

                  _buildAudioStatus(), // NUEVO: Estado del audio
                  SizedBox(height: 40),

                  // Instrucción actual
                  _buildCurrentInstruction(),
                  SizedBox(height: 40),

                  // Indicador de progreso
                  _buildProgressIndicator(),
                  SizedBox(height: 40),

                  // Controles
                  _buildControlButtons(viewModel),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildExerciseHeader() {
    return Column(
      children: [
        Icon(_getExerciseIcon(), size: 80, color: Colors.white),
        SizedBox(height: 16),
        Text(
          widget.exerciseType,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Tiempo: ${_formatTime(_currentTime)}',
          style: TextStyle(fontSize: 18, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildCurrentInstruction() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.record_voice_over, size: 40, color: _getPrimaryColor()),
          SizedBox(height: 16),
          Text(
            _currentInstruction,
            style: TextStyle(fontSize: 18, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Text('Progreso', style: TextStyle(fontSize: 16, color: Colors.white70)),
        SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _currentTime / 300, // 5 minutos máximo
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          '${(_currentTime / 60).floor()}min ${_currentTime % 60}seg',
          style: TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildControlButtons(ExercisesViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showExitConfirmation(context),
            icon: Icon(Icons.stop),
            label: Text('Finalizar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _getPrimaryColor(),
              minimumSize: Size(double.infinity, 50),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _nextInstruction(),
            icon: Icon(Icons.skip_next),
            label: Text('Siguiente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getPrimaryColor(),
              minimumSize: Size(double.infinity, 50),
            ),
          ),
        ),
      ],
    );
  }

  void _nextInstruction() {
    final instructions = _viewModel.getInstructionsForExercise(
      widget.exerciseType,
    );

    final currentIndex = instructions.indexOf(_currentInstruction);
    if (currentIndex < instructions.length - 1) {
      setState(() {
        _currentInstruction = instructions[currentIndex + 1];
      });
    }
  }

  Widget _buildAudioStatus() {
    return Consumer<ExercisesViewModel>(
      builder: (context, viewModel, child) {
        final isSpeaking = viewModel.exerciseGuideService.isTtsSpeaking;

        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSpeaking
                ? Colors.white.withOpacity(0.9)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSpeaking ? Icons.volume_up : Icons.volume_off,
                color: isSpeaking ? _getPrimaryColor() : Colors.white54,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                isSpeaking ? 'Hablando...' : 'En pausa',
                style: TextStyle(
                  color: isSpeaking ? _getPrimaryColor() : Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Finalizar Ejercicio'),
        content: Text('¿Estás seguro de que quieres finalizar el ejercicio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Continuar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Volver a lista de ejercicios
            },
            child: Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (widget.exerciseType) {
      case 'Respiración':
        return Colors.blue;
      case 'Mindfulness':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  Color _getPrimaryColor() {
    switch (widget.exerciseType) {
      case 'Respiración':
        return Colors.blue;
      case 'Mindfulness':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  IconData _getExerciseIcon() {
    switch (widget.exerciseType) {
      case 'Respiración':
        return Icons.air;
      case 'Mindfulness':
        return Icons.self_improvement;
      default:
        return Icons.fitness_center;
    }
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
