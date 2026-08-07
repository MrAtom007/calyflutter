import 'package:flutter_test/flutter_test.dart';
import 'package:calistrack/models/workout.dart';
import 'package:calistrack/data/ranks.dart';

Workout _w(String discipline, List<WorkoutSet> sets) => Workout(
  id: 't',
  date: DateTime(2026, 1, 1),
  discipline: discipline,
  sets: sets,
);

void main() {
  group('workoutPoints', () {
    test('calisthenics: reps valgono 1, secondi 0.5', () {
      final w = _w('calisthenics', const [
        WorkoutSet(exerciseId: 'pushup', reps: 20),
        WorkoutSet(exerciseId: 'plank', sec: 60),
      ]);
      // 20*1 + 60*0.5 = 50
      expect(workoutPoints(w), 50);
    });

    test('gym: peso*reps/10', () {
      final w = _w('gym', const [
        WorkoutSet(exerciseId: 'bench', reps: 10, weight: 50), // 500/10 = 50
        WorkoutSet(exerciseId: 'squat', reps: 5, weight: 100), // 500/10 = 50
      ]);
      expect(workoutPoints(w), 100);
    });

    test('set vuoto non contribuisce', () {
      final w = _w('calisthenics', const [WorkoutSet(exerciseId: 'x')]);
      expect(workoutPoints(w), 0);
    });
  });

  group('totalPoints', () {
    test('somma e arrotonda i punti di più allenamenti', () {
      final list = [
        _w('calisthenics', const [WorkoutSet(exerciseId: 'a', reps: 15)]),
        _w('calisthenics', const [WorkoutSet(exerciseId: 'b', sec: 30)]),
      ];
      // 15 + 15 = 30
      expect(totalPoints(list), 30);
    });
  });

  group('rankFor', () {
    test('parte da Legno a 0 punti', () {
      final info = rankFor(0);
      expect(info.current.id, 'wood');
      expect(info.next?.id, 'stone');
      expect(info.progress, 0);
    });

    test('seleziona il rango corretto alla soglia', () {
      expect(rankFor(300).current.id, 'stone');
      expect(rankFor(899).current.id, 'stone');
      expect(rankFor(900).current.id, 'bronze');
    });

    test('ultimo rango ha progresso pieno e next nullo', () {
      final info = rankFor(60000);
      expect(info.current.id, 'antimatter');
      expect(info.next, isNull);
      expect(info.progress, 1.0);
    });

    test('progresso è a metà tra due soglie', () {
      // wood[0]..stone[300]: 150 -> 0.5
      final info = rankFor(150);
      expect(info.current.id, 'wood');
      expect(info.progress, closeTo(0.5, 1e-9));
    });
  });

  group('levelOf', () {
    test('mappa id -> livello 1..N', () {
      expect(levelOf('wood'), 1);
      expect(levelOf('antimatter'), ranks.length);
      expect(levelOf('inesistente'), 0);
    });
  });
}
