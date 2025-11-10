import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/tipo_ejercicio.dart';

class TipoEjercicioRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<TipoEjercicio>> obtenerTodosLosEjercicios() async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'TIPO_EJERCICIO',
      orderBy: 'id_tipo_ejercicio ASC',
    );

    return results.map((map) => TipoEjercicio.fromMap(map)).toList();
  }

  Future<TipoEjercicio?> obtenerEjercicioPorId(int id) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'TIPO_EJERCICIO',
      where: 'id_tipo_ejercicio = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return TipoEjercicio.fromMap(results.first);
    }
    return null;
  }

  Future<List<TipoEjercicio>> obtenerEjerciciosRecomendados() async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'TIPO_EJERCICIO',
      orderBy: 'duracion_recomendada_minutos ASC',
    );

    return results.map((map) => TipoEjercicio.fromMap(map)).toList();
  }
}