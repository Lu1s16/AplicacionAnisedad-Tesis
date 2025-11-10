class AnalisisEmocional {
  int? idAnalisis;
  int idSesion;
  String nivelAnsiedad; // 'LEVE', 'MODERADO', 'GRAVE'
  String palabrasClaveDetectadas; // JSON como string
  DateTime timestamp;

  AnalisisEmocional({
    this.idAnalisis,
    required this.idSesion,
    required this.nivelAnsiedad,
    required this.palabrasClaveDetectadas,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id_analisis': idAnalisis,
      'id_sesion': idSesion,
      'nivel_ansiedad': nivelAnsiedad,
      'palabras_clave_detectadas': palabrasClaveDetectadas,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AnalisisEmocional.fromMap(Map<String, dynamic> map) {
    return AnalisisEmocional(
      idAnalisis: map['id_analisis'],
      idSesion: map['id_sesion'],
      nivelAnsiedad: map['nivel_ansiedad'],
      palabrasClaveDetectadas: map['palabras_clave_detectadas'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}