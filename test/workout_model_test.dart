import 'package:flutter_test/flutter_test.dart';
import 'package:calistrack/models/workout.dart';

void main() {
  group('Workout serializzazione', () {
    test('round-trip toJson/fromJson preserva i dati', () {
      final w = Workout(
        id: 'abc',
        date: DateTime.utc(2026, 3, 14, 9, 30),
        discipline: 'gym',
        single: true,
        sets: const [
          WorkoutSet(exerciseId: 'bench', reps: 8, weight: 60),
          WorkoutSet(exerciseId: 'plank', sec: 45),
        ],
      );

      final back = Workout.fromJson(w.toJson());

      expect(back.id, w.id);
      expect(back.date.toIso8601String(), w.date.toIso8601String());
      expect(back.discipline, 'gym');
      expect(back.single, isTrue);
      expect(back.sets.length, 2);
      expect(back.sets.first.exerciseId, 'bench');
      expect(back.sets.first.reps, 8);
      expect(back.sets.first.weight, 60);
      expect(back.sets[1].sec, 45);
    });

    test('fromJson applica default sensati su dati mancanti', () {
      final w = Workout.fromJson({'id': 7});
      expect(w.id, '7'); // id coerced a String
      expect(w.discipline, 'calisthenics'); // default
      expect(w.single, isFalse);
      expect(w.sets, isEmpty);
    });

    test('WorkoutSet gestisce campi opzionali nulli', () {
      final s = WorkoutSet.fromJson({'exerciseId': 'x'});
      expect(s.exerciseId, 'x');
      expect(s.reps, isNull);
      expect(s.sec, isNull);
      expect(s.weight, isNull);
    });
  });
}
