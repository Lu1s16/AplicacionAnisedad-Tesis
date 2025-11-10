class SesionVoz {
  int? idSesion;
  int idUsuario;
  DateTime fechaHoraInicio;
  DateTime? fechaHoraFin;
  int? audioDuracionSegundos;
  String? textoTranscrito;

  SesionVoz({
    this.idSesion,
    required this.idUsuario,
    required this.fechaHoraInicio,
    this.fechaHoraFin,
    this.audioDuracionSegundos,
    this.textoTranscrito,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_sesion': idSesion,
      'id_usuario': idUsuario,
      'fecha_hora_inicio': fechaHoraInicio.toIso8601String(),
      'fecha_hora_fin': fechaHoraFin?.toIso8601String(),
      'audio_duracion_segundos': audioDuracionSegundos,
      'texto_transcrito': textoTranscrito,
    };
  }

  factory SesionVoz.fromMap(Map<String, dynamic> map) {
    return SesionVoz(
      idSesion: map['id_sesion'],
      idUsuario: map['id_usuario'],
      fechaHoraInicio: DateTime.parse(map['fecha_hora_inicio']),
      fechaHoraFin: map['fecha_hora_fin'] != null 
          ? DateTime.parse(map['fecha_hora_fin']) 
          : null,
      audioDuracionSegundos: map['audio_duracion_segundos'],
      textoTranscrito: map['texto_transcrito'],
    );
  }
}