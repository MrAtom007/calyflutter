import 'dart:convert';
import 'package:flutter/material.dart';

import '../models/health_data.dart';
import '../services/health_service.dart';
import '../services/google_auth_service.dart';
import '../services/cloud_sync_service.dart';
import '../services/home_widget_service.dart';
import '../services/storage_service.dart';

enum HealthStatus { idle, loading, ready, error }

/// Stato della sezione Salute: gestisce connessione, sincronizzazione e cache.
class HealthProvider extends ChangeNotifier {
  HealthSnapshot? _snapshot;
  HealthStatus _status = HealthStatus.idle;
  bool _connected = false;
  String? _googleEmail;
  String? _googleName;
  String? _googlePhoto;

  /// Callback impostata da main.dart per ricaricare TUTTI i provider dopo il
  /// ripristino di un backup dal cloud.
  Future<void> Function()? onCloudRestored;
  bool _cloudBusy = false;
  DateTime? _lastCloudBackup;

  bool get cloudBusy => _cloudBusy;
  bool get cloudSignedIn => CloudSyncService.isSignedIn;
  DateTime? get lastCloudBackup => _lastCloudBackup;

  // Sorgente dispositivo/app selezionata (null = tutte le sorgenti).
  String? _selectedSource;
  String? get selectedSource => _selectedSource;
  List<String> get availableSources => _snapshot?.sources ?? const [];

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
          Map<String, dynamic>.from(jsonDecode(raw)),
        );
        _status = HealthStatus.ready;
      } catch (_) {}
    }
    _connected =
        (await StorageService.getBool(StorageService.healthConnectedKey)) ??
        false;
    final src = await StorageService.getString(StorageService.healthSourceKey);
    _selectedSource = (src == null || src.isEmpty) ? null : src;
    _googleEmail = await StorageService.getString(
      StorageService.googleAccountKey,
    );
    final goalsRaw = await StorageService.getString(
      StorageService.healthGoalsKey,
    );
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
        StorageService.googleAccountKey,
        acc.email,
      );
    }

    // Firebase mantiene la propria sessione: se già autenticato, ripristina
    // eventuali progressi più recenti dal cloud all'avvio.
    if (CloudSyncService.isSignedIn) {
      final restored = await CloudSyncService.restore();
      if (restored) {
        await onCloudRestored?.call();
      }
      _lastCloudBackup = await CloudSyncService.lastBackupAt();
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    if (_snapshot != null) {
      await StorageService.setString(
        StorageService.healthDataKey,
        jsonEncode(_snapshot!.toJson()),
      );
      _pushWidget();
    }
    await StorageService.setBool(StorageService.healthConnectedKey, _connected);
    // Salva i dati salute sul cloud (debounced), se l'account è collegato.
    CloudSyncService.backupSoon();
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

  Future<void> setGoals({
    double? steps,
    double? calories,
    double? sleep,
  }) async {
    if (steps != null) _goalSteps = steps;
    if (calories != null) _goalCalories = calories;
    if (sleep != null) _goalSleep = sleep;
    await StorageService.setString(
      StorageService.healthGoalsKey,
      jsonEncode({
        'steps': _goalSteps,
        'calories': _goalCalories,
        'sleep': _goalSleep,
      }),
    );
    notifyListeners();
    CloudSyncService.backupSoon();
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

    // Autentica su Firebase e ripristina/salva i progressi sul cloud.
    await _cloudLogin();
    return true;
  }

  Future<void> signOutGoogle() async {
    // Salva un ultimo backup prima di uscire, così i progressi non si perdono.
    if (CloudSyncService.isSignedIn) {
      await CloudSyncService.backup();
    }
    await CloudSyncService.signOut();
    await GoogleAuthService.signOut();
    _googleEmail = null;
    _googleName = null;
    _googlePhoto = null;
    _lastCloudBackup = null;
    await StorageService.setString(StorageService.googleAccountKey, '');
    notifyListeners();
  }

  /// Autentica su Firebase con le credenziali Google e sincronizza i progressi:
  /// se esiste un backup nel cloud lo ripristina (e ricarica i provider),
  /// altrimenti carica lo stato locale attuale come primo backup.
  Future<void> _cloudLogin() async {
    _cloudBusy = true;
    notifyListeners();
    try {
      final t = await GoogleAuthService.tokens();
      final user = await CloudSyncService.signInWithGoogle(
        idToken: t.idToken,
        accessToken: t.accessToken,
      );
      if (user != null) {
        final restored = await CloudSyncService.restore();
        if (restored) {
          // Ricarica tutti i provider dai dati ripristinati.
          await onCloudRestored?.call();
          await load();
        } else {
          // Nessun backup remoto: crea il primo dallo stato locale.
          await CloudSyncService.backup();
        }
        _lastCloudBackup = await CloudSyncService.lastBackupAt();
      }
    } catch (_) {
    } finally {
      _cloudBusy = false;
      notifyListeners();
    }
  }

  /// Salva manualmente lo stato locale sul cloud.
  Future<bool> backupToCloud() async {
    if (!CloudSyncService.isSignedIn) return false;
    _cloudBusy = true;
    notifyListeners();
    final ok = await CloudSyncService.backup();
    if (ok) _lastCloudBackup = await CloudSyncService.lastBackupAt();
    _cloudBusy = false;
    notifyListeners();
    return ok;
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
    await sync();
    return true;
  }

  /// Aggiorna i dati dalla piattaforma salute reale (Health Connect /
  /// Apple Health). Se non ci sono dati reali, non inventa nulla: mantiene lo
  /// stato precedente o segnala l'assenza di dati.
  Future<void> sync() async {
    if (!_connected) return;
    _status = HealthStatus.loading;
    notifyListeners();
    final real = await HealthService.fetchReal(selectedSource: _selectedSource);
    if (real != null) {
      _snapshot = real;
      _status = HealthStatus.ready;
      await _persist();
    } else {
      _status = _snapshot != null ? HealthStatus.ready : HealthStatus.error;
    }
    notifyListeners();
  }

  /// Sceglie il dispositivo/app sorgente dei dati (es. l'orologio Xiaomi).
  /// Passa `null` per usare tutte le sorgenti. Ricarica subito i dati.
  Future<void> setSource(String? source) async {
    _selectedSource = source;
    await StorageService.setString(
      StorageService.healthSourceKey,
      source ?? '',
    );
    notifyListeners();
    if (_connected) {
      await sync();
    }
  }

  Future<void> disconnect() async {
    _connected = false;
    _snapshot = null;
    _status = HealthStatus.idle;
    await StorageService.setString(StorageService.healthDataKey, '');
    await StorageService.setBool(StorageService.healthConnectedKey, false);
    notifyListeners();
  }

  Future<void> installHealthConnect() => HealthService.installHealthConnect();

  MetricSeries? series(HealthMetric m) => _snapshot?.of(m);
}
