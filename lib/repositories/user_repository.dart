import '../models/user_model.dart';

// Repositório em memória para gerenciar dados de usuários
// Na Parte 2, será substituído por banco de dados
class UserRepository {
  // Simula um banco de dados em memória com lista de usuários
  final List<UserModel> _users = [
    UserModel(
      id: '1',
      name: 'Pablo',
      email: 'pablo@gmail.com',
      password: '123456',
      totalDistance: 127.5,
      totalActivities: 23,
      totalTime: const Duration(hours: 18, minutes: 45),
    ),
    UserModel(
      id: '2',
      name: 'Fabio',
      email: 'fabio@gmail.com',
      password: '123456',
      totalDistance: 55.9,
      totalActivities: 16,
      totalTime: const Duration(hours: 14, minutes: 15),
    ),
  ];

  // Busca usuário por email e senha para login
  UserModel? authenticate(String email, String password) {
    try {
      return _users.firstWhere(
        (user) => user.email == email && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  // Verifica se já existe um usuário com o email informado
  bool emailExists(String email) {
    return _users.any((user) => user.email == email);
  }

  // Adiciona um novo usuário (cadastro)
  UserModel addUser(UserModel user) {
    _users.add(user);
    return user;
  }

  // Atualiza os dados de um usuário existente
  UserModel? updateUser(UserModel updatedUser) {
    final index = _users.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
      return updatedUser;
    }
    return null;
  }

  // Busca um usuário pelo ID
  UserModel? getUserById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }
}
