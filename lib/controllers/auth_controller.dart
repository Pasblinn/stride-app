import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';

class AuthController extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final AuthRepository _authRepository = AuthRepository();

  UserModel? _currentUser;
  String? _token;
  String? _refreshToken;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null && _token != null;

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token');
    final savedRefreshToken = prefs.getString('refresh_token');

    if (savedToken == null || savedRefreshToken == null) return false;

    try {
      final tokens = await _authRepository.refresh(
        refreshToken: savedRefreshToken,
      );

      final newToken = tokens['token']!;
      final newRefreshToken = tokens['refreshToken']!;

      _currentUser = await _authRepository.getMe(token: newToken);

      await prefs.setString('token', newToken);
      await prefs.setString('refresh_token', newRefreshToken);
      _token = newToken;
      _refreshToken = newRefreshToken;
      notifyListeners();
      return true;
    } catch (_) {
      await _clearSession(prefs);
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.login(
        email: email,
        password: password,
      );

      _currentUser = result['user'] as UserModel;
      _token = result['token'] as String;
      _refreshToken = result['refreshToken'] as String;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('refresh_token', _refreshToken!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _userRepository.create(
        name: name,
        email: email,
        password: password,
      );

      return await login(email, password);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      if (_token != null) {
        await _authRepository.logout(token: _token!);
      }
    } catch (_) {}

    _currentUser = null;
    _token = null;
    _refreshToken = null;
    _errorMessage = null;

    final prefs = await SharedPreferences.getInstance();
    await _clearSession(prefs);

    notifyListeners();
  }

  Future<bool> updateProfile(String name, String email) async {
    if (_currentUser == null || _token == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _userRepository.update(
        token: _token!,
        id: _currentUser!.id,
        name: name,
        email: email,
      );

      _currentUser = updated;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _clearSession(SharedPreferences prefs) async {
    await prefs.remove('token');
    await prefs.remove('refresh_token');
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
