import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/theme_provider.dart';
import '../state/workout_provider.dart';
import '../state/locale_provider.dart';
import '../services/feedback_service.dart';
import '../models/workout.dart';
import '../utils/format.dart';
import '../theme/app_theme.dart';
import 'new_workout_screen.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final String id;
  const WorkoutDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    final wp = context.watch<WorkoutProvider>();
    final matches = wp.all.where((e) => e.id == id).toList();
    final Workout? w = matches.isEmpty ? null : matches.first;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('detail')),
        actions: [
          if (w != null)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              tooltip: t('edit_workout'),
              onPressed: () {
                FeedbackService.onTap();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NewWorkoutScreen(workoutToEdit: w),
                  ),
                );
              },
            ),
        ],
      ),
      body: w == null
          ? Center(child: Text(t('workout_not_found')))
          : ListView(
              padding: const EdgeInsets.all(Spacing.md),
              children: [
                Text(
                  formatDateTime(w.date),
                  style: TextStyle(color: c.textMuted),
                ),
                const SizedBox(height: Spacing.md),
                ...w.sets.map(
                  (s) => Card(
                    color: c.card,
                    margin: const EdgeInsets.only(bottom: Spacing.sm),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Radii.md),
                      side: BorderSide(color: c.border),
                    ),
                    child: ListTile(
                      title: Text(exerciseName(s.exerciseId)),
                      trailing: Text(
                        setValue(s),
                        style: TextStyle(
                          color: c.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                OutlinedButton.icon(
                  icon: Icon(Icons.delete_outline, color: c.danger),
                  label: Text(
                    t('delete_workout'),
                    style: TextStyle(color: c.danger),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: c.danger),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => _confirmDelete(context, w),
                ),
              ],
            ),
    );
  }

  void _confirmDelete(BuildContext context, Workout w) {
    final t = context.read<LocaleProvider>().t;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('delete_workout')),
        content: Text(t('confirm_delete_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t('cancel')),
          ),
          TextButton(
            onPressed: () {
              FeedbackService.medium();
              context.read<WorkoutProvider>().delete(w.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(t('delete')),
          ),
        ],
      ),
    );
  }
}
