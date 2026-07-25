// Libreria completa di esercizi da palestra (pesi).
// unit 'weight' => si registrano kg e reps (volume = kg * reps).
const e = (id, name, category, level = 'Base') => ({
  id,
  name,
  category,
  unit: 'weight',
  level,
  discipline: 'gym',
});

export const gymExercises = [
  // Petto (Chest)
  e('bench-press', 'Panca piana bilanciere', 'Petto', 'Intermedio'),
  e('incline-bench', 'Panca inclinata', 'Petto', 'Intermedio'),
  e('decline-bench', 'Panca declinata', 'Petto', 'Intermedio'),
  e('db-press', 'Distensioni manubri', 'Petto', 'Base'),
  e('chest-fly', 'Croci ai cavi', 'Petto', 'Base'),
  e('pec-deck', 'Pectoral machine', 'Petto', 'Base'),

  // Schiena (Back)
  e('deadlift', 'Stacco da terra', 'Schiena', 'Avanzato'),
  e('barbell-row', 'Rematore bilanciere', 'Schiena', 'Intermedio'),
  e('lat-pulldown', 'Lat machine', 'Schiena', 'Base'),
  e('seated-row', 'Pulley basso', 'Schiena', 'Base'),
  e('t-bar-row', 'T-bar row', 'Schiena', 'Intermedio'),
  e('db-row', 'Rematore manubrio', 'Schiena', 'Base'),

  // Gambe (Legs)
  e('back-squat', 'Squat bilanciere', 'Gambe', 'Intermedio'),
  e('front-squat', 'Front squat', 'Gambe', 'Avanzato'),
  e('leg-press', 'Leg press', 'Gambe', 'Base'),
  e('romanian-deadlift', 'Stacco rumeno', 'Gambe', 'Intermedio'),
  e('leg-extension', 'Leg extension', 'Gambe', 'Base'),
  e('leg-curl', 'Leg curl', 'Gambe', 'Base'),
  e('calf-press', 'Calf press', 'Gambe', 'Base'),
  e('hip-thrust', 'Hip thrust', 'Gambe', 'Intermedio'),

  // Spalle (Shoulders)
  e('ohp', 'Military press', 'Spalle', 'Intermedio'),
  e('db-shoulder-press', 'Distensioni manubri spalle', 'Spalle', 'Base'),
  e('lateral-raise', 'Alzate laterali', 'Spalle', 'Base'),
  e('front-raise', 'Alzate frontali', 'Spalle', 'Base'),
  e('rear-delt-fly', 'Alzate posteriori', 'Spalle', 'Base'),
  e('upright-row', 'Tirate al mento', 'Spalle', 'Intermedio'),

  // Braccia (Arms)
  e('barbell-curl', 'Curl bilanciere', 'Braccia', 'Base'),
  e('db-curl', 'Curl manubri', 'Braccia', 'Base'),
  e('hammer-curl', 'Hammer curl', 'Braccia', 'Base'),
  e('preacher-curl', 'Panca Scott', 'Braccia', 'Intermedio'),
  e('triceps-pushdown', 'Pushdown ai cavi', 'Braccia', 'Base'),
  e('skull-crusher', 'French press', 'Braccia', 'Intermedio'),
  e('close-grip-bench', 'Panca presa stretta', 'Braccia', 'Intermedio'),

  // Core
  e('cable-crunch', 'Crunch ai cavi', 'Core', 'Base'),
  e('weighted-plank', 'Plank zavorrato', 'Core', 'Intermedio'),
  e('russian-twist', 'Russian twist', 'Core', 'Base'),
  e('ab-wheel', 'Ab wheel rollout', 'Core', 'Avanzato'),
  e('hanging-knee-raise', 'Hanging knee raise', 'Core', 'Intermedio'),
  e('pallof-press', 'Pallof press', 'Core', 'Intermedio'),
  e('back-extension', 'Iperestensioni', 'Core', 'Base'),

  // Petto (extra)
  e('cable-crossover', 'Cable crossover', 'Petto', 'Base'),
  e('incline-db-press', 'Distensioni inclinate manubri', 'Petto', 'Intermedio'),
  e('machine-press', 'Chest press machine', 'Petto', 'Base'),
  e('svend-press', 'Svend press', 'Petto', 'Base'),

  // Schiena (extra)
  e('pull-up-weighted', 'Trazioni zavorrate', 'Schiena', 'Avanzato'),
  e('pendlay-row', 'Pendlay row', 'Schiena', 'Intermedio'),
  e('straight-arm-pulldown', 'Pulldown braccia tese', 'Schiena', 'Base'),
  e('face-pull', 'Face pull', 'Schiena', 'Base'),
  e('shrug', 'Scrollate (trapezi)', 'Schiena', 'Base'),

  // Gambe (extra)
  e('hack-squat', 'Hack squat', 'Gambe', 'Intermedio'),
  e('bulgarian-db', 'Bulgarian split squat manubri', 'Gambe', 'Intermedio'),
  e('walking-lunge', 'Affondi camminata', 'Gambe', 'Base'),
  e('goblet-squat', 'Goblet squat', 'Gambe', 'Base'),
  e('seated-calf', 'Calf da seduto', 'Gambe', 'Base'),
  e('good-morning', 'Good morning', 'Gambe', 'Intermedio'),
  e('adductor-machine', 'Adductor machine', 'Gambe', 'Base'),

  // Spalle (extra)
  e('arnold-press', 'Arnold press', 'Spalle', 'Intermedio'),
  e('cable-lateral', 'Alzate laterali ai cavi', 'Spalle', 'Base'),
  e('machine-shoulder-press', 'Shoulder press machine', 'Spalle', 'Base'),

  // Braccia (extra)
  e('concentration-curl', 'Curl di concentrazione', 'Braccia', 'Base'),
  e('cable-curl', 'Curl ai cavi', 'Braccia', 'Base'),
  e('overhead-triceps', 'Estensioni sopra la testa', 'Braccia', 'Base'),
  e('dips-weighted', 'Dips zavorrate', 'Braccia', 'Avanzato'),
  e('reverse-curl', 'Reverse curl', 'Braccia', 'Base'),
  e('wrist-curl', 'Wrist curl (avambracci)', 'Braccia', 'Base'),
];

export const gymCategories = ['Petto', 'Schiena', 'Gambe', 'Spalle', 'Braccia', 'Core'];
