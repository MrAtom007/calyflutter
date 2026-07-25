import '../models/exercise.dart';
import 'gym.dart';

Exercise _cx(String id, String name, String category, String unit, String level) =>
    Exercise(
      id: id,
      name: name,
      category: category,
      unit: unit,
      level: level,
      discipline: 'calisthenics',
    );

/// Libreria completa di esercizi calisthenics.
final List<Exercise> calisthenicsExercises = [
  // Push
  _cx('pushup', 'Push-up', 'Push', 'reps', 'Base'),
  _cx('knee-pushup', 'Push-up sulle ginocchia', 'Push', 'reps', 'Base'),
  _cx('incline-pushup', 'Push-up inclinato', 'Push', 'reps', 'Base'),
  _cx('decline-pushup', 'Push-up declinato', 'Push', 'reps', 'Intermedio'),
  _cx('diamond-pushup', 'Diamond Push-up', 'Push', 'reps', 'Intermedio'),
  _cx('wide-pushup', 'Push-up presa larga', 'Push', 'reps', 'Base'),
  _cx('archer-pushup', 'Archer Push-up', 'Push', 'reps', 'Avanzato'),
  _cx('pseudo-planche-pushup', 'Pseudo Planche Push-up', 'Push', 'reps', 'Avanzato'),
  _cx('one-arm-pushup', 'Push-up a un braccio', 'Push', 'reps', 'Avanzato'),
  _cx('dips', 'Dips alle parallele', 'Push', 'reps', 'Intermedio'),
  _cx('bench-dips', 'Bench Dips', 'Push', 'reps', 'Base'),
  _cx('pike-pushup', 'Pike Push-up', 'Push', 'reps', 'Intermedio'),
  _cx('hspu', 'Handstand Push-up', 'Push', 'reps', 'Avanzato'),
  // Pull
  _cx('pullup', 'Pull-up', 'Pull', 'reps', 'Intermedio'),
  _cx('chinup', 'Chin-up', 'Pull', 'reps', 'Intermedio'),
  _cx('neutral-pullup', 'Pull-up presa neutra', 'Pull', 'reps', 'Intermedio'),
  _cx('wide-pullup', 'Pull-up presa larga', 'Pull', 'reps', 'Intermedio'),
  _cx('aussie-pullup', 'Australian Pull-up', 'Pull', 'reps', 'Base'),
  _cx('scapular-pull', 'Scapular Pull-up', 'Pull', 'reps', 'Base'),
  _cx('negative-pullup', 'Pull-up negativo', 'Pull', 'reps', 'Base'),
  _cx('archer-pullup', 'Archer Pull-up', 'Pull', 'reps', 'Avanzato'),
  _cx('typewriter-pullup', 'Typewriter Pull-up', 'Pull', 'reps', 'Avanzato'),
  _cx('commando-pullup', 'Commando Pull-up', 'Pull', 'reps', 'Intermedio'),
  _cx('muscleup', 'Muscle-up', 'Pull', 'reps', 'Avanzato'),
  _cx('one-arm-pullup', 'Pull-up a un braccio', 'Pull', 'reps', 'Avanzato'),
  // Legs
  _cx('squat', 'Squat', 'Legs', 'reps', 'Base'),
  _cx('sumo-squat', 'Sumo Squat', 'Legs', 'reps', 'Base'),
  _cx('jump-squat', 'Jump Squat', 'Legs', 'reps', 'Intermedio'),
  _cx('lunge', 'Affondi', 'Legs', 'reps', 'Base'),
  _cx('bulgarian-split', 'Bulgarian Split Squat', 'Legs', 'reps', 'Intermedio'),
  _cx('step-up', 'Step-up', 'Legs', 'reps', 'Base'),
  _cx('glute-bridge', 'Glute Bridge', 'Legs', 'reps', 'Base'),
  _cx('nordic-curl', 'Nordic Curl', 'Legs', 'reps', 'Avanzato'),
  _cx('pistol-squat', 'Pistol Squat', 'Legs', 'reps', 'Avanzato'),
  _cx('shrimp-squat', 'Shrimp Squat', 'Legs', 'reps', 'Avanzato'),
  _cx('calf-raise', 'Calf Raise', 'Legs', 'reps', 'Base'),
  _cx('wall-sit', 'Wall Sit', 'Legs', 'sec', 'Base'),
  // Core
  _cx('plank', 'Plank', 'Core', 'sec', 'Base'),
  _cx('side-plank', 'Side Plank', 'Core', 'sec', 'Base'),
  _cx('hollow-hold', 'Hollow Hold', 'Core', 'sec', 'Intermedio'),
  _cx('lsit', 'L-sit', 'Core', 'sec', 'Avanzato'),
  _cx('leg-raise', 'Leg Raise', 'Core', 'reps', 'Base'),
  _cx('hanging-leg-raise', 'Hanging Leg Raise', 'Core', 'reps', 'Intermedio'),
  _cx('toes-to-bar', 'Toes to Bar', 'Core', 'reps', 'Avanzato'),
  _cx('crunch', 'Crunch', 'Core', 'reps', 'Base'),
  _cx('bicycle-crunch', 'Bicycle Crunch', 'Core', 'reps', 'Base'),
  _cx('russian-twist-bw', 'Russian Twist', 'Core', 'reps', 'Base'),
  _cx('mountain-climber', 'Mountain Climber', 'Core', 'reps', 'Base'),
  _cx('dragon-flag', 'Dragon Flag', 'Core', 'reps', 'Avanzato'),
  _cx('plank-static', 'Front Lever (progressione)', 'Core', 'sec', 'Avanzato'),
  // Skills
  _cx('handstand', 'Handstand', 'Skills', 'sec', 'Avanzato'),
  _cx('wall-handstand', 'Handstand al muro', 'Skills', 'sec', 'Intermedio'),
  _cx('crow-pose', 'Crow Pose', 'Skills', 'sec', 'Intermedio'),
  _cx('tuck-planche', 'Tuck Planche', 'Skills', 'sec', 'Avanzato'),
  _cx('planche', 'Full Planche', 'Skills', 'sec', 'Avanzato'),
  _cx('front-lever', 'Front Lever', 'Skills', 'sec', 'Avanzato'),
  _cx('back-lever', 'Back Lever', 'Skills', 'sec', 'Avanzato'),
  _cx('human-flag', 'Human Flag', 'Skills', 'sec', 'Avanzato'),
  _cx('elbow-lever', 'Elbow Lever', 'Skills', 'sec', 'Intermedio'),
  _cx('straddle-planche', 'Straddle Planche', 'Skills', 'sec', 'Avanzato'),
  _cx('v-sit', 'V-sit', 'Skills', 'sec', 'Avanzato'),
  _cx('handstand-walk', 'Handstand Walk', 'Skills', 'reps', 'Avanzato'),
  _cx('pseudo-planche-hold', 'Pseudo Planche Hold', 'Skills', 'sec', 'Intermedio'),
  _cx('tuck-front-lever', 'Tuck Front Lever', 'Skills', 'sec', 'Intermedio'),
  // Push (extra)
  _cx('hindu-pushup', 'Hindu Push-up', 'Push', 'reps', 'Base'),
  _cx('spiderman-pushup', 'Spiderman Push-up', 'Push', 'reps', 'Intermedio'),
  _cx('clap-pushup', 'Clap Push-up', 'Push', 'reps', 'Avanzato'),
  _cx('ring-dips', 'Ring Dips', 'Push', 'reps', 'Avanzato'),
  _cx('korean-dips', 'Korean Dips', 'Push', 'reps', 'Avanzato'),
  _cx('tricep-extension-bw', 'Bodyweight Tricep Ext.', 'Push', 'reps', 'Intermedio'),
  // Pull (extra)
  _cx('l-pullup', 'L Pull-up', 'Pull', 'reps', 'Avanzato'),
  _cx('ice-cream-maker', 'Ice Cream Maker', 'Pull', 'reps', 'Avanzato'),
  _cx('front-lever-raise', 'Front Lever Raise', 'Pull', 'reps', 'Avanzato'),
  _cx('inverted-row', 'Inverted Row', 'Pull', 'reps', 'Base'),
  _cx('dead-hang', 'Dead Hang', 'Pull', 'sec', 'Base'),
  _cx('high-pullup', 'High Pull-up', 'Pull', 'reps', 'Avanzato'),
  // Legs (extra)
  _cx('cossack-squat', 'Cossack Squat', 'Legs', 'reps', 'Intermedio'),
  _cx('sissy-squat', 'Sissy Squat', 'Legs', 'reps', 'Avanzato'),
  _cx('box-jump', 'Box Jump', 'Legs', 'reps', 'Intermedio'),
  _cx('single-leg-bridge', 'Single Leg Glute Bridge', 'Legs', 'reps', 'Intermedio'),
  _cx('natural-leg-ext', 'Natural Leg Extension', 'Legs', 'reps', 'Avanzato'),
  _cx('duck-walk', 'Duck Walk', 'Legs', 'sec', 'Intermedio'),
  // Core (extra)
  _cx('v-up', 'V-up', 'Core', 'reps', 'Intermedio'),
  _cx('flutter-kick', 'Flutter Kick', 'Core', 'sec', 'Base'),
  _cx('windshield-wiper', 'Windshield Wiper', 'Core', 'reps', 'Avanzato'),
  _cx('ab-rollout-bw', 'Ab Rollout', 'Core', 'reps', 'Avanzato'),
  _cx('plank-reach', 'Plank Reach', 'Core', 'reps', 'Intermedio'),
  _cx('hanging-windshield', 'Hanging Windshield Wiper', 'Core', 'reps', 'Avanzato'),
];

const List<String> calisthenicsCategories = ['Push', 'Pull', 'Legs', 'Core', 'Skills'];

/// Tutti gli esercizi delle due discipline.
final List<Exercise> allExercises = [...calisthenicsExercises, ...gymExercises];

final Map<String, Exercise> _byId = {for (final e in allExercises) e.id: e};

Exercise? getExercise(String id) => _byId[id];

List<Exercise> getLibrary(String discipline) =>
    discipline == 'gym' ? gymExercises : calisthenicsExercises;

List<String> getCategories(String discipline) =>
    discipline == 'gym' ? gymCategories : calisthenicsCategories;
