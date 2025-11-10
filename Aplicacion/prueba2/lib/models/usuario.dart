class Usuario {
  int? idUsuario;
  String nombre;
  String email;
  String password; // Encriptada
  DateTime fechaRegistro;
  bool configNotificaciones;
  String temaAplicacion;

  Usuario({
    this.idUsuario,
    required this.nombre,
    required this.email,
    required this.password,
    DateTime? fechaRegistro,
    this.configNotificaciones = true,
    this.temaAplicacion = 'claro',
  }) : fechaRegistro = fechaRegistro ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id_usuario': idUsuario,
      'nombre': nombre,
      'email': email,
      'password': password,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'config_notificaciones': configNotificaciones ? 1 : 0,
      'tema_aplicacion': temaAplicacion,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      idUsuario: map['id_usuario'],
      nombre: map['nombre'],
      email: map['email'],
      password: map['password'],
      fechaRegistro: DateTime.parse(map['fecha_registro']),
      configNotificaciones: map['config_notificaciones'] == 1,
      temaAplicacion: map['tema_aplicacion'],
    );
  }
}