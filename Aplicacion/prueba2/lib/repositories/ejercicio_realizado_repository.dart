import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/ejercicio_realizado.dart';
import "../models/tipo_ejercicio.dart";

class EjercicioRealizadoRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> crearEjercicioRealizado(EjercicioRealizado ejercicio) async {
    final db = await _databaseHelper.database;
    return await db.insert('EJERCICIO_REALIZADO', ejercicio.toMap());
  }

  Future<void> actualizarEjercicioRealizado(EjercicioRealizado ejercicio) async {
    final db = await _databaseHelper.database;
    await db.update(
      'EJERCICIO_REALIZADO',
      ejercicio.toMap(),
      where: 'id_ejercicio = ?',
      whereArgs: [ejercicio.idEjercicio],
    );
  }

  Future<EjercicioRealizado?> obtenerEjercicioPorId(int id) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'EJERCICIO_REALIZADO',
      where: 'id_tipo_ejercicio = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return EjercicioRealizado.fromMap(results.first);
    }
    return null;
  }

  Future<List<EjercicioRealizado>> obtenerEjerciciosPorUsuario(int idUsuario) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'EJERCICIO_REALIZADO',
      where: 'id_usuario = ?',
      whereArgs: [idUsuario],
      orderBy: 'fecha_hora_inicio DESC',
    );
    return results.map((map) => EjercicioRealizado.fromMap(map)).toList();
  }
}