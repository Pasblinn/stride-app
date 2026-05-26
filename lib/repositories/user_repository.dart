import '../models/user_model.dart';
import '../services/api_service.dart';

class UserRepository {
  final ApiService _api = ApiService();

  Future<UserModel> create({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _api.post('/users', {
      'name': name,
      'email': email,
      'password': password,
    });

    if (response['statusCode'] == 201) {
      return UserModel.fromJson(response['data']);
    }

    throw Exception(response['data']?['message'] ?? 'Erro ao cadastrar usuário');
  }

  Future<UserModel> update({
    required String token,
    required String id,
    String? name,
    String? email,
    String? password,
    String? profileImageUrl,
  }) async {
    final response = await _api.put('/users/$id', {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
    }, token: token);

    final statusCode = response['statusCode'] as int;

    if (statusCode == 200) {
      return UserModel.fromJson(response['data']);
    }

    if (statusCode == 409) throw Exception('Email já cadastrado');

    throw Exception(response['data']?['message'] ?? 'Erro ao atualizar usuário');
  }
}
