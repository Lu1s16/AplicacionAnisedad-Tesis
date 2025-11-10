import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prueba2/screens/active_exercise_screen.dart';
import '../viewmodels/exercises_viewmodel.dart';
import '../repositories/tipo_ejercicio_repository.dart';
import '../repositories/ejercicio_realizado_repository.dart';
import '../services/exercise_guide_service.dart';
import '../models/tipo_ejercicio.dart';
import "../models/ejercicio_realizado.dart";

class ExercisesListScreen extends StatefulWidget {
  final int userId;

  const ExercisesListScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ExercisesListScreenState createState() => _ExercisesListScreenState();
}

class _ExercisesListScreenState extends State<ExercisesListScreen> {
  late ExercisesViewModel _viewModel;
  String _selectedAnxietyLevel = 'LEVE';

  @override
  void initState() {
    super.initState();
    _viewModel = ExercisesViewModel(
      tipoEjercicioRepository: TipoEjercicioRepository(),
      ejercicioRealizadoRepository: EjercicioRealizadoRepository(),
      exerciseGuideService: ExerciseGuideService(),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    await _viewModel.loadEjercicios();
    await _viewModel.loadHistorialEjercicios(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Ejercicios de Relajación'),
          backgroundColor: Colors.green[100],
        ),
        body: Consumer<ExercisesViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading && viewModel.ejercicios.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selector de nivel de ansiedad
                  _buildAnxietyLevelSelector(),
                  SizedBox(height: 20),
                  
                  // Lista de ejercicios
                  Expanded(
                    child: _buildExercisesList(viewModel),
                  ),
                  
                  // Historial reciente
                  _buildRecentHistory(viewModel),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnxietyLevelSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Cómo te sientes ahora?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedAnxietyLevel,
              items: [
                DropdownMenuItem(value: 'LEVE', child: Text('Leve - Un poco inquieto')),
                DropdownMenuItem(value: 'MODERADO', child: Text('Moderado - Bastante ansioso')),
                DropdownMenuItem(value: 'GRAVE', child: Text('Grave - Muy angustiado')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedAnxietyLevel = value!;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nivel de ansiedad actual',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExercisesList(ExercisesViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ejercicios Recomendados',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: viewModel.ejercicios.length,
            itemBuilder: (context, index) {
              final ejercicio = viewModel.ejercicios[index];
              return _buildExerciseCard(ejercicio, viewModel);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(TipoEjercicio ejercicio, ExercisesViewModel viewModel) {
    Color cardColor;
    IconData icon;
    
    switch (ejercicio.nombre) {
      case 'Respiración':
        cardColor = Colors.blue[50]!;
        icon = Icons.air;
        break;
      case 'Mindfulness':
        cardColor = Colors.green[50]!;
        icon = Icons.self_improvement;
        break;
      default:
        cardColor = Colors.grey[50]!;
        icon = Icons.fitness_center;
    }

    return Card(
      color: cardColor,
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 40, color: Colors.grey[700]),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ejercicio.nombre,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${ejercicio.duracionRecomendadaMinutos} minutos',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              ejercicio.descripcion,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: viewModel.isLoading
                  ? null
                  : () => _startExercise(ejercicio, viewModel),
              icon: Icon(Icons.play_arrow),
              label: Text('Comenzar Ejercicio'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: _getButtonColor(ejercicio.nombre),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentHistory(ExercisesViewModel viewModel) {
    final recentExercises = viewModel.historialEjercicios.take(3).toList();
    
    if (recentExercises.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          'Historial Reciente',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        ...recentExercises.map((ejercicio) => _buildHistoryItem(ejercicio)),
      ],
    );
  }

  Widget _buildHistoryItem(EjercicioRealizado ejercicio) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(Icons.check_circle, color: Colors.green),
        title: Text(_getExerciseName(ejercicio.idTipoEjercicio)),
        subtitle: Text(
          '${ejercicio.fechaHoraInicio.day}/${ejercicio.fechaHoraInicio.month} - '
          '${ejercicio.duracionRealSegundos != null ? (ejercicio.duracionRealSegundos! ~/ 60) : '?'} min'
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (ejercicio.satisfaccionUsuario != null)
              Icon(Icons.star, color: Colors.amber, size: 20),
            SizedBox(width: 4),
            Text(ejercicio.satisfaccionUsuario?.toString() ?? '-'),
          ],
        ),
      ),
    );
  }

  Color _getButtonColor(String exerciseName) {
    switch (exerciseName) {
      case 'Respiración':
        return Colors.blue;
      case 'Mindfulness':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  String _getExerciseName(int tipoEjercicioId) {
    final ejercicio = _viewModel.ejercicios.firstWhere(
      (e) => e.idTipoEjercicio == tipoEjercicioId,
      orElse: () => TipoEjercicio(
        idTipoEjercicio: tipoEjercicioId,
        nombre: 'Ejercicio',
        descripcion: '',
        duracionRecomendadaMinutos: 5,
      ),
    );
    return ejercicio.nombre;
  }

  Future<void> _startExercise(TipoEjercicio ejercicio, ExercisesViewModel viewModel) async {
    try {
      await viewModel.startExercise(
        userId: widget.userId,
        tipoEjercicioId: ejercicio.idTipoEjercicio!,
        nivelAnsiedadInicial: _selectedAnxietyLevel,
      );

      // Navegar a pantalla de ejercicio activo
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ActiveExerciseScreen(
            userId: widget.userId,
            exerciseType: ejercicio.nombre,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error iniciando ejercicio: $e')),
      );
    }
  }
}