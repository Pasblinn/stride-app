import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

// Controller responsável pela autenticação (login e cadastro)
// Utiliza ChangeNotifier para notificar a UI sobre mudanças de estado
class AuthController extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters para acessar o estado atual
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // Realiza o login verificando email e senha no repositório
  bool login(String email, String password) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final user = _userRepository.authenticate(email, password);

    if (user != null) {
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = 'Email ou senha inválidos';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Realiza o cadastro de um novo usuário com validações
  bool register(String name, String email, String password) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (_userRepository.emailExists(email)) {
      _errorMessage = 'Este email já está cadastrado';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      password: password,
    );

    _currentUser = _userRepository.addUser(newUser);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Realiza o logout limpando o usuário atual
  void logout() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Atualiza os dados do perfil do usuário logado
  bool updateProfile(String name, String email) {
    if (_currentUser == null) return false;

    final updatedUser = _currentUser!.copyWith(name: name, email: email);
    final result = _userRepository.updateUser(updatedUser);

    if (result != null) {
      _currentUser = result;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Limpa a mensagem de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
