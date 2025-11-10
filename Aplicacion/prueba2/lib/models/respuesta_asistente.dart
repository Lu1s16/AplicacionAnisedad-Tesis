class RespuestaAsistente {
  int? idRespuesta;
  int idSesion;
  int? idTipoEjercicioRecomendado;
  String respuestaTexto;
  String tecnicaAplicada;
  DateTime timestamp;

  RespuestaAsistente({
    this.idRespuesta,
    required this.idSesion,
    this.idTipoEjercicioRecomendado,
    required this.respuestaTexto,
    required this.tecnicaAplicada,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id_respuesta': idRespuesta,
      'id_sesion': idSesion,
      'id_tipo_ejercicio_recomendado': idTipoEjercicioRecomendado,
      'respuesta_texto': respuestaTexto,
      'tecnica_aplicada': tecnicaAplicada,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory RespuestaAsistente.fromMap(Map<String, dynamic> map) {
    return RespuestaAsistente(
      idRespuesta: map['id_respuesta'],
      idSesion: map['id_sesion'],
      idTipoEjercicioRecomendado: map['id_tipo_ejercicio_recomendado'],
      respuestaTexto: map['respuesta_texto'],
      tecnicaAplicada: map['tecnica_aplicada'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}