import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/analisis_emocional.dart';

class AnalisisEmocionalRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> crearAnalisisEmocional(AnalisisEmocional analisis) async {
    final db = await _databaseHelper.database;
    return await db.insert('ANALISIS_EMOCIONAL', analisis.toMap());
  }

  Future<List<AnalisisEmocional>> obtenerAnalisisPorSesion(int idSesion) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'ANALISIS_EMOCIONAL',
      where: 'id_sesion = ?',
      whereArgs: [idSesion],
      orderBy: 'timestamp DESC',
    );
    return results.map((map) => AnalisisEmocional.fromMap(map)).toList();
  }
}