import 'package:flutter/material.dart';
import '../models/activity_model.dart';
import '../repositories/activity_repository.dart';

// Controller responsável por gerenciar as atividades do usuário
// Utiliza ChangeNotifier para notificar a UI sobre mudanças
class ActivityController extends ChangeNotifier {
  final ActivityRepository _activityRepository = ActivityRepository();

  List<ActivityModel> _activities = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters para acessar o estado
  List<ActivityModel> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Carrega as atividades de um usuário específico
  void loadActivities(String userId) {
    _isLoading = true;
    notifyListeners();

    _activities = _activityRepository.getActivitiesByUserId(userId);
    _isLoading = false;
    notifyListeners();
  }

  // Adiciona uma nova atividade e recarrega a lista
  bool addActivity({
    required String userId,
    required String title,
    String? description,
    required ActivityType type,
    required double distance,
    required Duration duration,
    required DateTime date,
    double? calories,
  }) {
    _errorMessage = null;

    final activity = ActivityModel(
      id: '',
      userId: userId,
      title: title,
      description: description,
      type: type,
      distance: distance,
      duration: duration,
      date: date,
      calories: calories,
    );

    _activityRepository.addActivity(activity);
    loadActivities(userId);
    return true;
  }

  // Atualiza uma atividade existente
  bool updateActivity(ActivityModel activity) {
    final result = _activityRepository.updateActivity(activity);
    if (result != null) {
      loadActivities(activity.userId);
      return true;
    }
    _errorMessage = 'Erro ao atualizar atividade.';
    notifyListeners();
    return false;
  }

  // Remove uma atividade e recarrega a lista
  bool deleteActivity(String activityId, String userId) {
    final success = _activityRepository.deleteActivity(activityId);
    if (success) {
      loadActivities(userId);
      return true;
    }
    _errorMessage = 'Erro ao remover atividade.';
    notifyListeners();
    return false;
  }

  // Calcula a distância total das atividades carregadas
  double get totalDistance {
    return _activities.fold(0.0, (sum, a) => sum + a.distance);
  }

  // Calcula o tempo total das atividades carregadas
  Duration get totalDuration {
    return _activities.fold(Duration.zero, (sum, a) => sum + a.duration);
  }

  // Retorna o total de atividades carregadas
  int get totalActivities => _activities.length;

  // Retorna atividades filtradas por tipo
  List<ActivityModel> getActivitiesByType(ActivityType type) {
    return _activities.where((a) => a.type == type).toList();
  }

  // Retorna as atividades da semana atual
  List<ActivityModel> get weekActivities {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    return _activities.where((a) => a.date.isAfter(start)).toList();
  }

  // Limpa a mensagem de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
