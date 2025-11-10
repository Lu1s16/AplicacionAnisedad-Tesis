class EjercicioRealizado {
  int? idEjercicio;
  int idUsuario;
  int idTipoEjercicio;
  DateTime fechaHoraInicio;
  DateTime? fechaHoraFin;
  int? duracionRealSegundos;
  String? nivelAnsiedadInicial;
  String? nivelAnsiedadFinal;
  int? satisfaccionUsuario;

  EjercicioRealizado({
    this.idEjercicio,
    required this.idUsuario,
    required this.idTipoEjercicio,
    required this.fechaHoraInicio,
    this.fechaHoraFin,
    this.duracionRealSegundos,
    this.nivelAnsiedadInicial,
    this.nivelAnsiedadFinal,
    this.satisfaccionUsuario,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_ejercicio': idEjercicio,
      'id_usuario': idUsuario,
      'id_tipo_ejercicio': idTipoEjercicio,
      'fecha_hora_inicio': fechaHoraInicio.toIso8601String(),
      'fecha_hora_fin': fechaHoraFin?.toIso8601String(),
      'duracion_real_segundos': duracionRealSegundos,
      'nivel_ansiedad_inicial': nivelAnsiedadInicial,
      'nivel_ansiedad_final': nivelAnsiedadFinal,
      'satisfaccion_usuario': satisfaccionUsuario,
    };
  }

  factory EjercicioRealizado.fromMap(Map<String, dynamic> map) {
    return EjercicioRealizado(
      idEjercicio: map['id_ejercicio'],
      idUsuario: map['id_usuario'],
      idTipoEjercicio: map['id_tipo_ejercicio'],
      fechaHoraInicio: DateTime.parse(map['fecha_hora_inicio']),
      fechaHoraFin: map['fecha_hora_fin'] != null 
          ? DateTime.parse(map['fecha_hora_fin']) 
          : null,
      duracionRealSegundos: map['duracion_real_segundos'],
      nivelAnsiedadInicial: map['nivel_ansiedad_inicial'],
      nivelAnsiedadFinal: map['nivel_ansiedad_final'],
      satisfaccionUsuario: map['satisfaccion_usuario'],
    );
  }
}