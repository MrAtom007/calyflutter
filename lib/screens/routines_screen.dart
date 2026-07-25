import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/theme_provider.dart';
import '../state/discipline_provider.dart';
import '../state/locale_provider.dart';
import '../services/feedback_service.dart';
import '../data/routines.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/discipline_switch.dart';
import 'new_workout_screen.dart';

class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    final discipline = context.watch<DisciplineProvider>().discipline;
    final routines = getRoutines(discipline);

    return Scaffold(
      appBar: AppBar(title: Text(t('nav_routines'))),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          const DisciplineSwitch(),
          const SizedBox(height: Spacing.sm),
          ...routines.map((r) => Container(
                margin: const EdgeInsets.only(bottom: Spacing.md),
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(Radii.lg),
                  border: Border.all(color: c.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(r.name,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w800)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: c.cardAlt,
                            borderRadius: BorderRadius.circular(Radii.sm),
                          ),
                          child: Text(r.level,
                              style: TextStyle(
                                  color: c.primary, fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(r.description,
                        style: TextStyle(color: c.textMuted)),
                    const SizedBox(height: 6),
                    Text('${r.duration} • ${t.p('exercises_count', {'n': '${r.sets.length}'})}',
                        style: TextStyle(color: c.textMuted, fontSize: 12)),
                    const SizedBox(height: Spacing.sm),
                    ...r.sets.map((s) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Icon(Icons.circle, size: 6, color: c.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(exerciseName(s.exerciseId))),
                              Text(_target(s),
                                  style: TextStyle(color: c.textMuted)),
                            ],
                          ),
                        )),
                    const SizedBox(height: Spacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style:
                            FilledButton.styleFrom(backgroundColor: c.primary),
                        onPressed: () {
                          FeedbackService.onTap();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    NewWorkoutScreen(preset: r.sets)),
                          );
                        },
                        child: Text(t('start_routine')),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  String _target(RoutineSet s) {
    if (s.weight != null) return '${fmtNum(s.weight!)}kg×${s.reps ?? 0}';
    if (s.sec != null) return '${s.sec}s';
    return '×${s.reps ?? 0}';
  }
}
