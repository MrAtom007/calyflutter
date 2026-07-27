import 'package:intl/intl.dart';
import '../data/exercises.dart';
import '../models/workout.dart';

/// Locale corrente per la formattazione (aggiornato da LocaleProvider).
String appLocale = 'it';

String exerciseName(String id) => getExercise(id)?.name ?? id;

String formatDate(DateTime d) => DateFormat('dd MMM yyyy', appLocale).format(d);
String formatDateTime(DateTime d) =>
    DateFormat('dd MMM yyyy • HH:mm', appLocale).format(d);

/// Formatta un numero rimuovendo lo zero decimale inutile.
String fmtNum(num n) {
  if (n == n.roundToDouble()) return n.toInt().toString();
  return n.toString();
}

/// Formattazione compatta (es. 600M, 12.3K) per evitare overflow nelle card.
String fmtCompact(num n) {
  if (n.abs() < 1000) return n.round().toString();
  return NumberFormat.compact(locale: appLocale).format(n);
}

/// Riepilogo di un singolo set in base al tipo di esercizio.
String setSummary(WorkoutSet s) {
  final ex = getExercise(s.exerciseId);
  final name = ex?.name ?? s.exerciseId;
  if (s.weight != null) {
    return '$name ${fmtNum(s.weight!)}kg×${s.reps ?? 0}';
  }
  if (s.sec != null) {
    return '$name ${s.sec}s';
  }
  return '$name ×${s.reps ?? 0}';
}

/// Valore leggibile di un set (senza nome).
String setValue(WorkoutSet s) {
  if (s.weight != null) return '${fmtNum(s.weight!)} kg × ${s.reps ?? 0}';
  if (s.sec != null) return '${s.sec} sec';
  return '${s.reps ?? 0} reps';
}

/// Breve riepilogo di un allenamento (primi 2 set).
String workoutSummary(Workout w) {
  final n = w.sets.length;
  final firstTwo = w.sets.take(2).map(setSummary).join(', ');
  return '$n set • $firstTwo';
}
