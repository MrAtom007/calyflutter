import 'package:flutter/material.dart';

import '../models/health_data.dart';
import '../services/storage_service.dart';
import '../services/cloud_sync_service.dart';

/// Gestisce quali widget-metrica mostrare nella schermata Salute e in che
/// ordine. L'utente può aggiungere, rimuovere e riordinare le metriche
/// (battito, passi, sonno, calorie, SpO2, HRV, pressione, ecc.).
class HealthLayoutProvider extends ChangeNotifier {
  /// Ordine di default: tutte le metriche disponibili.
  static const List<HealthMetric> _defaults = [
    HealthMetric.heartRate,
    HealthMetric.bloodPressure,
    HealthMetric.restingHeartRate,
    HealthMetric.hrv,
    HealthMetric.spo2,
    HealthMetric.steps,
    HealthMetric.calories,
    HealthMetric.sleep,
  ];

  List<HealthMetric> _enabled = List.of(_defaults);
  List<HealthMetric> get enabled => List.unmodifiable(_enabled);

  /// Metriche non ancora presenti (disponibili da aggiungere).
  List<HealthMetric> get available =>
      _defaults.where((m) => !_enabled.contains(m)).toList();

  bool isEnabled(HealthMetric m) => _enabled.contains(m);

  Future<void> load() async {
    final saved =
        await StorageService.getStringList(StorageService.healthWidgetsKey);
    if (saved.isNotEmpty) {
      final parsed = <HealthMetric>[];
      for (final s in saved) {
        final m = HealthMetric.values.where((e) => e.name == s);
        if (m.isNotEmpty) parsed.add(m.first);
      }
      if (parsed.isNotEmpty) _enabled = parsed;
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    await StorageService.setStringList(
      StorageService.healthWidgetsKey,
      _enabled.map((e) => e.name).toList(),
    );
    CloudSyncService.backupSoon();
  }

  Future<void> add(HealthMetric m) async {
    if (_enabled.contains(m)) return;
    _enabled.add(m);
    await _persist();
    notifyListeners();
  }

  Future<void> remove(HealthMetric m) async {
    _enabled.remove(m);
    await _persist();
    notifyListeners();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _enabled.removeAt(oldIndex);
    _enabled.insert(newIndex, item);
    await _persist();
    notifyListeners();
  }

  Future<void> reset() async {
    _enabled = List.of(_defaults);
    await _persist();
    notifyListeners();
  }
}
