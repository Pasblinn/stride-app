import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

// Controller responsável pela autenticação (login e cadastro)
// Utiliza ChangeNotifier para notificar a UI sobre mudanças de estado
// Persiste a sessão com SharedPreferences para manter o login ao reabrir o app
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

  // Verifica se existe uma sessão salva ao iniciar o app
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString('logged_user_id');

    if (savedUserId == null) return false;

    final user = _userRepository.getUserById(savedUserId);
    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true;
    }

    // Sessão inválida, limpa o cache
    await prefs.remove('logged_user_id');
    return false;
  }

  // Realiza o login verificando email e senha no repositório
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final user = _userRepository.authenticate(email, password);

    if (user != null) {
      _currentUser = user;
      _isLoading = false;

      // Salva a sessão no cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('logged_user_id', user.id);

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
  Future<bool> register(String name, String email, String password) async {
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

    // Salva a sessão no cache
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('logged_user_id', _currentUser!.id);

    notifyListeners();
    return true;
  }

  // Realiza o logout limpando o usuário atual e o cache
  Future<void> logout() async {
    _currentUser = null;
    _errorMessage = null;

    // Remove a sessão do cache
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_user_id');

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
