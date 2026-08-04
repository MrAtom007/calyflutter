import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../state/theme_provider.dart';
import '../state/discipline_provider.dart';
import '../state/workout_provider.dart';
import '../state/locale_provider.dart';
import '../data/exercises.dart';
import '../models/workout.dart';
import '../services/export_service.dart';
import '../theme/app_theme.dart';
import '../widgets/discipline_switch.dart';
import '../widgets/charts.dart';
import '../widgets/design_system.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    final discipline = context.watch<DisciplineProvider>().discipline;
    final workouts =
        context.watch<WorkoutProvider>().forDiscipline(discipline);
    final isGym = discipline == 'gym';

    // Statistiche principali
    double totVolume = 0;
    int totReps = 0;
    int totSec = 0;
    for (final w in workouts) {
      for (final s in w.sets) {
        totVolume += (s.weight ?? 0) * (s.reps ?? 0);
        totReps += s.reps ?? 0;
        totSec += s.sec ?? 0;
      }
    }

    // Ultimi 7 giorni
    final now = DateTime.now();
    final days = List.generate(7, (i) => DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: 6 - i)));
    final dayFmt = DateFormat('E', 'it_IT');
    final dayCounts = days.map((d) {
      return workouts
          .where((w) =>
              w.date.year == d.year &&
              w.date.month == d.month &&
              w.date.day == d.day)
          .length
          .toDouble();
    }).toList();

    // Top esercizi per volume
    final volById = <String, double>{};
    for (final w in workouts) {
      for (final s in w.sets) {
        final v = isGym ? (s.weight ?? 0) * (s.reps ?? 0) : (s.reps ?? 0).toDouble();
        volById[s.exerciseId] = (volById[s.exerciseId] ?? 0) + v;
      }
    }
    final topEx = volById.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = topEx.take(6).toList();
    final maxVol = top.isEmpty ? 1.0 : top.first.value;

    // Serie andamento (per allenamento, ordinata)
    final ordered = [...workouts]..sort((a, b) => a.date.compareTo(b.date));
    final series = ordered.map((w) {
      double v = 0;
      for (final s in w.sets) {
        v += isGym ? (s.weight ?? 0) * (s.reps ?? 0) : (s.reps ?? 0) + (s.sec ?? 0);
      }
      return v;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(t('nav_progress'))),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          const DisciplineSwitch(),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              Expanded(
                child: _stat(
                    c,
                    isGym ? '${totVolume.toInt()}' : '$totReps',
                    isGym ? t('volume_kg') : t('total_reps')),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: _stat(
                    c,
                    isGym ? '${workouts.length}' : "${(totSec / 60).round()}'",
                    isGym ? t('sessions') : t('static_holds')),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          _sectionTitle(c, t('last_7_days')),
          const SizedBox(height: Spacing.sm),
          SimpleBarChart(
            labels: days.map((d) => dayFmt.format(d)).toList(),
            values: dayCounts,
            color: c.primary,
          ),
          const SizedBox(height: Spacing.lg),
          if (series.length >= 2) ...[
            _sectionTitle(c, isGym ? t('load_trend') : t('volume_trend')),
            const SizedBox(height: Spacing.sm),
            SimpleLineChart(values: series, color: c.primary),
            const SizedBox(height: Spacing.lg),
          ],
          if (top.isNotEmpty) ...[
            _sectionTitle(c, t('top_exercises')),
            const SizedBox(height: Spacing.sm),
            ResponsiveWrap(
              minTileWidth: 300,
              maxColumns: 2,
              runSpacing: 8,
              children: top
                  .map((e) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                  child: Text(getExercise(e.key)?.name ?? e.key,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis)),
                              Text('${e.value.toInt()}',
                                  style: TextStyle(color: c.textMuted)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: e.value / maxVol,
                              minHeight: 8,
                              backgroundColor: c.cardAlt,
                              valueColor: AlwaysStoppedAnimation(c.primary),
                            ),
                          ),
                        ],
                      ))
                  .toList(),
            ),
            const SizedBox(height: Spacing.lg),
          ],
          _sectionTitle(c, t('export_data')),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.table_chart_outlined),
                  label: const Text('CSV'),
                  onPressed: () => _export(context, workouts, 'csv'),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.code),
                  label: const Text('JSON'),
                  onPressed: () => _export(context, workouts, 'json'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _export(BuildContext context, List<Workout> w, String fmt) async {
    if (w.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nessun dato da esportare')),
      );
      return;
    }
    await ExportService.export(w, fmt);
  }

  Widget _sectionTitle(AppColors c, String t) => Text(t,
      style: TextStyle(color: c.textMuted, fontWeight: FontWeight.w700));

  Widget _stat(AppColors c, String value, String label) => Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: c.border),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: c.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800)),
            Text(label, style: TextStyle(color: c.textMuted, fontSize: 12)),
          ],
        ),
      );
}
