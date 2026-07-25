import { gymExercises, gymCategories } from './gym';

// Libreria completa di esercizi di calisthenics, raggruppati per categoria.
const cx = (id, name, category, unit, level) => ({
  id,
  name,
  category,
  unit,
  level,
  discipline: 'calisthenics',
});

export const calisthenicsExercises = [
  // ---- Push ----
  cx('pushup', 'Push-up', 'Push', 'reps', 'Base'),
  cx('knee-pushup', 'Push-up sulle ginocchia', 'Push', 'reps', 'Base'),
  cx('incline-pushup', 'Push-up inclinato', 'Push', 'reps', 'Base'),
  cx('decline-pushup', 'Push-up declinato', 'Push', 'reps', 'Intermedio'),
  cx('diamond-pushup', 'Diamond Push-up', 'Push', 'reps', 'Intermedio'),
  cx('wide-pushup', 'Push-up presa larga', 'Push', 'reps', 'Base'),
  cx('archer-pushup', 'Archer Push-up', 'Push', 'reps', 'Avanzato'),
  cx('pseudo-planche-pushup', 'Pseudo Planche Push-up', 'Push', 'reps', 'Avanzato'),
  cx('one-arm-pushup', 'Push-up a un braccio', 'Push', 'reps', 'Avanzato'),
  cx('dips', 'Dips alle parallele', 'Push', 'reps', 'Intermedio'),
  cx('bench-dips', 'Bench Dips', 'Push', 'reps', 'Base'),
  cx('pike-pushup', 'Pike Push-up', 'Push', 'reps', 'Intermedio'),
  cx('hspu', 'Handstand Push-up', 'Push', 'reps', 'Avanzato'),

  // ---- Pull ----
  cx('pullup', 'Pull-up', 'Pull', 'reps', 'Intermedio'),
  cx('chinup', 'Chin-up', 'Pull', 'reps', 'Intermedio'),
  cx('neutral-pullup', 'Pull-up presa neutra', 'Pull', 'reps', 'Intermedio'),
  cx('wide-pullup', 'Pull-up presa larga', 'Pull', 'reps', 'Intermedio'),
  cx('aussie-pullup', 'Australian Pull-up', 'Pull', 'reps', 'Base'),
  cx('scapular-pull', 'Scapular Pull-up', 'Pull', 'reps', 'Base'),
  cx('negative-pullup', 'Pull-up negativo', 'Pull', 'reps', 'Base'),
  cx('archer-pullup', 'Archer Pull-up', 'Pull', 'reps', 'Avanzato'),
  cx('typewriter-pullup', 'Typewriter Pull-up', 'Pull', 'reps', 'Avanzato'),
  cx('commando-pullup', 'Commando Pull-up', 'Pull', 'reps', 'Intermedio'),
  cx('muscleup', 'Muscle-up', 'Pull', 'reps', 'Avanzato'),
  cx('one-arm-pullup', 'Pull-up a un braccio', 'Pull', 'reps', 'Avanzato'),

  // ---- Legs ----
  cx('squat', 'Squat', 'Legs', 'reps', 'Base'),
  cx('sumo-squat', 'Sumo Squat', 'Legs', 'reps', 'Base'),
  cx('jump-squat', 'Jump Squat', 'Legs', 'reps', 'Intermedio'),
  cx('lunge', 'Affondi', 'Legs', 'reps', 'Base'),
  cx('bulgarian-split', 'Bulgarian Split Squat', 'Legs', 'reps', 'Intermedio'),
  cx('step-up', 'Step-up', 'Legs', 'reps', 'Base'),
  cx('glute-bridge', 'Glute Bridge', 'Legs', 'reps', 'Base'),
  cx('nordic-curl', 'Nordic Curl', 'Legs', 'reps', 'Avanzato'),
  cx('pistol-squat', 'Pistol Squat', 'Legs', 'reps', 'Avanzato'),
  cx('shrimp-squat', 'Shrimp Squat', 'Legs', 'reps', 'Avanzato'),
  cx('calf-raise', 'Calf Raise', 'Legs', 'reps', 'Base'),
  cx('wall-sit', 'Wall Sit', 'Legs', 'sec', 'Base'),

  // ---- Core ----
  cx('plank', 'Plank', 'Core', 'sec', 'Base'),
  cx('side-plank', 'Side Plank', 'Core', 'sec', 'Base'),
  cx('hollow-hold', 'Hollow Hold', 'Core', 'sec', 'Intermedio'),
  cx('lsit', 'L-sit', 'Core', 'sec', 'Avanzato'),
  cx('leg-raise', 'Leg Raise', 'Core', 'reps', 'Base'),
  cx('hanging-leg-raise', 'Hanging Leg Raise', 'Core', 'reps', 'Intermedio'),
  cx('toes-to-bar', 'Toes to Bar', 'Core', 'reps', 'Avanzato'),
  cx('crunch', 'Crunch', 'Core', 'reps', 'Base'),
  cx('bicycle-crunch', 'Bicycle Crunch', 'Core', 'reps', 'Base'),
  cx('russian-twist-bw', 'Russian Twist', 'Core', 'reps', 'Base'),
  cx('mountain-climber', 'Mountain Climber', 'Core', 'reps', 'Base'),
  cx('dragon-flag', 'Dragon Flag', 'Core', 'reps', 'Avanzato'),
  cx('plank-static', 'Front Lever (progressione)', 'Core', 'sec', 'Avanzato'),

  // ---- Skills (statiche) ----
  cx('handstand', 'Handstand', 'Skills', 'sec', 'Avanzato'),
  cx('wall-handstand', 'Handstand al muro', 'Skills', 'sec', 'Intermedio'),
  cx('crow-pose', 'Crow Pose', 'Skills', 'sec', 'Intermedio'),
  cx('tuck-planche', 'Tuck Planche', 'Skills', 'sec', 'Avanzato'),
  cx('planche', 'Full Planche', 'Skills', 'sec', 'Avanzato'),
  cx('front-lever', 'Front Lever', 'Skills', 'sec', 'Avanzato'),
  cx('back-lever', 'Back Lever', 'Skills', 'sec', 'Avanzato'),
  cx('human-flag', 'Human Flag', 'Skills', 'sec', 'Avanzato'),
  cx('elbow-lever', 'Elbow Lever', 'Skills', 'sec', 'Intermedio'),
  cx('straddle-planche', 'Straddle Planche', 'Skills', 'sec', 'Avanzato'),
  cx('v-sit', 'V-sit', 'Skills', 'sec', 'Avanzato'),
  cx('handstand-walk', 'Handstand Walk', 'Skills', 'reps', 'Avanzato'),
  cx('pseudo-planche-hold', 'Pseudo Planche Hold', 'Skills', 'sec', 'Intermedio'),
  cx('tuck-front-lever', 'Tuck Front Lever', 'Skills', 'sec', 'Intermedio'),

  // ---- Push (extra) ----
  cx('hindu-pushup', 'Hindu Push-up', 'Push', 'reps', 'Base'),
  cx('spiderman-pushup', 'Spiderman Push-up', 'Push', 'reps', 'Intermedio'),
  cx('clap-pushup', 'Clap Push-up', 'Push', 'reps', 'Avanzato'),
  cx('ring-dips', 'Ring Dips', 'Push', 'reps', 'Avanzato'),
  cx('korean-dips', 'Korean Dips', 'Push', 'reps', 'Avanzato'),
  cx('tricep-extension-bw', 'Bodyweight Tricep Ext.', 'Push', 'reps', 'Intermedio'),

  // ---- Pull (extra) ----
  cx('l-pullup', 'L Pull-up', 'Pull', 'reps', 'Avanzato'),
  cx('ice-cream-maker', 'Ice Cream Maker', 'Pull', 'reps', 'Avanzato'),
  cx('front-lever-raise', 'Front Lever Raise', 'Pull', 'reps', 'Avanzato'),
  cx('inverted-row', 'Inverted Row', 'Pull', 'reps', 'Base'),
  cx('dead-hang', 'Dead Hang', 'Pull', 'sec', 'Base'),
  cx('high-pullup', 'High Pull-up', 'Pull', 'reps', 'Avanzato'),

  // ---- Legs (extra) ----
  cx('cossack-squat', 'Cossack Squat', 'Legs', 'reps', 'Intermedio'),
  cx('sissy-squat', 'Sissy Squat', 'Legs', 'reps', 'Avanzato'),
  cx('box-jump', 'Box Jump', 'Legs', 'reps', 'Intermedio'),
  cx('single-leg-bridge', 'Single Leg Glute Bridge', 'Legs', 'reps', 'Intermedio'),
  cx('natural-leg-ext', 'Natural Leg Extension', 'Legs', 'reps', 'Avanzato'),
  cx('duck-walk', 'Duck Walk', 'Legs', 'sec', 'Intermedio'),

  // ---- Core (extra) ----
  cx('v-up', 'V-up', 'Core', 'reps', 'Intermedio'),
  cx('flutter-kick', 'Flutter Kick', 'Core', 'sec', 'Base'),
  cx('windshield-wiper', 'Windshield Wiper', 'Core', 'reps', 'Avanzato'),
  cx('ab-rollout-bw', 'Ab Rollout', 'Core', 'reps', 'Avanzato'),
  cx('plank-reach', 'Plank Reach', 'Core', 'reps', 'Intermedio'),
  cx('hanging-windshield', 'Hanging Windshield Wiper', 'Core', 'reps', 'Avanzato'),
];

export const calisthenicsCategories = ['Push', 'Pull', 'Legs', 'Core', 'Skills'];

// Tutti gli esercizi delle due discipline.
export const allExercises = [...calisthenicsExercises, ...gymExercises];

export function getExercise(id) {
  return allExercises.find((e) => e.id === id);
}

// Restituisce la libreria della disciplina richiesta.
export function getLibrary(discipline) {
  return discipline === 'gym' ? gymExercises : calisthenicsExercises;
}

export function getCategories(discipline) {
  return discipline === 'gym' ? gymCategories : calisthenicsCategories;
}

// Retrocompatibilità con i vecchi import.
export const exercises = calisthenicsExercises;
export const categories = calisthenicsCategories;
