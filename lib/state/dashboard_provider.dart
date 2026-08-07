import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// Widget disponibili per la Home personalizzabile.
enum DashWidget {
  heartWave,
  activityRings,
  vitals,
  sleep,
  workoutStats,
  rank,
  quickTimer,
  nextRoutine,
  shortcuts,
}

extension DashWidgetInfo on DashWidget {
  String get id => name;

  String get titleKey => switch (this) {
    DashWidget.heartWave => 'dw_heart',
    DashWidget.activityRings => 'dw_rings',
    DashWidget.vitals => 'dw_vitals',
    DashWidget.sleep => 'dw_sleep',
    DashWidget.workoutStats => 'dw_workout',
    DashWidget.rank => 'dw_rank',
    DashWidget.quickTimer => 'dw_timer',
    DashWidget.nextRoutine => 'dw_routine',
    DashWidget.shortcuts => 'dw_shortcuts',
  };

  IconData get icon => switch (this) {
    DashWidget.heartWave => Icons.favorite_rounded,
    DashWidget.activityRings => Icons.track_changes_rounded,
    DashWidget.vitals => Icons.monitor_heart_rounded,
    DashWidget.sleep => Icons.bedtime_rounded,
    DashWidget.workoutStats => Icons.insights_rounded,
    DashWidget.rank => Icons.military_tech_rounded,
    DashWidget.quickTimer => Icons.timer_rounded,
    DashWidget.nextRoutine => Icons.playlist_play_rounded,
    DashWidget.shortcuts => Icons.grid_view_rounded,
  };

  /// Se il widget occupa l'intera larghezza (altrimenti mezza colonna).
  bool get fullWidth => switch (this) {
    DashWidget.heartWave => true,
    DashWidget.activityRings => true,
    DashWidget.workoutStats => true,
    DashWidget.shortcuts => true,
    DashWidget.nextRoutine => true,
    _ => false,
  };
}

/// Gestisce l'ordine e l'abilitazione dei widget della Home.
class DashboardProvider extends ChangeNotifier {
  static const List<DashWidget> _defaults = [
    DashWidget.shortcuts,
    DashWidget.heartWave,
    DashWidget.activityRings,
    DashWidget.workoutStats,
    DashWidget.rank,
    DashWidget.quickTimer,
    DashWidget.vitals,
    DashWidget.sleep,
    DashWidget.nextRoutine,
  ];

  List<DashWidget> _widgets = List.of(_defaults);
  List<DashWidget> get widgets => List.unmodifiable(_widgets);

  /// Widget non ancora in dashboard (disponibili da aggiungere).
  List<DashWidget> get available =>
      DashWidget.values.where((w) => !_widgets.contains(w)).toList();

  Future<void> load() async {
    final saved = await StorageService.getStringList(
      StorageService.dashboardWidgetsKey,
    );
    if (saved.isNotEmpty) {
      final parsed = <DashWidget>[];
      for (final s in saved) {
        final w = DashWidget.values.where((e) => e.name == s);
        if (w.isNotEmpty) parsed.add(w.first);
      }
      if (parsed.isNotEmpty) _widgets = parsed;
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    await StorageService.setStringList(
      StorageService.dashboardWidgetsKey,
      _widgets.map((e) => e.name).toList(),
    );
  }

  Future<void> add(DashWidget w) async {
    if (_widgets.contains(w)) return;
    _widgets.add(w);
    await _persist();
    notifyListeners();
  }

  Future<void> remove(DashWidget w) async {
    _widgets.remove(w);
    await _persist();
    notifyListeners();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final item = _widgets.removeAt(oldIndex);
    _widgets.insert(newIndex, item);
    await _persist();
    notifyListeners();
  }

  Future<void> reset() async {
    _widgets = List.of(_defaults);
    await _persist();
    notifyListeners();
  }
}
