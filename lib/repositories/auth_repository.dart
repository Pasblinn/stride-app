import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthRepository {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    });

    final statusCode = response['statusCode'] as int;

    if (statusCode == 200) {
      final data = response['data'];
      return {
        'user': UserModel.fromJson(data['user']),
        'token': data['token'] as String,
        'refreshToken': data['refreshToken'] as String,
      };
    }

    if (statusCode == 401) throw Exception('Email ou senha inválidos');

    throw Exception('Erro ao fazer login. Tente novamente.');
  }

  Future<String> refresh({required String refreshToken}) async {
    final response = await _api.post('/auth/refresh', {
      'refreshToken': refreshToken,
    });

    if (response['statusCode'] == 200) {
      return response['data']['token'] as String;
    }

    throw Exception('Sessão expirada. Faça login novamente.');
  }

  Future<void> logout({required String token}) async {
    await _api.post('/auth/logout', {}, token: token);
  }
}
