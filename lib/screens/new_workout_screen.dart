import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/theme_provider.dart';
import '../state/discipline_provider.dart';
import '../state/workout_provider.dart';
import '../state/locale_provider.dart';
import '../services/feedback_service.dart';
import '../data/exercises.dart';
import '../data/routines.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../theme/app_theme.dart';
import '../modules/weighted/weighted_widgets.dart';

class _EditSet {
  final Exercise exercise;
  final reps = TextEditingController();
  final sec = TextEditingController();
  final weight = TextEditingController();
  _EditSet(this.exercise, {int? presetReps, int? presetSec, double? presetWeight}) {
    if (presetReps != null) reps.text = '$presetReps';
    if (presetSec != null) sec.text = '$presetSec';
    if (presetWeight != null) weight.text = presetWeight.toString();
  }
}

class NewWorkoutScreen extends StatefulWidget {
  final List<RoutineSet>? preset;
  const NewWorkoutScreen({super.key, this.preset});

  @override
  State<NewWorkoutScreen> createState() => _NewWorkoutScreenState();
}

class _NewWorkoutScreenState extends State<NewWorkoutScreen> {
  late String _category;
  final List<_EditSet> _sets = [];

  @override
  void initState() {
    super.initState();
    final discipline = context.read<DisciplineProvider>().discipline;
    _category = getCategories(discipline).first;
    if (widget.preset != null) {
      for (final p in widget.preset!) {
        final ex = getExercise(p.exerciseId);
        if (ex != null) {
          _sets.add(_EditSet(ex,
              presetReps: p.reps, presetSec: p.sec, presetWeight: p.weight));
        }
      }
    }
  }

  void _addSet(Exercise ex) {
    FeedbackService.onTap();
    setState(() => _sets.add(_EditSet(ex)));
  }

  void _save() {
    final t = context.read<LocaleProvider>().t;
    if (_sets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('add_one_set'))),
      );
      return;
    }
    final discipline = context.read<DisciplineProvider>().discipline;
    final sets = _sets.map((s) {
      return WorkoutSet(
        exerciseId: s.exercise.id,
        reps: int.tryParse(s.reps.text),
        sec: int.tryParse(s.sec.text),
        weight: double.tryParse(s.weight.text.replaceAll(',', '.')),
      );
    }).toList();
    final workout = Workout(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      discipline: discipline,
      sets: sets,
    );
    context.read<WorkoutProvider>().save(workout);
    FeedbackService.onSuccess();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    final discipline = context.watch<DisciplineProvider>().discipline;
    final categories = getCategories(discipline);
    final library =
        getLibrary(discipline).where((e) => e.category == _category).toList();

    return Scaffold(
      appBar: AppBar(title: Text(t('new_workout'))),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(Spacing.md),
              children: [
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: categories.map((cat) {
                      final sel = cat == _category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: sel,
                          onSelected: (_) => setState(() => _category = cat),
                          selectedColor: c.primary,
                          labelStyle: TextStyle(
                              color: sel
                                  ? (context.read<ThemeProvider>().skin.isDark
                                      ? Colors.black
                                      : Colors.white)
                                  : c.text),
                          backgroundColor: c.cardAlt,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: Spacing.md),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: library.map((ex) {
                    return GestureDetector(
                      onTap: () => _addSet(ex),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: c.card,
                          borderRadius: BorderRadius.circular(Radii.md),
                          border: Border.all(color: c.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(ex.name,
                                style:
                                    const TextStyle(fontWeight: FontWeight.w600)),
                            Text(ex.level,
                                style: TextStyle(
                                    color: c.textMuted, fontSize: 11)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: Spacing.lg),
                if (_sets.isNotEmpty)
                  Text(t('added_sets'),
                      style: TextStyle(
                          color: c.textMuted, fontWeight: FontWeight.w700)),
                const SizedBox(height: Spacing.sm),
                ..._sets.asMap().entries.map((e) => _buildSetRow(e.key, e.value, c)),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: c.primary),
                  onPressed: _save,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(t('save_workout')),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(int i, _EditSet s, AppColors c) {
    final unit = s.exercise.unit;
    final t2 = context.read<LocaleProvider>().t;
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(s.exercise.name,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          if (unit == 'weight') ...[
            Expanded(child: _numField(s.weight, 'kg', decimal: true)),
            const SizedBox(width: 6),
            Expanded(child: _numField(s.reps, 'reps')),
            IconButton(
              tooltip: t2('show_plates'),
              icon: Icon(Icons.fitness_center_rounded,
                  color: c.primary, size: 20),
              onPressed: () {
                FeedbackService.onTap();
                final w = double.tryParse(
                        s.weight.text.replaceAll(',', '.')) ??
                    0;
                showPlateSheet(context, addedWeight: w);
              },
            ),
          ] else if (unit == 'sec')
            Expanded(child: _numField(s.sec, 'sec'))
          else
            Expanded(child: _numField(s.reps, 'reps')),
          IconButton(
            icon: Icon(Icons.close, color: c.danger, size: 20),
            onPressed: () => setState(() => _sets.removeAt(i)),
          ),
        ],
      ),
    );
  }

  Widget _numField(TextEditingController ctrl, String hint,
      {bool decimal = false}) {
    return TextField(
      controller: ctrl,
      keyboardType:
          TextInputType.numberWithOptions(decimal: decimal),
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
