import '../models/activity_model.dart';
import '../services/api_service.dart';

class ActivityRepository {
  final ApiService _api = ApiService();

  Future<List<ActivityModel>> list({required String token}) async {
    final response = await _api.get('/activities', token: token);

    if (response['statusCode'] == 200) {
      final data = response['data'] as List;
      return data.map((json) => ActivityModel.fromJson(json)).toList();
    }

    throw Exception('Erro ao buscar atividades');
  }

  Future<ActivityModel> create({
    required String token,
    required String title,
    String? description,
    required ActivityType type,
    required double distance,
    required Duration duration,
    required DateTime date,
    double? averagePace,
    double? calories,
  }) async {
    final response = await _api.post('/activities', {
      'title': title,
      'description': description,
      'type': type.name,
      'distance': distance,
      'durationSeconds': duration.inSeconds,
      'date': date.toIso8601String(),
      'averagePace': averagePace,
      'calories': calories,
    }, token: token);

    if (response['statusCode'] == 201) {
      return ActivityModel.fromJson(response['data']);
    }

    throw Exception('Erro ao criar atividade');
  }

  Future<ActivityModel> update({
    required String token,
    required String id,
    String? title,
    String? description,
    ActivityType? type,
    double? distance,
    Duration? duration,
    DateTime? date,
    double? averagePace,
    double? calories,
  }) async {
    final response = await _api.put('/activities/$id', {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (type != null) 'type': type.name,
      if (distance != null) 'distance': distance,
      if (duration != null) 'durationSeconds': duration.inSeconds,
      if (date != null) 'date': date.toIso8601String(),
      if (averagePace != null) 'averagePace': averagePace,
      if (calories != null) 'calories': calories,
    }, token: token);

    if (response['statusCode'] == 200) {
      return ActivityModel.fromJson(response['data']);
    }

    throw Exception('Erro ao atualizar atividade');
  }

  Future<void> delete({required String token, required String id}) async {
    final response = await _api.delete('/activities/$id', token: token);

    if (response['statusCode'] != 204) {
      throw Exception('Erro ao remover atividade');
    }
  }
}
