import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/sesion_voz.dart';

class SesionVozRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> crearSesionVoz(SesionVoz sesion) async {
    final db = await _databaseHelper.database;
    return await db.insert('SESION_VOZ', sesion.toMap());
  }

  Future<void> actualizarSesionVoz(SesionVoz sesion) async {
    final db = await _databaseHelper.database;
    await db.update(
      'SESION_VOZ',
      sesion.toMap(),
      where: 'id_sesion = ?',
      whereArgs: [sesion.idSesion],
    );
  }

  Future<List<SesionVoz>> obtenerSesionesPorUsuario(int idUsuario) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'SESION_VOZ',
      where: 'id_usuario = ?',
      whereArgs: [idUsuario],
      orderBy: 'fecha_hora_inicio DESC',
    );

    return results.map((map) => SesionVoz.fromMap(map)).toList();
  }

  Future<SesionVoz?> obtenerSesionPorId(int idSesion) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'SESION_VOZ',
      where: 'id_sesion = ?',
      whereArgs: [idSesion],
    );

    if (results.isNotEmpty) {
      return SesionVoz.fromMap(results.first);
    }
    return null;
  }
}