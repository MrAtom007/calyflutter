// Scala di ranghi: dal materiale piu' comune (legno) al piu' prezioso
// dell'universo (antimateria). Vale sia per calisthenics che per palestra.
// glow = colore alone/riflesso; color2 = secondo stop del gradiente; mci = icona vettoriale.
export const ranks = [
  { id: 'wood', name: 'Legno', icon: '🪵', mci: 'pine-tree', color: '#9c6b3f', color2: '#6d4a2b', glow: '#c98a52', min: 0 },
  { id: 'stone', name: 'Pietra', icon: '🪨', mci: 'terrain', color: '#9aa0a6', color2: '#6b7075', glow: '#b8bec4', min: 300 },
  { id: 'bronze', name: 'Bronzo', icon: '🥉', mci: 'medal-outline', color: '#cd7f32', color2: '#8a5320', glow: '#e6a15a', min: 900 },
  { id: 'iron', name: 'Ferro', icon: '⚙️', mci: 'anvil', color: '#c2c8cf', color2: '#7d858e', glow: '#dfe4e9', min: 2000 },
  { id: 'silver', name: 'Argento', icon: '🥈', mci: 'medal', color: '#d8d8d8', color2: '#9a9a9a', glow: '#ffffff', min: 4000 },
  { id: 'gold', name: 'Oro', icon: '🥇', mci: 'trophy-variant', color: '#ffd700', color2: '#c79a00', glow: '#fff2a8', min: 7500 },
  { id: 'platinum', name: 'Platino', icon: '💠', mci: 'shield-star', color: '#e9edf0', color2: '#a9b4bd', glow: '#ffffff', min: 13000 },
  { id: 'diamond', name: 'Diamante', icon: '💎', mci: 'diamond-stone', color: '#7fe3f2', color2: '#2aa7c4', glow: '#c8f6ff', min: 22000 },
  { id: 'painite', name: 'Painite', icon: '🟥', mci: 'diamond', color: '#d24437', color2: '#7c1f18', glow: '#ff7a6b', min: 38000 },
  { id: 'antimatter', name: 'Antimateria', icon: '⚛️', mci: 'atom', color: '#c77bff', color2: '#6d28d9', glow: '#e9b6ff', min: 60000 },
];

export const maxLevel = ranks.length;

// Livello 1..N in base all'id del rango.
export function levelOf(rankId) {
  return ranks.findIndex((r) => r.id === rankId) + 1;
}

// Punteggio di un allenamento.
// Calisthenics: 1 pt/rep, 0.5 pt/sec di hold.
// Palestra: volume (kg * reps) / 10 pt.
export function workoutPoints(workout) {
  let pts = 0;
  for (const s of workout.sets) {
    if (workout.discipline === 'gym') {
      pts += ((s.weight || 0) * (s.reps || 0)) / 10;
    } else {
      pts += (s.reps || 0) * 1 + (s.sec || 0) * 0.5;
    }
  }
  return pts;
}

export function totalPoints(workouts) {
  return Math.round(workouts.reduce((acc, w) => acc + workoutPoints(w), 0));
}

// Rango attuale + prossimo + progresso (0..1) verso il prossimo.
export function rankFor(points) {
  let current = ranks[0];
  let next = null;
  for (let i = 0; i < ranks.length; i++) {
    if (points >= ranks[i].min) {
      current = ranks[i];
      next = ranks[i + 1] || null;
    }
  }
  const progress = next
    ? Math.min(1, (points - current.min) / (next.min - current.min))
    : 1;
  return { current, next, progress };
}
