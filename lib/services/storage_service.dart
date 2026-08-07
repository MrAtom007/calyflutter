import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout.dart';
import 'crypto_service.dart';

/// Persistenza locale (equivalente a AsyncStorage dell'app Expo).
class StorageService {
  static const workoutsKey = '@calistrack/workouts';
  static const onboardingKey = '@calistrack/onboarded';
  static const lastLevelKey = '@calistrack/lastLevel';
  static const photoKey = '@calistrack/exercisePhotos';
  static const videoKey = '@calistrack/exerciseVideos';
  static const themeKey = '@calistrack/themeId';
  static const glowKey = '@calistrack/glow';
  static const unlockedKey = '@calistrack/unlocked';
  static const disciplineKey = '@calistrack/discipline';
  static const reminderKey = '@calistrack/reminder';
  // Salute / wearable
  static const healthDataKey = '@calistrack/healthData';
  static const healthConnectedKey = '@calistrack/healthConnected';
  static const googleAccountKey = '@calistrack/googleAccount';
  static const healthGoalsKey = '@calistrack/healthGoals';
  // Dispositivo/app sorgente scelto per i dati salute (es. Xiaomi/Mi Fitness).
  static const healthSourceKey = '@calistrack/healthSource';
  // Dashboard personalizzabile
  static const dashboardWidgetsKey = '@calistrack/dashboardWidgets';
  // Widget personalizzabili della schermata Salute
  static const healthWidgetsKey = '@calistrack/healthWidgets';
  // Aspetto / personalizzazione
  static const accentKey = '@calistrack/accent';
  static const densityKey = '@calistrack/density';
  static const cardStyleKey = '@calistrack/cardStyle';
  static const appIconKey = '@calistrack/appIcon';
  static const emblemStyleKey = '@calistrack/emblemStyle';
  static const emblemFollowKey = '@calistrack/emblemFollowIcon';
  static const iconFollowThemeKey = '@calistrack/iconFollowsTheme';

  static SharedPreferences? _prefs;
  static Future<SharedPreferences> get _p async =>
      _prefs ??= await SharedPreferences.getInstance();

  // ---------- Workouts ----------
  static Future<List<Workout>> _readAll() async {
    final p = await _p;
    final raw = p.getString(workoutsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final parsed = jsonDecode(raw);
      if (parsed is Map && parsed['__enc'] != null) {
        final plain = await CryptoService.decryptString(parsed['data']);
        final list = jsonDecode(plain) as List;
        return list
            .map((e) => Workout.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      final list = parsed as List;
      return list
          .map((e) => Workout.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _writeAll(List<Workout> list) async {
    final p = await _p;
    final json = jsonEncode(list.map((w) => w.toJson()).toList());
    if (await CryptoService.isEncryptionEnabled()) {
      final data = await CryptoService.encryptString(json);
      await p.setString(workoutsKey, jsonEncode({'__enc': 1, 'data': data}));
    } else {
      await p.setString(workoutsKey, json);
    }
  }

  /// Tutti gli allenamenti, oppure filtrati per disciplina.
  static Future<List<Workout>> getWorkouts([String? discipline]) async {
    final all = await _readAll();
    if (discipline == null) return all;
    return all.where((w) => w.discipline == discipline).toList();
  }

  static Future<List<Workout>> saveWorkout(Workout w) async {
    final all = await _readAll();
    final updated = [w, ...all];
    await _writeAll(updated);
    return updated;
  }

  /// Aggiorna un allenamento esistente (per id), preservandone la posizione.
  static Future<List<Workout>> updateWorkout(Workout w) async {
    final all = await _readAll();
    final idx = all.indexWhere((e) => e.id == w.id);
    if (idx >= 0) {
      all[idx] = w;
    } else {
      all.insert(0, w);
    }
    await _writeAll(all);
    return all;
  }

  static Future<List<Workout>> deleteWorkout(String id) async {
    final all = await _readAll();
    final updated = all.where((w) => w.id != id).toList();
    await _writeAll(updated);
    return updated;
  }

  static Future<List<Workout>> importWorkouts(
    List<Workout> list, {
    bool merge = true,
  }) async {
    final base = merge ? await _readAll() : <Workout>[];
    final byId = <String, Workout>{};
    for (final w in [...list, ...base]) {
      byId[w.id] = w;
    }
    final merged = byId.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    await _writeAll(merged);
    return merged;
  }

  static Future<void> clearAll() async {
    final p = await _p;
    await p.remove(workoutsKey);
  }

  // ---------- Encryption toggle ----------
  static Future<bool> isEncryptionEnabled() =>
      CryptoService.isEncryptionEnabled();

  static Future<void> enableEncryption() async {
    final all = await _readAll();
    await CryptoService.ensureKey();
    await CryptoService.setEncryptionFlag(true);
    await _writeAll(all);
  }

  static Future<void> disableEncryption() async {
    final all = await _readAll();
    await CryptoService.setEncryptionFlag(false);
    await _writeAll(all);
  }

  // ---------- Onboarding ----------
  static Future<bool> hasOnboarded() async {
    final p = await _p;
    return p.getString(onboardingKey) == 'true';
  }

  static Future<void> setOnboarded(bool value) async {
    final p = await _p;
    if (value) {
      await p.setString(onboardingKey, 'true');
    } else {
      await p.remove(onboardingKey);
    }
  }

  // ---------- Last level ----------
  static Future<int?> getLastLevel(String discipline) async {
    final p = await _p;
    final raw = p.getString(lastLevelKey);
    if (raw == null) return null;
    final map = jsonDecode(raw) as Map;
    return (map[discipline] as num?)?.toInt();
  }

  static Future<void> setLastLevel(String discipline, int level) async {
    final p = await _p;
    final raw = p.getString(lastLevelKey);
    final map = raw != null ? Map<String, dynamic>.from(jsonDecode(raw)) : {};
    map[discipline] = level;
    await p.setString(lastLevelKey, jsonEncode(map));
  }

  // ---------- Media personalizzati ----------
  static Future<String?> getExercisePhoto(String id) => _getMap(photoKey, id);
  static Future<void> setExercisePhoto(String id, String? uri) =>
      _setMap(photoKey, id, uri);
  static Future<String?> getExerciseVideo(String id) => _getMap(videoKey, id);
  static Future<void> setExerciseVideo(String id, String? uri) =>
      _setMap(videoKey, id, uri);

  static Future<String?> _getMap(String key, String id) async {
    final p = await _p;
    final raw = p.getString(key);
    if (raw == null) return null;
    final map = jsonDecode(raw) as Map;
    return map[id] as String?;
  }

  static Future<void> _setMap(String key, String id, String? uri) async {
    final p = await _p;
    final raw = p.getString(key);
    final map = raw != null ? Map<String, dynamic>.from(jsonDecode(raw)) : {};
    if (uri != null) {
      map[id] = uri;
    } else {
      map.remove(id);
    }
    await p.setString(key, jsonEncode(map));
  }

  // ---------- Preferenze semplici ----------
  static Future<String?> getString(String key) async =>
      (await _p).getString(key);
  static Future<void> setString(String key, String value) async =>
      (await _p).setString(key, value);
  static Future<List<String>> getStringList(String key) async =>
      (await _p).getStringList(key) ?? [];
  static Future<void> setStringList(String key, List<String> v) async =>
      (await _p).setStringList(key, v);
  static Future<bool?> getBool(String key) async => (await _p).getBool(key);
  static Future<void> setBool(String key, bool v) async =>
      (await _p).setBool(key, v);

  // ---------- Backup completo (cloud sync) ----------

  /// Esporta tutte le chiavi dell'app (`@calistrack/...`) in una mappa
  /// serializzabile, preservando il tipo di ogni valore. Usata dal
  /// [CloudSyncService] per salvare i progressi su Firestore.
  static Future<Map<String, dynamic>> exportAll() async {
    final p = await _p;
    final out = <String, dynamic>{};
    for (final key in p.getKeys()) {
      if (!key.startsWith('@calistrack/')) continue;
      final value = p.get(key);
      if (value == null) continue;
      final String type;
      final dynamic data;
      if (value is String) {
        type = 's';
        data = value;
      } else if (value is bool) {
        type = 'b';
        data = value;
      } else if (value is int) {
        type = 'i';
        data = value;
      } else if (value is double) {
        type = 'd';
        data = value;
      } else if (value is List<String>) {
        type = 'l';
        data = value;
      } else {
        continue;
      }
      out[key] = {'t': type, 'v': data};
    }
    return out;
  }

  /// Ripristina le chiavi esportate da [exportAll] nella persistenza locale.
  static Future<void> importAll(Map<String, dynamic> data) async {
    final p = await _p;
    for (final entry in data.entries) {
      final key = entry.key;
      if (!key.startsWith('@calistrack/')) continue;
      final v = entry.value;
      if (v is! Map) continue;
      final type = v['t'];
      final value = v['v'];
      try {
        switch (type) {
          case 's':
            await p.setString(key, value as String);
            break;
          case 'b':
            await p.setBool(key, value as bool);
            break;
          case 'i':
            await p.setInt(key, (value as num).toInt());
            break;
          case 'd':
            await p.setDouble(key, (value as num).toDouble());
            break;
          case 'l':
            await p.setStringList(
              key,
              (value as List).map((e) => e.toString()).toList(),
            );
            break;
        }
      } catch (_) {}
    }
  }
}
