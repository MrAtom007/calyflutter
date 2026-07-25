import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/theme_provider.dart';
import '../state/workout_provider.dart';
import '../state/locale_provider.dart';
import '../services/feedback_service.dart';
import '../data/exercises.dart';
import '../data/media.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/charts.dart';
import 'webview_screen.dart';
import 'timer_screen.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final String exerciseId;
  const ExerciseDetailScreen({super.key, required this.exerciseId});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  final _reps = TextEditingController();
  final _sec = TextEditingController();
  final _weight = TextEditingController();

  @override
  void dispose() {
    _reps.dispose();
    _sec.dispose();
    _weight.dispose();
    super.dispose();
  }

  /// Storico (data, valore) di questo esercizio.
  List<MapEntry<DateTime, double>> _history(List<Workout> all, Exercise ex) {
    final out = <MapEntry<DateTime, double>>[];
    for (final w in all) {
      for (final s in w.sets) {
        if (s.exerciseId != ex.id) continue;
        double v;
        if (ex.unit == 'weight') {
          v = (s.weight ?? 0) * (s.reps ?? 0);
        } else if (ex.unit == 'sec') {
          v = (s.sec ?? 0).toDouble();
        } else {
          v = (s.reps ?? 0).toDouble();
        }
        out.add(MapEntry(w.date, v));
      }
    }
    out.sort((a, b) => a.key.compareTo(b.key));
    return out;
  }

  void _quickLog(Exercise ex) {
    final set = WorkoutSet(
      exerciseId: ex.id,
      reps: int.tryParse(_reps.text),
      sec: int.tryParse(_sec.text),
      weight: double.tryParse(_weight.text.replaceAll(',', '.')),
    );
    if (set.reps == null && set.sec == null && set.weight == null) return;
    final w = Workout(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      discipline: ex.discipline,
      single: true,
      sets: [set],
    );
    context.read<WorkoutProvider>().save(w);
    FeedbackService.onSuccess();
    _reps.clear();
    _sec.clear();
    _weight.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    final ex = getExercise(widget.exerciseId);
    if (ex == null) {
      return Scaffold(body: Center(child: Text(t('exercise_not_found'))));
    }
    final all = context.watch<WorkoutProvider>().all;
    final history = _history(all, ex);
    final count = history.length;
    final record = history.isEmpty
        ? 0.0
        : history.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final series = history.map((e) => e.value).toList();
    final last10 = series.length > 10
        ? series.sublist(series.length - 10)
        : series;

    return Scaffold(
      appBar: AppBar(title: Text(ex.name)),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          Text('${ex.category} · ${ex.level}',
              style: TextStyle(color: c.textMuted)),
          const SizedBox(height: Spacing.md),
          // Media banner
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WebViewScreen(
                    url: demoSearchUrl(ex), title: 'Tutorial: ${ex.name}'),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Radii.md),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CachedNetworkImage(
                    imageUrl: imageFor(ex),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                        height: 180, color: c.cardAlt),
                    errorWidget: (_, __, ___) => Container(
                      height: 180,
                      color: c.cardAlt,
                      child: Icon(Icons.image_not_supported,
                          color: c.textMuted),
                    ),
                  ),
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.play_arrow, color: Colors.white, size: 34),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(
                  child: _stat(c, '$count', t('times'))),
              const SizedBox(width: Spacing.sm),
              Expanded(
                  child:
                      _stat(c, _recordLabel(ex, record), t('personal_record'))),
            ],
          ),
          if (ex.unit == 'sec')
            Padding(
              padding: const EdgeInsets.only(top: Spacing.sm),
              child: TextButton.icon(
                icon: const Icon(Icons.timer_outlined),
                label: Text(t('open_timer_hold')),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => TimerScreen(exerciseName: ex.name)),
                ),
              ),
            ),
          const SizedBox(height: Spacing.md),
          if (last10.length >= 2) ...[
            Text(t('trend'),
                style: TextStyle(
                    color: c.textMuted, fontWeight: FontWeight.w700)),
            const SizedBox(height: Spacing.sm),
            SimpleLineChart(
                values: last10, color: c.primary, refLine: record),
            const SizedBox(height: Spacing.md),
          ],
          // Quick log
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(Radii.md),
              border: Border.all(color: c.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t('record_now'),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: Spacing.sm),
                Row(
                  children: [
                    if (ex.unit == 'weight') ...[
                      Expanded(child: _field(_weight, 'kg', decimal: true)),
                      const SizedBox(width: 8),
                      Expanded(child: _field(_reps, 'reps')),
                    ] else if (ex.unit == 'sec')
                      Expanded(child: _field(_sec, 'sec'))
                    else
                      Expanded(child: _field(_reps, 'reps')),
                    const SizedBox(width: 8),
                    FilledButton(
                      style:
                          FilledButton.styleFrom(backgroundColor: c.primary),
                      onPressed: () => _quickLog(ex),
                      child: Text(t('save')),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Text(t('history'),
              style:
                  TextStyle(color: c.textMuted, fontWeight: FontWeight.w700)),
          const SizedBox(height: Spacing.sm),
          if (history.isEmpty)
            Text(t('no_history'), style: TextStyle(color: c.textMuted))
          else
            ...history.reversed.map((e) => ListTile(
                  dense: true,
                  title: Text(formatDate(e.key)),
                  trailing: Text(_recordLabel(ex, e.value),
                      style: TextStyle(color: c.primary)),
                )),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _recordLabel(Exercise ex, double v) {
    if (ex.unit == 'weight') return fmtNum(v);
    if (ex.unit == 'sec') return '${v.toInt()}s';
    return '${v.toInt()}';
  }

  Widget _stat(AppColors c, String value, String label) => Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: c.cardAlt,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: c.border),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: c.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
            Text(label,
                style: TextStyle(color: c.textMuted, fontSize: 11)),
          ],
        ),
      );

  Widget _field(TextEditingController ctrl, String hint,
          {bool decimal = false}) =>
      TextField(
        controller: ctrl,
        keyboardType: TextInputType.numberWithOptions(decimal: decimal),
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
      );
}
