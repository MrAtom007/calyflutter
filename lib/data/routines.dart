/// Un set target all'interno di una routine.
class RoutineSet {
  final String exerciseId;
  final int? reps;
  final int? sec;
  final double? weight;
  const RoutineSet(this.exerciseId, {this.reps, this.sec, this.weight});
}

/// Una routine predefinita.
class Routine {
  final String id;
  final String name;
  final String level;
  final String duration;
  final String description;
  final List<RoutineSet> sets;
  const Routine({
    required this.id,
    required this.name,
    required this.level,
    required this.duration,
    required this.description,
    required this.sets,
  });
}

final List<Routine> calisthenicsRoutines = [
  Routine(
    id: 'full-body-beginner',
    name: 'Full Body Principiante',
    level: 'Base',
    duration: '20 min',
    description: 'Circuito completo per iniziare col calisthenics.',
    sets: [
      RoutineSet('pushup', reps: 8),
      RoutineSet('aussie-pullup', reps: 8),
      RoutineSet('squat', reps: 12),
      RoutineSet('plank', sec: 30),
      RoutineSet('leg-raise', reps: 10),
    ],
  ),
  Routine(
    id: 'push-day',
    name: 'Push Day',
    level: 'Intermedio',
    duration: '30 min',
    description: 'Focus su petto, spalle e tricipiti.',
    sets: [
      RoutineSet('pushup', reps: 15),
      RoutineSet('diamond-pushup', reps: 10),
      RoutineSet('dips', reps: 10),
      RoutineSet('pike-pushup', reps: 8),
    ],
  ),
  Routine(
    id: 'pull-day',
    name: 'Pull Day',
    level: 'Intermedio',
    duration: '30 min',
    description: 'Dorsali e bicipiti, la base della schiena forte.',
    sets: [
      RoutineSet('pullup', reps: 8),
      RoutineSet('chinup', reps: 8),
      RoutineSet('aussie-pullup', reps: 12),
    ],
  ),
  Routine(
    id: 'core-blast',
    name: 'Core Blast',
    level: 'Base',
    duration: '15 min',
    description: 'Addome e stabilità con hold statici.',
    sets: [
      RoutineSet('plank', sec: 45),
      RoutineSet('hollow-hold', sec: 30),
      RoutineSet('leg-raise', reps: 15),
      RoutineSet('plank', sec: 45),
    ],
  ),
  Routine(
    id: 'skills',
    name: 'Skills Avanzate',
    level: 'Avanzato',
    duration: '40 min',
    description: 'Lavoro sulle skill: muscle-up, pistol, L-sit.',
    sets: [
      RoutineSet('muscleup', reps: 3),
      RoutineSet('pistol-squat', reps: 5),
      RoutineSet('lsit', sec: 15),
      RoutineSet('hspu', reps: 5),
    ],
  ),
];

final List<Routine> gymRoutines = [
  Routine(
    id: 'gym-full-body',
    name: 'Full Body Palestra',
    level: 'Base',
    duration: '45 min',
    description: 'Scheda completa per tutto il corpo, 3x settimana.',
    sets: [
      RoutineSet('back-squat', weight: 40, reps: 10),
      RoutineSet('bench-press', weight: 30, reps: 10),
      RoutineSet('barbell-row', weight: 30, reps: 10),
      RoutineSet('ohp', weight: 20, reps: 10),
      RoutineSet('barbell-curl', weight: 15, reps: 12),
    ],
  ),
  Routine(
    id: 'gym-push',
    name: 'Push (Petto/Spalle/Tricipiti)',
    level: 'Intermedio',
    duration: '50 min',
    description: 'Giornata di spinta in stile split.',
    sets: [
      RoutineSet('bench-press', weight: 50, reps: 8),
      RoutineSet('incline-bench', weight: 40, reps: 10),
      RoutineSet('db-shoulder-press', weight: 16, reps: 10),
      RoutineSet('lateral-raise', weight: 8, reps: 15),
      RoutineSet('triceps-pushdown', weight: 25, reps: 12),
    ],
  ),
  Routine(
    id: 'gym-pull',
    name: 'Pull (Schiena/Bicipiti)',
    level: 'Intermedio',
    duration: '50 min',
    description: 'Giornata di tirata per dorso e braccia.',
    sets: [
      RoutineSet('deadlift', weight: 70, reps: 6),
      RoutineSet('lat-pulldown', weight: 45, reps: 10),
      RoutineSet('seated-row', weight: 40, reps: 10),
      RoutineSet('db-curl', weight: 12, reps: 12),
      RoutineSet('hammer-curl', weight: 12, reps: 12),
    ],
  ),
  Routine(
    id: 'gym-legs',
    name: 'Leg Day',
    level: 'Intermedio',
    duration: '55 min',
    description: 'Gambe complete: quadricipiti, femorali, polpacci.',
    sets: [
      RoutineSet('back-squat', weight: 60, reps: 8),
      RoutineSet('romanian-deadlift', weight: 50, reps: 10),
      RoutineSet('leg-press', weight: 100, reps: 12),
      RoutineSet('leg-curl', weight: 30, reps: 12),
      RoutineSet('calf-press', weight: 60, reps: 15),
    ],
  ),
];

List<Routine> getRoutines(String discipline) =>
    discipline == 'gym' ? gymRoutines : calisthenicsRoutines;
