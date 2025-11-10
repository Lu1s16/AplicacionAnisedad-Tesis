import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/respuesta_asistente.dart';

class RespuestaAsistenteRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> crearRespuestaAsistente(RespuestaAsistente respuesta) async {
    final db = await _databaseHelper.database;
    return await db.insert('RESPUESTA_ASISTENTE', respuesta.toMap());
  }

  Future<List<RespuestaAsistente>> obtenerRespuestasPorSesion(int idSesion) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'RESPUESTA_ASISTENTE',
      where: 'id_sesion = ?',
      whereArgs: [idSesion],
      orderBy: 'timestamp DESC',
    );
    return results.map((map) => RespuestaAsistente.fromMap(map)).toList();
  }
}