import 'package:flutter/material.dart';

/// Mappa categoria -> icona Material (equivalente alle MCI dell'app originale).
const Map<String, IconData> categoryIcons = {
  // Calisthenics
  'Push': Icons.fitness_center,
  'Pull': Icons.sports_gymnastics,
  'Legs': Icons.directions_run,
  'Core': Icons.self_improvement,
  'Skills': Icons.accessibility_new,
  // Palestra
  'Petto': Icons.fitness_center,
  'Schiena': Icons.sports_gymnastics,
  'Gambe': Icons.directions_run,
  'Spalle': Icons.sports_handball,
  'Braccia': Icons.sports_mma,
};

IconData categoryIcon(String cat) => categoryIcons[cat] ?? Icons.fitness_center;
