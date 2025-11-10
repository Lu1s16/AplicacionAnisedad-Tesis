import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/voice_capture_viewmodel.dart';
import '../services/voice_recognition_service.dart';
import '../services/emotional_analysis_service.dart';
import '../services/audio_service.dart';
import '../repositories/sesion_voz_repository.dart';
import '../repositories/analisis_emocional_repository.dart';
import '../repositories/respuesta_asistente_repository.dart';
import '../repositories/ejercicio_realizado_repository.dart';

class VoiceCaptureScreen extends StatefulWidget {
  final int userId;

  const VoiceCaptureScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _VoiceCaptureScreenState createState() => _VoiceCaptureScreenState();
}

class _VoiceCaptureScreenState extends State<VoiceCaptureScreen> {
  late VoiceCaptureViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = VoiceCaptureViewModel(
      voiceService: VoiceRecognitionService(),
      sesionVozRepository: SesionVozRepository(),
      emotionalAnalysisService: EmotionalAnalysisService(),
      audioService: AudioService(),
      analisisEmocionalRepository: AnalisisEmocionalRepository(),
      respuestaAsistenteRepository: RespuestaAsistenteRepository(),
      ejercicioRealizadoRepository: EjercicioRealizadoRepository(),
    );
    _initializeVoiceRecognition();
  }

  Future<void> _initializeVoiceRecognition() async {
    final success = await _viewModel.initializeVoiceRecognition();
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Permiso de micrófono denegado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Asistente de Voz'),
          backgroundColor: Colors.blue[100],
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer<VoiceCaptureViewModel>(
          builder: (context, viewModel, child) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (viewModel.isLoading) ...[
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 20),
                            Text('Procesando tu mensaje...'),
                          ],
                        ),
                      ),
                    ),
                  ] else if (viewModel.showAssistantResponse) ...[
                    // Respuesta del asistente
                    _buildAssistantResponse(viewModel),
                    Spacer(),
                    _buildActionButtons(viewModel),
                  ] else ...[
                    // Interfaz de grabación normal
                    _buildRecordingInterface(viewModel),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecordingInterface(VoiceCaptureViewModel viewModel) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Indicador de estado
          _buildStatusIndicator(viewModel),
          SizedBox(height: 40),
          
          // Botón de grabación
          _buildRecordButton(viewModel),
          SizedBox(height: 40),
          
          // Texto reconocido
          if (viewModel.recognizedText.isNotEmpty) ...[
            Text(
              'Texto reconocido:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                viewModel.recognizedText,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
          
          // Mensaje de error
          if (viewModel.errorMessage.isNotEmpty) ...[
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      viewModel.errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAssistantResponse(VoiceCaptureViewModel viewModel) {
    final analysis = viewModel.currentAnalysis;
    final tecnica = analysis['tecnicaRecomendada'] ?? {};
    
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Análisis emocional
            Card(
              color: _getColorByAnxietyLevel(analysis['nivelAnsiedad']),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.psychology, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Análisis Emocional',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Nivel de ansiedad: ${analysis['nivelAnsiedad']}',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    if (analysis['palabrasClaveDetectadas'] != null &&
                        (analysis['palabrasClaveDetectadas'] as List).isNotEmpty) ...[
                      SizedBox(height: 8),
                      Text(
                        'Palabras detectadas: ${(analysis['palabrasClaveDetectadas'] as List).join(', ')}',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // Recomendación
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.recommend, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Recomendación',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Técnica: ${tecnica['tecnica']}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Ejercicio: ${tecnica['ejercicio']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      tecnica['descripcion'] ?? '',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Duración: ${tecnica['duracion']} minutos',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // Respuesta del asistente
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.support_agent, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Asistente',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      viewModel.assistantResponse,
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(VoiceCaptureViewModel viewModel) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: viewModel.isLoading ? null : () => viewModel.startGuidedExercise(),
          icon: Icon(Icons.play_arrow),
          label: Text('Comenzar Ejercicio Guiado'),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
            backgroundColor: Colors.green,
          ),
        ),
        SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: viewModel.isLoading ? null : () => viewModel.clearState(),
          icon: Icon(Icons.refresh),
          label: Text('Hablar Nuevamente'),
          style: OutlinedButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(VoiceCaptureViewModel viewModel) {
    Color color;
    String text;
    IconData icon;

    if (viewModel.isListening) {
      color = Colors.red;
      text = 'Escuchando... Habla ahora';
      icon = Icons.mic;
    } else if (viewModel.recognizedText.isNotEmpty) {
      color = Colors.green;
      text = 'Texto reconocido';
      icon = Icons.check_circle;
    } else {
      color = Colors.blue;
      text = 'Presiona el botón para hablar';
      icon = Icons.mic_none;
    }

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, size: 48, color: color),
        ),
        SizedBox(height: 16),
        Text(
          text,
          style: TextStyle(fontSize: 18, color: color),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRecordButton(VoiceCaptureViewModel viewModel) {
    return GestureDetector(
      onTap: () {
        if (viewModel.isListening) {
          viewModel.stopRecording();
        } else {
          viewModel.startRecording(widget.userId);
        }
      },
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: viewModel.isListening ? Colors.red : Colors.blue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          viewModel.isListening ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: 60,
        ),
      ),
    );
  }

  Color _getColorByAnxietyLevel(String level) {
    switch (level) {
      case 'MODERADO':
        return Colors.orange;
      case 'LEVE':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}