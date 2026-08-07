import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../services/storage_service.dart';
import '../services/cloud_sync_service.dart';
import '../services/analytics_service.dart';
import '../data/ranks.dart';

/// Cache reattiva degli allenamenti.
class WorkoutProvider extends ChangeNotifier {
  List<Workout> _all = [];
  bool ready = false;

  List<Workout> get all => _all;

  List<Workout> forDiscipline(String d) =>
      _all.where((w) => w.discipline == d).toList();

  Future<void> load() async {
    _all = await StorageService.getWorkouts();
    ready = true;
    notifyListeners();
  }

  Future<void> save(Workout w) async {
    _all = await StorageService.saveWorkout(w);
    notifyListeners();
    CloudSyncService.backupSoon();
    AnalyticsService.workoutSaved(
      discipline: w.discipline,
      sets: w.sets.length,
      points: workoutPoints(w).round(),
      single: w.single,
    );
  }

  Future<void> update(Workout w) async {
    _all = await StorageService.updateWorkout(w);
    notifyListeners();
    CloudSyncService.backupSoon();
  }

  Future<void> delete(String id) async {
    _all = await StorageService.deleteWorkout(id);
    notifyListeners();
    CloudSyncService.backupSoon();
  }

  Future<void> clear() async {
    await StorageService.clearAll();
    _all = [];
    notifyListeners();
    CloudSyncService.backupSoon();
  }

  Future<void> reencrypt() async {
    // ricarica dopo cambio cifratura
    _all = await StorageService.getWorkouts();
    notifyListeners();
  }
}
