import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../data/exercises.dart';
import '../models/workout.dart';

class ExportService {
  static final _fmt = DateFormat('yyyy-MM-dd HH:mm');
  static String _stamp() => DateFormat('yyyyMMdd-HHmm').format(DateTime.now());

  static String _csvEscape(String s) =>
      RegExp(r'[",\n]').hasMatch(s) ? '"${s.replaceAll('"', '""')}"' : s;

  static String toCsv(List<Workout> workouts) {
    const headers = [
      'data', 'disciplina', 'esercizio', 'categoria', 'reps', 'secondi', 'peso_kg'
    ];
    final lines = [headers.join(',')];
    for (final w in workouts) {
      for (final s in w.sets) {
        final ex = getExercise(s.exerciseId);
        final row = [
          _fmt.format(w.date),
          w.discipline,
          ex?.name ?? s.exerciseId,
          ex?.category ?? '',
          s.reps?.toString() ?? '',
          s.sec?.toString() ?? '',
          s.weight?.toString() ?? '',
        ];
        lines.add(row.map(_csvEscape).join(','));
      }
    }
    return lines.join('\n');
  }

  static String toJson(List<Workout> workouts) => const JsonEncoder.withIndent('  ')
      .convert({
    'app': 'CaliStrack',
    'exportedAt': DateTime.now().toIso8601String(),
    'count': workouts.length,
    'workouts': workouts.map((w) => w.toJson()).toList(),
  });

  /// Esporta in CSV o JSON e apre il foglio di condivisione.
  static Future<bool> export(List<Workout> workouts, String format) async {
    if (workouts.isEmpty) return false;
    final dir = await getTemporaryDirectory();
    final isJson = format == 'json';
    final filename = 'calistrack-${_stamp()}.${isJson ? 'json' : 'csv'}';
    final file = File('${dir.path}/$filename');
    await file.writeAsString(isJson ? toJson(workouts) : toCsv(workouts));
    await Share.shareXFiles([XFile(file.path)],
        subject: 'Esporta allenamenti CaliStrack');
    return true;
  }
}
