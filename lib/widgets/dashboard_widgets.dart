import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/theme_provider.dart';
import '../state/workout_provider.dart';
import '../state/discipline_provider.dart';
import '../state/locale_provider.dart';
import '../state/health_provider.dart';
import '../state/dashboard_provider.dart';
import '../state/draft_provider.dart';
import '../models/health_data.dart';
import '../models/workout.dart';
import '../data/ranks.dart';
import '../data/routines.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../services/feedback_service.dart';
import 'design_system.dart';
import 'ui_kit.dart';
import 'health_charts.dart';
import 'medal.dart';
import '../screens/new_workout_screen.dart';
import '../screens/timer_screen.dart';
import '../screens/ranks_screen.dart';

/// Mappa un [DashWidget] al widget concreto da renderizzare.
Widget buildDashWidget(
  BuildContext context,
  DashWidget type,
  void Function(String tab) onOpenTab,
) {
  switch (type) {
    case DashWidget.shortcuts:
      return _ShortcutsWidget(onOpenTab: onOpenTab);
    case DashWidget.heartWave:
      return const _HeartWaveWidget();
    case DashWidget.activityRings:
      return const _ActivityRingsWidget();
    case DashWidget.vitals:
      return const _VitalsWidget();
    case DashWidget.sleep:
      return const _SleepWidget();
    case DashWidget.workoutStats:
      return const _WorkoutStatsWidget();
    case DashWidget.rank:
      return const _RankWidget();
    case DashWidget.quickTimer:
      return const _QuickTimerWidget();
    case DashWidget.nextRoutine:
      return const _NextRoutineWidget();
  }
}

// ---------------------------------------------------------------------------
// Scorciatoie
// ---------------------------------------------------------------------------
class _ShortcutsWidget extends StatelessWidget {
  final void Function(String tab) onOpenTab;
  const _ShortcutsWidget({required this.onOpenTab});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    final items = <(IconData, String, VoidCallback)>[
      (Icons.menu_book_rounded, t('diary'), () => onOpenTab('diary')),
      (Icons.assignment_outlined, t('nav_routines'),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewWorkoutScreen()))),
      (Icons.show_chart_rounded, t('nav_progress'), () => onOpenTab('progress')),
      (Icons.military_tech_outlined, t('nav_medals'),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RanksScreen()))),
      (Icons.fitness_center, t('nav_exercises'), () => onOpenTab('exercises')),
      (Icons.monitor_heart_rounded, t('nav_health'), () => onOpenTab('health')),
    ];
    return SurfaceCard(
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.35,
        children: [
          for (final it in items)
            PressableScaleShortcut(
              icon: it.$1,
              label: it.$2,
              color: c.primary,
              onTap: () {
                FeedbackService.onTap();
                it.$3();
              },
            ),
        ],
      ),
    );
  }
}

class PressableScaleShortcut extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const PressableScaleShortcut({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: c.cardAlt,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: c.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 5),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: c.text)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Battiti + sinusoide live
// ---------------------------------------------------------------------------
class _HeartWaveWidget extends StatelessWidget {
  const _HeartWaveWidget();

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleProvider>().t;
    final health = context.watch<HealthProvider>();
    final s = health.series(HealthMetric.heartRate);
    final bpm = s?.latest ?? s?.avg;
    final accent = HealthMetric.heartRate.accent;
    return SurfaceCard(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite_rounded, color: accent, size: 18),
              const SizedBox(width: 8),
              Text(t('hm_heart_rate'),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              if (bpm != null)
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: bpm.round().toString(),
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: accent)),
                    TextSpan(
                        text: ' bpm',
                        style: TextStyle(
                            fontSize: 12,
                            color: accent.withValues(alpha: 0.8))),
                  ]),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (bpm != null)
            HeartWave(color: accent, bpm: bpm, height: 84)
          else
            _needData(context, t),
        ],
      ),
    );
  }
}

Widget _needData(BuildContext context, dynamic t) {
  final c = context.watch<ThemeProvider>().colors;
  return Container(
    height: 60,
    alignment: Alignment.center,
    child: Text(t('health_no_data_short'),
        style: TextStyle(color: c.textMuted, fontSize: 12)),
  );
}

// ---------------------------------------------------------------------------
// Anelli attività
// ---------------------------------------------------------------------------
class _ActivityRingsWidget extends StatelessWidget {
  const _ActivityRingsWidget();

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    final health = context.watch<HealthProvider>();
    final steps = health.series(HealthMetric.steps)?.daily.lastOrNull?.value ?? 0;
    final kcal =
        health.series(HealthMetric.calories)?.daily.lastOrNull?.value ?? 0;
    final stepGoal = health.goalSteps;
    final kcalGoal = health.goalCalories;
    final stepColor = HealthMetric.steps.accent;
    final kcalColor = HealthMetric.calories.accent;
    return SurfaceCard(
      child: Row(
        children: [
          RingGauge(
            progress: steps / stepGoal,
            color: stepColor,
            trackColor: c.cardAlt,
            size: 70,
            center: Icon(Icons.directions_walk_rounded,
                size: 20, color: stepColor),
          ),
          const SizedBox(width: 14),
          RingGauge(
            progress: kcal / kcalGoal,
            color: kcalColor,
            trackColor: c.cardAlt,
            size: 70,
            center: Icon(Icons.local_fire_department_rounded,
                size: 20, color: kcalColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _kv(context, t('hm_steps'), '${steps.round()}', stepColor),
                const SizedBox(height: 8),
                _kv(context, t('hm_calories'), '${kcal.round()} kcal',
                    kcalColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v, Color color) {
    final c = context.watch<ThemeProvider>().colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: TextStyle(fontSize: 11, color: c.textMuted)),
        Text(v,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Vitali (pressione / SpO2 / HRV)
// ---------------------------------------------------------------------------
class _VitalsWidget extends StatelessWidget {
  const _VitalsWidget();

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleProvider>().t;
    final health = context.watch<HealthProvider>();
    final bp = health.series(HealthMetric.bloodPressure);
    final spo2 = health.series(HealthMetric.spo2);
    final hrv = health.series(HealthMetric.hrv);
    final sys = bp?.daily.lastOrNull?.value;
    final dia = bp?.daily.lastOrNull?.value2;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: t('vitals').toUpperCase(), icon: Icons.monitor_heart_rounded),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatTile(
                label: t('hm_blood_pressure'),
                value: sys != null
                    ? '${sys.round()}/${dia?.round() ?? '--'}'
                    : '--',
                unit: 'mmHg',
                icon: Icons.bloodtype_rounded,
                color: HealthMetric.bloodPressure.accent,
              ),
              StatTile(
                label: 'SpO₂',
                value: spo2?.latest?.round().toString() ??
                    spo2?.daily.lastOrNull?.value.round().toString() ??
                    '--',
                unit: '%',
                icon: Icons.air_rounded,
                color: HealthMetric.spo2.accent,
              ),
              StatTile(
                label: 'HRV',
                value: hrv?.daily.lastOrNull?.value.round().toString() ?? '--',
                unit: 'ms',
                icon: Icons.graphic_eq_rounded,
                color: HealthMetric.hrv.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sonno
// ---------------------------------------------------------------------------
class _SleepWidget extends StatelessWidget {
  const _SleepWidget();

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    final health = context.watch<HealthProvider>();
    final s = health.series(HealthMetric.sleep);
    final last = s?.daily.lastOrNull?.value;
    final accent = HealthMetric.sleep.accent;
    return SurfaceCard(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bedtime_rounded, color: accent, size: 18),
              const SizedBox(width: 8),
              Text(t('hm_sleep'),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(
                last != null
                    ? '${last.floor()}h ${((last % 1) * 60).round()}m'
                    : '--',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w900, color: accent),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (s != null && s.daily.length > 1)
            Sparkline(
                values: s.daily.map((e) => e.value).toList(), color: accent)
          else
            SizedBox(
                height: 40,
                child: Center(
                    child: Text(t('health_no_data_short'),
                        style: TextStyle(color: c.textMuted, fontSize: 12)))),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Statistiche allenamento (settimana)
// ---------------------------------------------------------------------------
class _WorkoutStatsWidget extends StatelessWidget {
  const _WorkoutStatsWidget();

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleProvider>().t;
    final disc = context.watch<DisciplineProvider>().discipline;
    final all = context.watch<WorkoutProvider>().forDiscipline(disc);
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final week = all.where((w) => w.date.isAfter(weekAgo)).toList();
    double volume = 0;
    int sets = 0;
    for (final w in week) {
      for (final s in w.sets) {
        sets++;
        if (disc == 'gym') {
          volume += (s.weight ?? 0) * (s.reps ?? 0);
        } else {
          volume += (s.reps ?? 0) + (s.sec ?? 0);
        }
      }
    }
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
              title: '${t('nav_progress')} · 7${t('day_short')}',
              icon: Icons.insights_rounded),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatTile(
                  label: t('sessions'), value: week.length.toString()),
              StatTile(label: t('total_sets'), value: sets.toString()),
              StatTile(
                  label: disc == 'gym' ? t('volume_kg') : t('total_reps'),
                  value: fmtNum(volume)),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Rango / livello
// ---------------------------------------------------------------------------
class _RankWidget extends StatelessWidget {
  const _RankWidget();

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    final disc = context.watch<DisciplineProvider>().discipline;
    final all = context.watch<WorkoutProvider>().forDiscipline(disc);
    final pts = totalPoints(all);
    final info = rankFor(pts);
    return SurfaceCard(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const RanksScreen())),
      child: Row(
        children: [
          Medal(rank: info.current, size: 54),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(info.current.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('$pts ${t('points')}',
                    style: TextStyle(color: c.textMuted, fontSize: 12)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: info.progress,
                    minHeight: 7,
                    backgroundColor: c.cardAlt,
                    valueColor:
                        AlwaysStoppedAnimation(info.current.glow),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Timer rapido
// ---------------------------------------------------------------------------
class _QuickTimerWidget extends StatelessWidget {
  const _QuickTimerWidget();

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: t('timer').toUpperCase(), icon: Icons.timer_rounded),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in [30, 45, 60, 90])
                GestureDetector(
                  onTap: () {
                    FeedbackService.onTap();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const TimerScreen()));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: c.cardAlt,
                      borderRadius: BorderRadius.circular(Radii.md),
                      border: Border.all(color: c.border),
                    ),
                    child: Text('${s}s',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: c.primary)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero: ultima sessione / avvio rapido workout
// ---------------------------------------------------------------------------
class DashboardHero extends StatelessWidget {
  final void Function(String tab) onOpenTab;
  const DashboardHero({super.key, required this.onOpenTab});

  @override
  Widget build(BuildContext context) {
    final disc = context.watch<DisciplineProvider>().discipline;
    final workouts = context.watch<WorkoutProvider>().forDiscipline(disc);
    final last = workouts.isEmpty ? null : workouts.first;
    final draft = context.watch<DraftProvider>().draftFor(disc);
    final resumeCount = draft?.sets.length ?? 0;
    final startedAt = draft?.startedAt;

    // Transizione fluida quando cambia disciplina o ultima sessione.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.04), end: Offset.zero)
              .animate(anim),
          child: child,
        ),
      ),
      child: _HeroCard(
        key: ValueKey('$disc-${last?.id ?? 'none'}-r$resumeCount'),
        last: last,
        resumeCount: resumeCount,
        startedAt: startedAt,
        onOpenTab: onOpenTab,
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Workout? last;
  final int resumeCount;
  final DateTime? startedAt;
  final void Function(String tab) onOpenTab;
  const _HeroCard(
      {super.key,
      required this.last,
      required this.onOpenTab,
      this.resumeCount = 0,
      this.startedAt});

  String _elapsed() {
    if (startedAt == null) return '';
    final d = DateTime.now().difference(startedAt!);
    if (d.inMinutes < 1) return 'ora';
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    return '${d.inHours}h ${d.inMinutes % 60}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final c = theme.colors;
    final t = context.watch<LocaleProvider>().t;

    final resuming = resumeCount > 0;

    void startWorkout() {
      FeedbackService.onTap();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => NewWorkoutScreen(resumeDraft: resuming)));
    }

    final onPrimary = theme.skin.isDark ? Colors.black : Colors.white;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(c.primary.withValues(alpha: 0.22), c.card),
            Color.alphaBlend(c.primary.withValues(alpha: 0.06), c.cardAlt),
          ],
        ),
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: c.primary.withValues(alpha: 0.35)),
        boxShadow: theme.glowActive
            ? glowShadow(c.primary, blur: 18)
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: theme.skin.isDark ? 0.3 : 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: c.primary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(Radii.md),
                ),
                child: Icon(
                  resuming
                      ? Icons.play_circle_fill_rounded
                      : (last == null
                          ? Icons.bolt_rounded
                          : Icons.history_rounded),
                  color: c.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resuming
                          ? t('hero_in_progress')
                          : (last == null
                              ? t('hero_no_sessions')
                              : t('hero_last_session')),
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: c.textMuted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      resuming
                          ? t.p('hero_draft_sets', {'n': '$resumeCount'})
                          : (last == null
                              ? t('hero_subtitle')
                              : formatDate(last!.date)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                    if (resuming) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded,
                              size: 12, color: c.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            t.p('hero_since', {'t': _elapsed()}),
                            style:
                                TextStyle(fontSize: 12, color: c.textMuted),
                          ),
                        ],
                      ),
                    ] else if (last != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        workoutSummary(last!),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: c.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          // CTA grande e tattile (min 52dp) facile da premere in palestra.
          SizedBox(
            width: double.infinity,
            height: 52,
            child: PressableScale(
              onTap: startWorkout,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: c.primary,
                  borderRadius: BorderRadius.circular(Radii.md),
                  boxShadow: theme.glowActive
                      ? glowShadow(c.primary, blur: 12)
                      : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                          resuming
                              ? Icons.play_arrow_rounded
                              : Icons.play_arrow_rounded,
                          color: onPrimary),
                      const SizedBox(width: 8),
                      Text(
                        resuming ? t('hero_resume') : t('hero_start'),
                        style: TextStyle(
                            color: onPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (resuming) ...[
            const SizedBox(height: Spacing.sm),
            Row(
              children: [
                Expanded(
                  child: _heroAction(context, c, Icons.timer_outlined,
                      t('timer'), () {
                    FeedbackService.onTap();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const TimerScreen()));
                  }),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: _heroAction(context, c, Icons.menu_book_rounded,
                      t('diary'), () {
                    FeedbackService.onTap();
                    onOpenTab('diary');
                  }),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _heroAction(BuildContext context, AppColors c, IconData icon,
      String label, VoidCallback onTap) {
    return Material(
      color: c.cardAlt,
      borderRadius: BorderRadius.circular(Radii.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.md),
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(color: c.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: c.primary),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: c.text, fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Prossima routine
// ---------------------------------------------------------------------------
class _NextRoutineWidget extends StatelessWidget {
  const _NextRoutineWidget();

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    final disc = context.watch<DisciplineProvider>().discipline;
    final routines = getRoutines(disc);
    if (routines.isEmpty) return const SizedBox.shrink();
    final r = routines.first;
    return SurfaceCard(
      onTap: () {
        FeedbackService.onTap();
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => NewWorkoutScreen(preset: r.sets)));
      },
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: c.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            child: Icon(Icons.play_arrow_rounded, color: c.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t('dw_routine'),
                    style: TextStyle(fontSize: 11, color: c.textMuted)),
                Text(r.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800)),
                Text('${r.duration} · ${r.level}',
                    style: TextStyle(fontSize: 12, color: c.textMuted)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: c.textMuted),
        ],
      ),
    );
  }
}
