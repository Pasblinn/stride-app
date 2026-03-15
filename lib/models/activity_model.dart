// Enum que define os tipos de atividade disponíveis
enum ActivityType {
  running,
  cycling,
  walking,
  hiking,
  swimming,
}

// Extensão para obter o nome legível de cada tipo de atividade
extension ActivityTypeExtension on ActivityType {
  String get displayName {
    switch (this) {
      case ActivityType.running:
        return 'Corrida';
      case ActivityType.cycling:
        return 'Ciclismo';
      case ActivityType.walking:
        return 'Caminhada';
      case ActivityType.hiking:
        return 'Trilha';
      case ActivityType.swimming:
        return 'Natação';
    }
  }

  String get icon {
    switch (this) {
      case ActivityType.running:
        return '🏃';
      case ActivityType.cycling:
        return '🚴';
      case ActivityType.walking:
        return '🚶';
      case ActivityType.hiking:
        return '⛰️';
      case ActivityType.swimming:
        return '🏊';
    }
  }
}

// Modelo que representa uma atividade física registrada
class ActivityModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final ActivityType type;
  final double distance; // em km
  final Duration duration;
  final DateTime date;
  final double? averagePace; // min/km
  final double? calories;

  ActivityModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.type,
    required this.distance,
    required this.duration,
    required this.date,
    this.averagePace,
    this.calories,
  });

  // Calcula o pace médio (min/km) a partir da distância e duração
  double get calculatedPace {
    if (distance <= 0) return 0;
    return duration.inMinutes / distance;
  }

  // Formata a duração para exibição (ex: "1h 30min")
  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min ${seconds}s';
  }

  // Formata o pace para exibição (ex: "5:30 /km")
  String get formattedPace {
    final pace = averagePace ?? calculatedPace;
    if (pace <= 0) return '--';
    final minutes = pace.floor();
    final seconds = ((pace - minutes) * 60).round();
    return '$minutes:${seconds.toString().padLeft(2, '0')} /km';
  }

  // Cria uma cópia do modelo com campos alterados
  ActivityModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    ActivityType? type,
    double? distance,
    Duration? duration,
    DateTime? date,
    double? averagePace,
    double? calories,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      date: date ?? this.date,
      averagePace: averagePace ?? this.averagePace,
      calories: calories ?? this.calories,
    );
  }
}
