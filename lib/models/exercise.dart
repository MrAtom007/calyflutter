/// Un esercizio della libreria (calisthenics o palestra).
class Exercise {
  final String id;
  final String name;
  final String category;

  /// 'reps' | 'sec' | 'weight'
  final String unit;

  /// 'Base' | 'Intermedio' | 'Avanzato'
  final String level;

  /// 'calisthenics' | 'gym'
  final String discipline;

  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.level,
    required this.discipline,
  });
}
