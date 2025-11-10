import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../database/database_helper.dart';
import '../models/usuario.dart';

class UsuarioRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Encriptar contraseña
  String _encryptPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Registrar nuevo usuario
  Future<int> registrarUsuario(Usuario usuario) async {
    final db = await _databaseHelper.database;
    
    // Verificar si el email ya existe
    final existingUser = await db.query(
      'USUARIO',
      where: 'email = ?',
      whereArgs: [usuario.email],
    );

    if (existingUser.isNotEmpty) {
      throw Exception('El email ya está registrado');
    }

    // Encriptar contraseña
    usuario.password = _encryptPassword(usuario.password);

    return await db.insert('USUARIO', usuario.toMap());
  }

  // Autenticar usuario
  Future<Usuario?> autenticarUsuario(String email, String password) async {
    final db = await _databaseHelper.database;
    final encryptedPassword = _encryptPassword(password);

    final results = await db.query(
      'USUARIO',
      where: 'email = ? AND password = ?',
      whereArgs: [email, encryptedPassword],
    );

    if (results.isNotEmpty) {
      return Usuario.fromMap(results.first);
    }
    return null;
  }

  // Obtener usuario por ID
  Future<Usuario?> obtenerUsuarioPorId(int id) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'USUARIO',
      where: 'id_usuario = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return Usuario.fromMap(results.first);
    }
    return null;
  }

  // Verificar si existe un usuario
  Future<bool> existeUsuario(String email) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'USUARIO',
      where: 'email = ?',
      whereArgs: [email],
    );
    return results.isNotEmpty;
  }
}