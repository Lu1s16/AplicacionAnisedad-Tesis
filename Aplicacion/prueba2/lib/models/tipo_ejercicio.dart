class TipoEjercicio {
  int? idTipoEjercicio;
  String nombre;
  String descripcion;
  int duracionRecomendadaMinutos;
  String? audioGuiaUrl;

  TipoEjercicio({
    this.idTipoEjercicio,
    required this.nombre,
    required this.descripcion,
    required this.duracionRecomendadaMinutos,
    this.audioGuiaUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_tipo_ejercicio': idTipoEjercicio,
      'nombre': nombre,
      'descripcion': descripcion,
      'duracion_recomendada_minutos': duracionRecomendadaMinutos,
      'audio_guia_url': audioGuiaUrl,
    };
  }

  factory TipoEjercicio.fromMap(Map<String, dynamic> map) {
    return TipoEjercicio(
      idTipoEjercicio: map['id_tipo_ejercicio'],
      nombre: map['nombre'],
      descripcion: map['descripcion'],
      duracionRecomendadaMinutos: map['duracion_recomendada_minutos'],
      audioGuiaUrl: map['audio_guia_url'],
    );
  }
}