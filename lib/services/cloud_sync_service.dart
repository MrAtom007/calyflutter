import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'storage_service.dart';
import 'analytics_service.dart';
import 'monetization_service.dart';

/// Salvataggio dei progressi sul cloud (Firestore) legato all'account Google.
///
/// Strategia: mirror completo delle chiavi locali (`@calistrack/...`) in un
/// documento per-utente `users/{uid}`. In questo modo TUTTI i progressi
/// (allenamenti, dati salute, obiettivi, tema, preferenze) vengono salvati e
/// ripristinati senza dover toccare i singoli provider.
///
/// NB: richiede che Firebase sia stato configurato (`flutterfire configure`) e
/// che il provider Google sia abilitato in Firebase Authentication.
class CloudSyncService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  /// True solo se Firebase è stato inizializzato correttamente
  /// (cioè `flutterfire configure` è stato eseguito e le chiavi sono valide).
  /// In esecuzione puramente locale resta false e ogni operazione è no-op.
  static bool get isConfigured => Firebase.apps.isNotEmpty;

  static bool get isSignedIn => isConfigured && _auth.currentUser != null;
  static String? get uid => isConfigured ? _auth.currentUser?.uid : null;

  static DocumentReference<Map<String, dynamic>>? _doc() {
    final id = uid;
    if (id == null) return null;
    return _db.collection('users').doc(id);
  }

  /// Autentica su Firebase usando le credenziali Google già ottenute da
  /// `google_sign_in`. Restituisce l'utente Firebase o null in caso di errore.
  static Future<User?> signInWithGoogle({
    required String? idToken,
    required String? accessToken,
  }) async {
    if (!isConfigured) return null;
    try {
      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );
      final result = await _auth.signInWithCredential(credential);
      final user = result.user;
      if (user != null) {
        // Collega identità per telemetria e monetizzazione (no-op se disattivi).
        AnalyticsService.setUser(user.uid);
        AnalyticsService.loginCompleted('google');
        MonetizationService.identify(user.uid);
      }
      return user;
    } catch (_) {
      return null;
    }
  }

  static Future<void> signOut() async {
    if (!isConfigured) return;
    _debounce?.cancel();
    try {
      await _auth.signOut();
      AnalyticsService.setUser(null);
      MonetizationService.signOut();
    } catch (_) {}
  }

  static Timer? _debounce;

  /// Richiede un backup "a breve": accorpa più modifiche ravvicinate
  /// (es. salvataggio di più allenamenti) in un'unica scrittura su Firestore.
  /// No-op se Firebase non è configurato o l'utente non è loggato.
  static void backupSoon({Duration delay = const Duration(seconds: 4)}) {
    if (!isSignedIn) return;
    _debounce?.cancel();
    _debounce = Timer(delay, () {
      backup();
    });
  }

  /// Carica tutti i progressi locali su Firestore (upload).
  static Future<bool> backup() async {
    final doc = _doc();
    if (doc == null) return false;
    try {
      final data = await StorageService.exportAll();
      await doc.set({
        'data': data,
        'updatedAt': FieldValue.serverTimestamp(),
        'email': _auth.currentUser?.email,
      }, SetOptions(merge: true));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Scarica i progressi dal cloud e li scrive nella persistenza locale.
  /// Restituisce true se è stato trovato e ripristinato un backup.
  static Future<bool> restore() async {
    final doc = _doc();
    if (doc == null) return false;
    try {
      final snap = await doc.get();
      final raw = snap.data();
      if (raw == null || raw['data'] == null) return false;
      final data = Map<String, dynamic>.from(raw['data'] as Map);
      if (data.isEmpty) return false;
      await StorageService.importAll(data);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Timestamp dell'ultimo backup sul cloud (per mostrarlo nell'UI).
  static Future<DateTime?> lastBackupAt() async {
    final doc = _doc();
    if (doc == null) return null;
    try {
      final snap = await doc.get();
      final ts = snap.data()?['updatedAt'];
      if (ts is Timestamp) return ts.toDate();
    } catch (_) {}
    return null;
  }
}
