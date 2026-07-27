import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/workout.dart';
import '../services/storage_service.dart';

/// Bozza di allenamento in corso (persistita), per riprenderlo dalla Home.
class WorkoutDraft {
  final String discipline;
  final List<WorkoutSet> sets;
  final DateTime startedAt;
  final DateTime updatedAt;

  const WorkoutDraft({
    required this.discipline,
    required this.sets,
    required this.startedAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'discipline': discipline,
        'sets': sets.map((s) => s.toJson()).toList(),
        'startedAt': startedAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory WorkoutDraft.fromJson(Map<String, dynamic> j) {
    final updated =
        DateTime.tryParse(j['updatedAt']?.toString() ?? '') ?? DateTime.now();
    return WorkoutDraft(
      discipline: (j['discipline'] as String?) ?? 'calisthenics',
      sets: ((j['sets'] as List?) ?? [])
          .map((s) => WorkoutSet.fromJson(Map<String, dynamic>.from(s)))
          .toList(),
      startedAt: DateTime.tryParse(j['startedAt']?.toString() ?? '') ?? updated,
      updatedAt: updated,
    );
  }
}

/// Gestisce la bozza dell'allenamento in corso.
class DraftProvider extends ChangeNotifier {
  static const _key = '@calistrack/workoutDraft';
  WorkoutDraft? _draft;

  WorkoutDraft? get draft => _draft;
  bool get hasDraft => _draft != null && _draft!.sets.isNotEmpty;
  int get setCount => _draft?.sets.length ?? 0;

  /// Bozza per la disciplina indicata (se combacia).
  WorkoutDraft? draftFor(String discipline) =>
      (_draft != null && _draft!.discipline == discipline) ? _draft : null;

  Future<void> load() async {
    final raw = await StorageService.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      try {
        _draft = WorkoutDraft.fromJson(
            Map<String, dynamic>.from(jsonDecode(raw)));
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> saveDraft(String discipline, List<WorkoutSet> sets) async {
    if (sets.isEmpty) {
      await clear();
      return;
    }
    // Preserva l'inizio sessione se la bozza esiste già per la disciplina.
    final started = (_draft != null && _draft!.discipline == discipline)
        ? _draft!.startedAt
        : DateTime.now();
    _draft = WorkoutDraft(
        discipline: discipline,
        sets: sets,
        startedAt: started,
        updatedAt: DateTime.now());
    await StorageService.setString(_key, jsonEncode(_draft!.toJson()));
    notifyListeners();
  }

  Future<void> clear() async {
    _draft = null;
    await StorageService.setString(_key, '');
    notifyListeners();
  }
}
