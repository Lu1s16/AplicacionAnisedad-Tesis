import 'dart:convert';

class EmotionalAnalysisService {
  // Palabras clave para diferentes niveles de ansiedad
  final Map<String, List<String>> _ansiedadPalabrasClave = {
    
    'MODERADO': [
      'nervioso', 'preocupado', 'estresado', 'tenso', 'ansioso', 'miedo',
      'asustado', 'angustia', 'palpitaciones', 'mareo', 'temblor',
      'sudor', 'opresión', 'nudo garganta', 'dificultad respirar'
    ],
    'LEVE': [
      'inquieto', 'molesto', 'incómodo', 'preocupación', 'pensativo',
      'agitado', 'intranquilo', 'desconcentrado', 'distraído'
    ]
  };

  // Técnicas recomendadas por nivel de ansiedad
  final Map<String, Map<String, dynamic>> _tecnicasRecomendadas = {
    
    'MODERADO': {
      'tecnica': 'Respiración Profunda',
      'ejercicio': 'Respiración 4-7-8',
      'descripcion': 'Técnica de respiración para calmar el sistema nervioso',
      'duracion': 7,
      'idTipoEjercicio': 1 // Respiración
    },
    'LEVE': {
      'tecnica': 'Mindfulness',
      'ejercicio': 'Atención Plena',
      'descripcion': 'Observación consciente del momento presente',
      'duracion': 10,
      'idTipoEjercicio': 2 // Mindfulness
    }
  };

  // Analizar texto y determinar nivel de ansiedad
  Map<String, dynamic> analizarTexto(String texto) {
    final textoLower = texto.toLowerCase();
    Map<String, int> conteoPalabras = {};
    List<String> palabrasEncontradas = [];

    // Contar ocurrencias de palabras clave por nivel
    for (final nivel in _ansiedadPalabrasClave.keys) {
      int count = 0;
      for (final palabra in _ansiedadPalabrasClave[nivel]!) {
        if (textoLower.contains(palabra.toLowerCase())) {
          count++;
          palabrasEncontradas.add(palabra);
        }
      }
      conteoPalabras[nivel] = count;
    }

    // Determinar nivel de ansiedad basado en conteos
    String nivelAnsiedad = 'LEVE';
    
    if (conteoPalabras['MODERADO']! > 2) {
      nivelAnsiedad = 'MODERADO';
    } else if (conteoPalabras['LEVE']! > 0) {
      nivelAnsiedad = 'LEVE';
    }

    // Obtener técnica recomendada
    final tecnica = _tecnicasRecomendadas[nivelAnsiedad]!;

    return {
      'nivelAnsiedad': nivelAnsiedad,
      'palabrasClaveDetectadas': palabrasEncontradas,
      'conteoPalabras': conteoPalabras,
      'tecnicaRecomendada': tecnica,
    };
  }

  // Generar respuesta textual personalizada
  String generarRespuesta(String nivelAnsiedad, String tecnica) {
    final respuestas = {
      
      'MODERADO': '''
Noto que estás experimentando un nivel considerable de ansiedad. 
Te recomiendo practicar la técnica de respiración profunda.

Esta técnica te ayudará a calmar tu sistema nervioso y recuperar la tranquilidad.

¿Te gustaría que empecemos?
''',
      'LEVE': '''
Veo que estás sintiendo cierta inquietud. 
Te sugiero practicar un ejercicio de mindfulness para ayudarte a encontrar calma.

Es una excelente manera de manejar esos pensamientos que te generan malestar.

¿Quieres intentarlo?
'''
    };

    return respuestas[nivelAnsiedad] ?? 'Hola, ¿en qué puedo ayudarte hoy?';
  }
}