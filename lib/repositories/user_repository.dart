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
}
