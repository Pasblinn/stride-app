import '../models/activity_model.dart';

// Repositório em memória para gerenciar dados de atividades
// Na Parte 2, será substituído por banco de dados
class ActivityRepository {
  // Simula um banco de dados em memória com atividades pré-cadastradas
  final List<ActivityModel> _activities = [
    ActivityModel(
      id: '1',
      userId: '1',
      title: 'Corrida matinal no parque',
      description: 'Corrida leve pelo Parque Ibirapuera',
      type: ActivityType.running,
      distance: 5.2,
      duration: const Duration(minutes: 28, seconds: 30),
      date: DateTime.now().subtract(const Duration(days: 1)),
      averagePace: 5.48,
      calories: 420,
    ),
    ActivityModel(
      id: '2',
      userId: '1',
      title: 'Pedal de fim de semana',
      description: 'Ciclismo pela ciclovia da marginal',
      type: ActivityType.cycling,
      distance: 25.0,
      duration: const Duration(hours: 1, minutes: 15),
      date: DateTime.now().subtract(const Duration(days: 3)),
      averagePace: 3.0,
      calories: 650,
    ),
    ActivityModel(
      id: '3',
      userId: '1',
      title: 'Caminhada no bairro',
      type: ActivityType.walking,
      distance: 3.8,
      duration: const Duration(minutes: 45),
      date: DateTime.now().subtract(const Duration(days: 5)),
      calories: 180,
    ),
    ActivityModel(
      id: '4',
      userId: '1',
      title: 'Trilha na Serra',
      description: 'Trilha do Pico do Jaraguá',
      type: ActivityType.hiking,
      distance: 8.5,
      duration: const Duration(hours: 2, minutes: 40),
      date: DateTime.now().subtract(const Duration(days: 7)),
      calories: 780,
    ),
    ActivityModel(
      id: '5',
      userId: '1',
      title: 'Corrida intervalada',
      description: 'Treino de intervalos na pista',
      type: ActivityType.running,
      distance: 6.0,
      duration: const Duration(minutes: 32),
      date: DateTime.now().subtract(const Duration(days: 2)),
      averagePace: 5.33,
      calories: 490,
    ),
  ];

  int _nextId = 6;

  // Retorna todas as atividades de um usuário ordenadas por data
  List<ActivityModel> getActivitiesByUserId(String userId) {
    final userActivities =
        _activities.where((a) => a.userId == userId).toList();
    userActivities.sort((a, b) => b.date.compareTo(a.date));
    return userActivities;
  }

  // Busca uma atividade específica pelo ID
  ActivityModel? getActivityById(String id) {
    try {
      return _activities.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  // Adiciona uma nova atividade
  ActivityModel addActivity(ActivityModel activity) {
    final newActivity = activity.copyWith(id: _nextId.toString());
    _nextId++;
    _activities.add(newActivity);
    return newActivity;
  }

  // Atualiza uma atividade existente
  ActivityModel? updateActivity(ActivityModel updatedActivity) {
    final index = _activities.indexWhere((a) => a.id == updatedActivity.id);
    if (index != -1) {
      _activities[index] = updatedActivity;
      return updatedActivity;
    }
    return null;
  }

  // Remove uma atividade pelo ID
  bool deleteActivity(String id) {
    final initialLength = _activities.length;
    _activities.removeWhere((a) => a.id == id);
    return _activities.length < initialLength;
  }

  // Retorna as atividades da semana atual de um usuário
  List<ActivityModel> getWeekActivities(String userId) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    return _activities
        .where((a) => a.userId == userId && a.date.isAfter(start))
        .toList();
  }
}
