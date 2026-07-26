import 'dart:convert';
import 'package:flutter/material.dart';

import '../models/health_data.dart';
import '../services/health_service.dart';
import '../services/google_auth_service.dart';
import '../services/home_widget_service.dart';
import '../services/storage_service.dart';

enum HealthStatus { idle, loading, ready, error }

/// Stato della sezione Salute: gestisce connessione, sincronizzazione e cache.
class HealthProvider extends ChangeNotifier {
  HealthSnapshot? _snapshot;
  HealthStatus _status = HealthStatus.idle;
  bool _connected = false;
  bool _demoMode = false;
  String? _googleEmail;
  String? _googleName;
  String? _googlePhoto;

  // Obiettivi personalizzabili.
  double _goalSteps = 10000;
  double _goalCalories = 600;
  double _goalSleep = 8;

  double get goalSteps => _goalSteps;
  double get goalCalories => _goalCalories;
  double get goalSleep => _goalSleep;

  HealthSnapshot? get snapshot => _snapshot;
  HealthStatus get status => _status;
  bool get connected => _connected;
  bool get demoMode => _demoMode;
  bool get hasData => _snapshot != null;
  bool get googleSignedIn => _googleEmail != null;
  String? get googleEmail => _googleEmail;
  String? get googleName => _googleName;
  String? get googlePhoto => _googlePhoto;

  HealthSource get source => _snapshot?.source ?? HealthSource.none;

  Future<void> load() async {
    // Ripristina cache locale.
    final raw = await StorageService.getString(StorageService.healthDataKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        _snapshot = HealthSnapshot.fromJson(
            Map<String, dynamic>.from(jsonDecode(raw)));
        _status = HealthStatus.ready;
        _demoMode = _snapshot!.source == HealthSource.demo;
      } catch (_) {}
    }
    _connected =
        (await StorageService.getBool(StorageService.healthConnectedKey)) ?? false;
    _googleEmail = await StorageService.getString(StorageService.googleAccountKey);
    final goalsRaw = await StorageService.getString(StorageService.healthGoalsKey);
    if (goalsRaw != null && goalsRaw.isNotEmpty) {
      try {
        final g = Map<String, dynamic>.from(jsonDecode(goalsRaw));
        _goalSteps = (g['steps'] as num?)?.toDouble() ?? _goalSteps;
        _goalCalories = (g['calories'] as num?)?.toDouble() ?? _goalCalories;
        _goalSleep = (g['sleep'] as num?)?.toDouble() ?? _goalSleep;
      } catch (_) {}
    }

    // Prova a ripristinare la sessione Google silenziosamente.
    final acc = await GoogleAuthService.restore();
    if (acc != null) {
      _googleEmail = acc.email;
      _googleName = acc.displayName;
      _googlePhoto = acc.photoUrl;
      await StorageService.setString(
          StorageService.googleAccountKey, acc.email);
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    if (_snapshot != null) {
      await StorageService.setString(
          StorageService.healthDataKey, jsonEncode(_snapshot!.toJson()));
      _pushWidget();
    }
    await StorageService.setBool(
        StorageService.healthConnectedKey, _connected);
  }

  void _pushWidget() {
    final hr = series(HealthMetric.heartRate);
    final steps = series(HealthMetric.steps);
    final bpm = hr?.latest ?? hr?.avg;
    final st = steps?.daily.isNotEmpty == true ? steps!.daily.last.value : null;
    HomeWidgetService.update(
      bpm: bpm?.round().toString(),
      steps: st?.round().toString(),
    );
  }

  Future<void> setGoals({double? steps, double? calories, double? sleep}) async {
    if (steps != null) _goalSteps = steps;
    if (calories != null) _goalCalories = calories;
    if (sleep != null) _goalSleep = sleep;
    await StorageService.setString(
      StorageService.healthGoalsKey,
      jsonEncode({'steps': _goalSteps, 'calories': _goalCalories, 'sleep': _goalSleep}),
    );
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Google
  // ---------------------------------------------------------------------------
  Future<bool> signInGoogle() async {
    final acc = await GoogleAuthService.signIn();
    if (acc == null) return false;
    _googleEmail = acc.email;
    _googleName = acc.displayName;
    _googlePhoto = acc.photoUrl;
    await StorageService.setString(StorageService.googleAccountKey, acc.email);
    notifyListeners();
    return true;
  }

  Future<void> signOutGoogle() async {
    await GoogleAuthService.signOut();
    _googleEmail = null;
    _googleName = null;
    _googlePhoto = null;
    await StorageService.setString(StorageService.googleAccountKey, '');
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Sincronizzazione
  // ---------------------------------------------------------------------------

  /// Collega la piattaforma salute reale (Health Connect / Apple Health).
  Future<bool> connectHealthPlatform() async {
    _status = HealthStatus.loading;
    notifyListeners();
    final available = await HealthService.isAvailable();
    if (!available) {
      _status = _snapshot != null ? HealthStatus.ready : HealthStatus.error;
      notifyListeners();
      return false;
    }
    final granted = await HealthService.requestPermissions();
    if (!granted) {
      _status = _snapshot != null ? HealthStatus.ready : HealthStatus.error;
      notifyListeners();
      return false;
    }
    _connected = true;
    _demoMode = false;
    await sync();
    return true;
  }

  /// Aggiorna i dati dalla piattaforma reale (o demo se non disponibile).
  Future<void> sync() async {
    _status = HealthStatus.loading;
    notifyListeners();
    if (_connected && !_demoMode) {
      final real = await HealthService.fetchReal();
      if (real != null) {
        _snapshot = real;
        _status = HealthStatus.ready;
        await _persist();
        notifyListeners();
        return;
      }
    }
    // Fallback demo.
    _snapshot = HealthService.demoSnapshot();
    _demoMode = true;
    _status = HealthStatus.ready;
    await _persist();
    notifyListeners();
  }

  /// Attiva esplicitamente la modalità demo (dati simulati spettacolari).
  Future<void> enableDemo() async {
    _demoMode = true;
    _connected = false;
    _snapshot = HealthService.demoSnapshot();
    _status = HealthStatus.ready;
    await _persist();
    notifyListeners();
  }

  Future<void> disconnect() async {
    _connected = false;
    _demoMode = false;
    _snapshot = null;
    _status = HealthStatus.idle;
    await StorageService.setString(StorageService.healthDataKey, '');
    await StorageService.setBool(StorageService.healthConnectedKey, false);
    notifyListeners();
  }

  Future<void> installHealthConnect() => HealthService.installHealthConnect();

  MetricSeries? series(HealthMetric m) => _snapshot?.of(m);
}
