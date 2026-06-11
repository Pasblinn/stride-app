import 'package:flutter/material.dart';
import '../models/activity_model.dart';
import '../repositories/activity_repository.dart';

class ActivityController extends ChangeNotifier {
  final ActivityRepository _activityRepository = ActivityRepository();

  List<ActivityModel> _activities = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ActivityModel> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadActivities({required String token}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _activities = await _activityRepository.list(token: token);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addActivity({
    required String token,
    required String title,
    String? description,
    required ActivityType type,
    required double distance,
    required Duration duration,
    required DateTime date,
    double? averagePace,
    double? calories,
    List<RoutePoint>? route,
  }) async {
    _errorMessage = null;

    try {
      final activity = await _activityRepository.create(
        token: token,
        title: title,
        description: description,
        type: type,
        distance: distance,
        duration: duration,
        date: date,
        averagePace: averagePace,
        calories: calories,
        route: route,
      );

      _activities.insert(0, activity);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateActivity({
    required String token,
    required ActivityModel activity,
  }) async {
    _errorMessage = null;

    try {
      final updated = await _activityRepository.update(
        token: token,
        id: activity.id,
        title: activity.title,
        description: activity.description,
        type: activity.type,
        distance: activity.distance,
        duration: activity.duration,
        date: activity.date,
        averagePace: activity.averagePace,
        calories: activity.calories,
      );

      final index = _activities.indexWhere((a) => a.id == activity.id);
      if (index != -1) _activities[index] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteActivity({
    required String token,
    required String activityId,
  }) async {
    _errorMessage = null;

    try {
      await _activityRepository.delete(token: token, id: activityId);
      _activities.removeWhere((a) => a.id == activityId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  double get totalDistance =>
      _activities.fold(0.0, (sum, a) => sum + a.distance);

  Duration get totalDuration =>
      _activities.fold(Duration.zero, (sum, a) => sum + a.duration);

  int get totalActivities => _activities.length;

  List<ActivityModel> getActivitiesByType(ActivityType type) =>
      _activities.where((a) => a.type == type).toList();

  List<ActivityModel> get weekActivities {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    return _activities.where((a) => a.date.isAfter(start)).toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
