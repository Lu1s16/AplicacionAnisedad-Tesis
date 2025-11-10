import 'package:flutter/material.dart';

class ExerciseCompletionScreen extends StatelessWidget {
  final String exerciseType;
  final int duration;
  final String initialAnxiety;
  final String finalAnxiety;

  const ExerciseCompletionScreen({
    Key? key,
    required this.exerciseType,
    required this.duration,
    required this.initialAnxiety,
    required this.finalAnxiety,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 32),
            Text(
              '¡Ejercicio Completado!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            _buildStatsCard(context),
            SizedBox(height: 32),
            _buildSatisfactionButtons(context),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text('Volver al Inicio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _getPrimaryColor(),
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Resumen del Ejercicio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildStatRow('Ejercicio', exerciseType),
            _buildStatRow('Duración', '${duration ~/ 60} minutos'),
            _buildStatRow('Ansiedad Inicial', _formatAnxietyLevel(initialAnxiety)),
            _buildStatRow('Ansiedad Final', _formatAnxietyLevel(finalAnxiety)),
            _buildStatRow('Mejora', _calculateImprovement()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getPrimaryColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSatisfactionButtons(BuildContext context) {
    return Column(
      children: [
        Text(
          '¿Cómo te sentiste con el ejercicio?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [1, 2, 3, 4, 5].map((rating) {
            return GestureDetector(
              onTap: () => _registerSatisfaction(context, rating),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    rating.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getPrimaryColor(),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('No me gustó', style: TextStyle(color: Colors.white70)),
            Text('Me encantó', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ],
    );
  }

  void _registerSatisfaction(BuildContext context, int rating) {
    // Aquí registrarías la satisfacción en la base de datos
    print('Satisfacción registrada: $rating estrellas');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('¡Gracias por tu feedback!')),
    );
  }

  String _formatAnxietyLevel(String level) {
    switch (level) {
      case 'LEVE':
        return 'Leve';
      case 'MODERADO':
        return 'Moderado';
      case 'GRAVE':
        return 'Grave';
      default:
        return level;
    }
  }

  String _calculateImprovement() {
    if (initialAnxiety == 'GRAVE' && finalAnxiety == 'MODERADO') return '✅ Mejoró';
    if (initialAnxiety == 'MODERADO' && finalAnxiety == 'LEVE') return '✅ Mejoró';
    if (initialAnxiety == finalAnxiety) return '⚡ Se mantuvo';
    return '📈 Mejoró';
  }

  Color _getBackgroundColor() {
    switch (exerciseType) {
      case 'Respiración':
        return Colors.blue;
      case 'Mindfulness':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  Color _getPrimaryColor() {
    switch (exerciseType) {
      case 'Respiración':
        return Colors.blue;
      case 'Mindfulness':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}