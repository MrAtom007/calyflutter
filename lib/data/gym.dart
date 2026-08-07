import '../models/exercise.dart';

Exercise _e(String id, String name, String category, [String level = 'Base']) =>
    Exercise(
      id: id,
      name: name,
      category: category,
      unit: 'weight',
      level: level,
      discipline: 'gym',
    );

/// Libreria completa di esercizi da palestra (unit 'weight' => kg x reps).
final List<Exercise> gymExercises = [
  // Petto
  _e('bench-press', 'Panca piana bilanciere', 'Petto', 'Intermedio'),
  _e('incline-bench', 'Panca inclinata', 'Petto', 'Intermedio'),
  _e('decline-bench', 'Panca declinata', 'Petto', 'Intermedio'),
  _e('db-press', 'Distensioni manubri', 'Petto', 'Base'),
  _e('chest-fly', 'Croci ai cavi', 'Petto', 'Base'),
  _e('pec-deck', 'Pectoral machine', 'Petto', 'Base'),
  // Schiena
  _e('deadlift', 'Stacco da terra', 'Schiena', 'Avanzato'),
  _e('barbell-row', 'Rematore bilanciere', 'Schiena', 'Intermedio'),
  _e('lat-pulldown', 'Lat machine', 'Schiena', 'Base'),
  _e('seated-row', 'Pulley basso', 'Schiena', 'Base'),
  _e('t-bar-row', 'T-bar row', 'Schiena', 'Intermedio'),
  _e('db-row', 'Rematore manubrio', 'Schiena', 'Base'),
  // Gambe
  _e('back-squat', 'Squat bilanciere', 'Gambe', 'Intermedio'),
  _e('front-squat', 'Front squat', 'Gambe', 'Avanzato'),
  _e('leg-press', 'Leg press', 'Gambe', 'Base'),
  _e('romanian-deadlift', 'Stacco rumeno', 'Gambe', 'Intermedio'),
  _e('leg-extension', 'Leg extension', 'Gambe', 'Base'),
  _e('leg-curl', 'Leg curl', 'Gambe', 'Base'),
  _e('calf-press', 'Calf press', 'Gambe', 'Base'),
  _e('hip-thrust', 'Hip thrust', 'Gambe', 'Intermedio'),
  // Spalle
  _e('ohp', 'Military press', 'Spalle', 'Intermedio'),
  _e('db-shoulder-press', 'Distensioni manubri spalle', 'Spalle', 'Base'),
  _e('lateral-raise', 'Alzate laterali', 'Spalle', 'Base'),
  _e('front-raise', 'Alzate frontali', 'Spalle', 'Base'),
  _e('rear-delt-fly', 'Alzate posteriori', 'Spalle', 'Base'),
  _e('upright-row', 'Tirate al mento', 'Spalle', 'Intermedio'),
  // Braccia
  _e('barbell-curl', 'Curl bilanciere', 'Braccia', 'Base'),
  _e('db-curl', 'Curl manubri', 'Braccia', 'Base'),
  _e('hammer-curl', 'Hammer curl', 'Braccia', 'Base'),
  _e('preacher-curl', 'Panca Scott', 'Braccia', 'Intermedio'),
  _e('triceps-pushdown', 'Pushdown ai cavi', 'Braccia', 'Base'),
  _e('skull-crusher', 'French press', 'Braccia', 'Intermedio'),
  _e('close-grip-bench', 'Panca presa stretta', 'Braccia', 'Intermedio'),
  // Core
  _e('cable-crunch', 'Crunch ai cavi', 'Core', 'Base'),
  _e('weighted-plank', 'Plank zavorrato', 'Core', 'Intermedio'),
  _e('russian-twist', 'Russian twist', 'Core', 'Base'),
  _e('ab-wheel', 'Ab wheel rollout', 'Core', 'Avanzato'),
  _e('hanging-knee-raise', 'Hanging knee raise', 'Core', 'Intermedio'),
  _e('pallof-press', 'Pallof press', 'Core', 'Intermedio'),
  _e('back-extension', 'Iperestensioni', 'Core', 'Base'),
  // Petto (extra)
  _e('cable-crossover', 'Cable crossover', 'Petto', 'Base'),
  _e(
    'incline-db-press',
    'Distensioni inclinate manubri',
    'Petto',
    'Intermedio',
  ),
  _e('machine-press', 'Chest press machine', 'Petto', 'Base'),
  _e('svend-press', 'Svend press', 'Petto', 'Base'),
  // Schiena (extra)
  _e('pull-up-weighted', 'Trazioni zavorrate', 'Schiena', 'Avanzato'),
  _e('pendlay-row', 'Pendlay row', 'Schiena', 'Intermedio'),
  _e('straight-arm-pulldown', 'Pulldown braccia tese', 'Schiena', 'Base'),
  _e('face-pull', 'Face pull', 'Schiena', 'Base'),
  _e('shrug', 'Scrollate (trapezi)', 'Schiena', 'Base'),
  // Gambe (extra)
  _e('hack-squat', 'Hack squat', 'Gambe', 'Intermedio'),
  _e('bulgarian-db', 'Bulgarian split squat manubri', 'Gambe', 'Intermedio'),
  _e('walking-lunge', 'Affondi camminata', 'Gambe', 'Base'),
  _e('goblet-squat', 'Goblet squat', 'Gambe', 'Base'),
  _e('seated-calf', 'Calf da seduto', 'Gambe', 'Base'),
  _e('good-morning', 'Good morning', 'Gambe', 'Intermedio'),
  _e('adductor-machine', 'Adductor machine', 'Gambe', 'Base'),
  // Spalle (extra)
  _e('arnold-press', 'Arnold press', 'Spalle', 'Intermedio'),
  _e('cable-lateral', 'Alzate laterali ai cavi', 'Spalle', 'Base'),
  _e('machine-shoulder-press', 'Shoulder press machine', 'Spalle', 'Base'),
  // Braccia (extra)
  _e('concentration-curl', 'Curl di concentrazione', 'Braccia', 'Base'),
  _e('cable-curl', 'Curl ai cavi', 'Braccia', 'Base'),
  _e('overhead-triceps', 'Estensioni sopra la testa', 'Braccia', 'Base'),
  _e('dips-weighted', 'Dips zavorrate', 'Braccia', 'Avanzato'),
  _e('reverse-curl', 'Reverse curl', 'Braccia', 'Base'),
  _e('wrist-curl', 'Wrist curl (avambracci)', 'Braccia', 'Base'),
];

const List<String> gymCategories = [
  'Petto',
  'Schiena',
  'Gambe',
  'Spalle',
  'Braccia',
  'Core',
];
