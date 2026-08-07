import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Telemetria di prodotto (Firebase Analytics) e crash reporting (Crashlytics).
///
/// Stessa filosofia degli altri service: se Firebase non è configurato
/// (`flutterfire configure` non eseguito) ogni chiamata è un no-op silenzioso,
/// così l'app continua a funzionare in locale senza dipendere dal backend.
///
/// In debug la raccolta è disattivata per non inquinare i dati di produzione.
class AnalyticsService {
  static bool _enabled = false;

  static FirebaseAnalytics? _analytics;

  /// Osservatore da agganciare a `MaterialApp.navigatorObservers` per tracciare
  /// automaticamente le schermate (`screen_view`). È null finché non si inizializza.
  static FirebaseAnalyticsObserver? observer;

  static bool get isEnabled => _enabled;

  /// Inizializza analytics + crashlytics. Va chiamata dopo `Firebase.initializeApp`.
  /// Non lancia mai: cattura qualunque errore e in caso lascia tutto disattivato.
  static Future<void> init() async {
    if (Firebase.apps.isEmpty) return; // Firebase non configurato -> no-op
    try {
      _analytics = FirebaseAnalytics.instance;
      observer = FirebaseAnalyticsObserver(analytics: _analytics!);

      // Niente telemetria/crash in debug: solo build di release.
      final collect = kReleaseMode;
      await _analytics!.setAnalyticsCollectionEnabled(collect);
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        collect,
      );

      // Instrada gli errori Flutter e async verso Crashlytics.
      final flutterOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        flutterOnError?.call(details);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      _enabled = true;
    } catch (_) {
      _enabled = false;
    }
  }

  /// Logga un evento custom. Sanitizza i nomi parametro (solo eventi definiti qui).
  static Future<void> log(String name, [Map<String, Object>? params]) async {
    if (!_enabled) return;
    try {
      await _analytics?.logEvent(name: name, parameters: params);
    } catch (_) {}
  }

  /// Associa (o rimuove, con null) l'utente corrente per segmentare i dati.
  static Future<void> setUser(String? uid) async {
    if (!_enabled) return;
    try {
      await _analytics?.setUserId(id: uid);
      if (uid != null) {
        await FirebaseCrashlytics.instance.setUserIdentifier(uid);
      }
    } catch (_) {}
  }

  static Future<void> setUserProperty(String name, String? value) async {
    if (!_enabled) return;
    try {
      await _analytics?.setUserProperty(name: name, value: value);
    } catch (_) {}
  }

  /// Registra un errore non fatale (es. eccezione catturata in un try/catch).
  static Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
  }) async {
    if (!_enabled) return;
    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        reason: reason,
        fatal: false,
      );
    } catch (_) {}
  }

  // ---- Eventi di dominio (helper tipati, per evitare stringhe sparse) ----

  static Future<void> appOpen() => log('app_open');

  static Future<void> workoutSaved({
    required String discipline,
    required int sets,
    required int points,
    bool single = false,
  }) => log('workout_saved', {
    'discipline': discipline,
    'sets': sets,
    'points': points,
    'single': single,
  });

  static Future<void> onboardingCompleted() => log('onboarding_completed');

  static Future<void> levelUp(int level, String rankId) =>
      log('level_up', {'level': level, 'rank': rankId});

  static Future<void> storeUnlock(
    String itemId, {
    required bool paid,
    double? price,
  }) {
    final params = <String, Object>{'item': itemId, 'paid': paid};
    if (price != null) params['price'] = price;
    return log('store_unlock', params);
  }

  static Future<void> purchase(
    String productId,
    double price,
    String currency,
  ) => log('purchase_completed', {
    'product': productId,
    'price': price,
    'currency': currency,
  });

  static Future<void> loginCompleted(String method) =>
      log('login_completed', {'method': method});
}
