import 'package:flutter/material.dart';
import '../repositories/usuario_repository.dart';
import '../models/usuario.dart';

class AuthService with ChangeNotifier {
  final UsuarioRepository _usuarioRepository = UsuarioRepository();
  Usuario? _currentUser;

  Usuario? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> loadUser(int userId) async {
    _currentUser = await _usuarioRepository.obtenerUsuarioPorId(userId);
    notifyListeners();
  }

  void setUser(Usuario user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}