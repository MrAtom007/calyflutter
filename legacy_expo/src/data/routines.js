// Routine predefinite: ognuna ha una lista di set con esercizio e target.
export const calisthenicsRoutines = [
  {
    id: 'full-body-beginner',
    name: 'Full Body Principiante',
    level: 'Base',
    duration: '20 min',
    description: 'Circuito completo per iniziare col calisthenics.',
    sets: [
      { exerciseId: 'pushup', reps: 8 },
      { exerciseId: 'aussie-pullup', reps: 8 },
      { exerciseId: 'squat', reps: 12 },
      { exerciseId: 'plank', sec: 30 },
      { exerciseId: 'leg-raise', reps: 10 },
    ],
  },
  {
    id: 'push-day',
    name: 'Push Day',
    level: 'Intermedio',
    duration: '30 min',
    description: 'Focus su petto, spalle e tricipiti.',
    sets: [
      { exerciseId: 'pushup', reps: 15 },
      { exerciseId: 'diamond-pushup', reps: 10 },
      { exerciseId: 'dips', reps: 10 },
      { exerciseId: 'pike-pushup', reps: 8 },
    ],
  },
  {
    id: 'pull-day',
    name: 'Pull Day',
    level: 'Intermedio',
    duration: '30 min',
    description: 'Dorsali e bicipiti, la base della schiena forte.',
    sets: [
      { exerciseId: 'pullup', reps: 8 },
      { exerciseId: 'chinup', reps: 8 },
      { exerciseId: 'aussie-pullup', reps: 12 },
    ],
  },
  {
    id: 'core-blast',
    name: 'Core Blast',
    level: 'Base',
    duration: '15 min',
    description: 'Addome e stabilità con hold statici.',
    sets: [
      { exerciseId: 'plank', sec: 45 },
      { exerciseId: 'hollow-hold', sec: 30 },
      { exerciseId: 'leg-raise', reps: 15 },
      { exerciseId: 'plank', sec: 45 },
    ],
  },
  {
    id: 'skills',
    name: 'Skills Avanzate',
    level: 'Avanzato',
    duration: '40 min',
    description: 'Lavoro sulle skill: muscle-up, pistol, L-sit.',
    sets: [
      { exerciseId: 'muscleup', reps: 3 },
      { exerciseId: 'pistol-squat', reps: 5 },
      { exerciseId: 'lsit', sec: 15 },
      { exerciseId: 'hspu', reps: 5 },
    ],
  },
];

// Routine da palestra (pesi). I pesi sono indicativi, da adattare.
export const gymRoutines = [
  {
    id: 'gym-full-body',
    name: 'Full Body Palestra',
    level: 'Base',
    duration: '45 min',
    description: 'Scheda completa per tutto il corpo, 3x settimana.',
    sets: [
      { exerciseId: 'back-squat', weight: 40, reps: 10 },
      { exerciseId: 'bench-press', weight: 30, reps: 10 },
      { exerciseId: 'barbell-row', weight: 30, reps: 10 },
      { exerciseId: 'ohp', weight: 20, reps: 10 },
      { exerciseId: 'barbell-curl', weight: 15, reps: 12 },
    ],
  },
  {
    id: 'gym-push',
    name: 'Push (Petto/Spalle/Tricipiti)',
    level: 'Intermedio',
    duration: '50 min',
    description: 'Giornata di spinta in stile split.',
    sets: [
      { exerciseId: 'bench-press', weight: 50, reps: 8 },
      { exerciseId: 'incline-bench', weight: 40, reps: 10 },
      { exerciseId: 'db-shoulder-press', weight: 16, reps: 10 },
      { exerciseId: 'lateral-raise', weight: 8, reps: 15 },
      { exerciseId: 'triceps-pushdown', weight: 25, reps: 12 },
    ],
  },
  {
    id: 'gym-pull',
    name: 'Pull (Schiena/Bicipiti)',
    level: 'Intermedio',
    duration: '50 min',
    description: 'Giornata di tirata per dorso e braccia.',
    sets: [
      { exerciseId: 'deadlift', weight: 70, reps: 6 },
      { exerciseId: 'lat-pulldown', weight: 45, reps: 10 },
      { exerciseId: 'seated-row', weight: 40, reps: 10 },
      { exerciseId: 'db-curl', weight: 12, reps: 12 },
      { exerciseId: 'hammer-curl', weight: 12, reps: 12 },
    ],
  },
  {
    id: 'gym-legs',
    name: 'Leg Day',
    level: 'Intermedio',
    duration: '55 min',
    description: 'Gambe complete: quadricipiti, femorali, polpacci.',
    sets: [
      { exerciseId: 'back-squat', weight: 60, reps: 8 },
      { exerciseId: 'romanian-deadlift', weight: 50, reps: 10 },
      { exerciseId: 'leg-press', weight: 100, reps: 12 },
      { exerciseId: 'leg-curl', weight: 30, reps: 12 },
      { exerciseId: 'calf-press', weight: 60, reps: 15 },
    ],
  },
];

export function getRoutines(discipline) {
  return discipline === 'gym' ? gymRoutines : calisthenicsRoutines;
}
