/// Un singolo set registrato.
class WorkoutSet {
  final String exerciseId;
  final int? reps;
  final int? sec;
  final double? weight;

  const WorkoutSet({
    required this.exerciseId,
    this.reps,
    this.sec,
    this.weight,
  });

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'reps': reps,
        'sec': sec,
        'weight': weight,
      };

  factory WorkoutSet.fromJson(Map<String, dynamic> j) => WorkoutSet(
        exerciseId: j['exerciseId'] as String,
        reps: (j['reps'] as num?)?.toInt(),
        sec: (j['sec'] as num?)?.toInt(),
        weight: (j['weight'] as num?)?.toDouble(),
      );
}

/// Un allenamento completo.
class Workout {
  final String id;
  final DateTime date;

  /// 'calisthenics' | 'gym'
  final String discipline;

  /// true se registrato dal quick-log di ExerciseDetail.
  final bool single;
  final List<WorkoutSet> sets;

  const Workout({
    required this.id,
    required this.date,
    required this.discipline,
    this.single = false,
    required this.sets,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'discipline': discipline,
        'single': single,
        'sets': sets.map((s) => s.toJson()).toList(),
      };

  factory Workout.fromJson(Map<String, dynamic> j) => Workout(
        id: j['id'].toString(),
        date: DateTime.tryParse(j['date']?.toString() ?? '') ?? DateTime.now(),
        discipline: (j['discipline'] as String?) ?? 'calisthenics',
        single: j['single'] == true,
        sets: ((j['sets'] as List?) ?? [])
            .map((s) => WorkoutSet.fromJson(Map<String, dynamic>.from(s)))
            .toList(),
      );
}
