// Modelo que representa um usuário do aplicativo
class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final String? profileImageUrl;
  final double totalDistance; // em km
  final int totalActivities;
  final Duration totalTime;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.profileImageUrl,
    this.totalDistance = 0.0,
    this.totalActivities = 0,
    this.totalTime = Duration.zero,
  });

  // Cria uma cópia do modelo com campos alterados
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? profileImageUrl,
    double? totalDistance,
    int? totalActivities,
    Duration? totalTime,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      totalDistance: totalDistance ?? this.totalDistance,
      totalActivities: totalActivities ?? this.totalActivities,
      totalTime: totalTime ?? this.totalTime,
    );
  }
}
