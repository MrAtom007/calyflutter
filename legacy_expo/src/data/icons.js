// Mappa categoria -> icona MaterialCommunityIcons (look realistico).
export const categoryIcons = {
  // Calisthenics
  Push: 'arm-flex',
  Pull: 'weight-lifter',
  Legs: 'run-fast',
  Core: 'ab-testing',
  Skills: 'gymnastics',
  // Palestra
  Petto: 'arm-flex',
  Schiena: 'weight-lifter',
  Gambe: 'run-fast',
  Spalle: 'dumbbell',
  Braccia: 'arm-flex-outline',
};

export function categoryIcon(cat) {
  return categoryIcons[cat] || 'dumbbell';
}
