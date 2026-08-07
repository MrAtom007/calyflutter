import 'package:flutter/material.dart';
import '../models/workout.dart';
import 'ranks.dart';

/// Statistiche aggregate usate per valutare i traguardi.
class BadgeStats {
  final int sessions;
  final int points;
  final int totalReps;
  final int totalSec;
  final int streak;
  final int distinctExercises;
  final double maxWeight;

  const BadgeStats({
    required this.sessions,
    required this.points,
    required this.totalReps,
    required this.totalSec,
    required this.streak,
    required this.distinctExercises,
    required this.maxWeight,
  });
}

BadgeStats computeBadgeStats(List<Workout> all) {
  int reps = 0;
  int sec = 0;
  double maxW = 0;
  final ex = <String>{};
  for (final w in all) {
    for (final s in w.sets) {
      reps += s.reps ?? 0;
      sec += s.sec ?? 0;
      if ((s.weight ?? 0) > maxW) maxW = s.weight ?? 0;
      ex.add(s.exerciseId);
    }
  }
  // Miglior serie di giorni consecutivi.
  final days =
      all
          .map((w) => DateTime(w.date.year, w.date.month, w.date.day))
          .toSet()
          .toList()
        ..sort();
  int best = 0;
  int cur = 0;
  DateTime? prev;
  for (final d in days) {
    if (prev != null && d.difference(prev).inDays == 1) {
      cur++;
    } else {
      cur = 1;
    }
    if (cur > best) best = cur;
    prev = d;
  }
  return BadgeStats(
    sessions: all.length,
    points: totalPoints(all),
    totalReps: reps,
    totalSec: sec,
    streak: best,
    distinctExercises: ex.length,
    maxWeight: maxW,
  );
}

enum BadgeMetric { sessions, points, streak, reps, hold, weight, variety }

class BadgeDef {
  final String id;
  final IconData icon;
  final BadgeMetric metric;
  final int threshold;
  final Color color;
  const BadgeDef(this.id, this.icon, this.metric, this.threshold, this.color);

  /// Chiave di localizzazione del template descrizione (usa {n}).
  String get descKey => switch (metric) {
    BadgeMetric.sessions => 'badge_sessions',
    BadgeMetric.points => 'badge_points',
    BadgeMetric.streak => 'badge_streak',
    BadgeMetric.reps => 'badge_reps',
    BadgeMetric.hold => 'badge_hold',
    BadgeMetric.weight => 'badge_weight',
    BadgeMetric.variety => 'badge_variety',
  };

  int current(BadgeStats s) => switch (metric) {
    BadgeMetric.sessions => s.sessions,
    BadgeMetric.points => s.points,
    BadgeMetric.streak => s.streak,
    BadgeMetric.reps => s.totalReps,
    BadgeMetric.hold => s.totalSec,
    BadgeMetric.weight => s.maxWeight.round(),
    BadgeMetric.variety => s.distinctExercises,
  };

  bool unlocked(BadgeStats s) => current(s) >= threshold;
  double progress(BadgeStats s) => (current(s) / threshold).clamp(0.0, 1.0);
}

const List<BadgeDef> badgeDefs = [
  // Sessioni
  BadgeDef(
    's1',
    Icons.flag_rounded,
    BadgeMetric.sessions,
    1,
    Color(0xff4cd964),
  ),
  BadgeDef(
    's10',
    Icons.military_tech_rounded,
    BadgeMetric.sessions,
    10,
    Color(0xff38bdf8),
  ),
  BadgeDef(
    's25',
    Icons.military_tech_rounded,
    BadgeMetric.sessions,
    25,
    Color(0xffa78bfa),
  ),
  BadgeDef(
    's50',
    Icons.workspace_premium_rounded,
    BadgeMetric.sessions,
    50,
    Color(0xfff59e0b),
  ),
  BadgeDef(
    's100',
    Icons.workspace_premium_rounded,
    BadgeMetric.sessions,
    100,
    Color(0xfff43f5e),
  ),
  BadgeDef(
    's250',
    Icons.diamond_rounded,
    BadgeMetric.sessions,
    250,
    Color(0xff2ee6d6),
  ),
  // Punti
  BadgeDef(
    'p1k',
    Icons.bolt_rounded,
    BadgeMetric.points,
    1000,
    Color(0xff4cd964),
  ),
  BadgeDef(
    'p5k',
    Icons.bolt_rounded,
    BadgeMetric.points,
    5000,
    Color(0xff38bdf8),
  ),
  BadgeDef(
    'p15k',
    Icons.electric_bolt_rounded,
    BadgeMetric.points,
    15000,
    Color(0xfff59e0b),
  ),
  BadgeDef(
    'p40k',
    Icons.electric_bolt_rounded,
    BadgeMetric.points,
    40000,
    Color(0xfff43f5e),
  ),
  // Costanza (streak)
  BadgeDef(
    'st3',
    Icons.local_fire_department_rounded,
    BadgeMetric.streak,
    3,
    Color(0xffff6a00),
  ),
  BadgeDef(
    'st7',
    Icons.local_fire_department_rounded,
    BadgeMetric.streak,
    7,
    Color(0xffff3b3b),
  ),
  BadgeDef(
    'st14',
    Icons.whatshot_rounded,
    BadgeMetric.streak,
    14,
    Color(0xffff2ec4),
  ),
  BadgeDef(
    'st30',
    Icons.whatshot_rounded,
    BadgeMetric.streak,
    30,
    Color(0xff9d4bff),
  ),
  // Ripetizioni
  BadgeDef(
    'r1k',
    Icons.repeat_rounded,
    BadgeMetric.reps,
    1000,
    Color(0xff34d399),
  ),
  BadgeDef(
    'r10k',
    Icons.repeat_rounded,
    BadgeMetric.reps,
    10000,
    Color(0xfff59e0b),
  ),
  // Tenute (secondi)
  BadgeDef(
    'h600',
    Icons.timer_rounded,
    BadgeMetric.hold,
    600,
    Color(0xff38bdf8),
  ),
  BadgeDef(
    'h3600',
    Icons.timer_rounded,
    BadgeMetric.hold,
    3600,
    Color(0xffa78bfa),
  ),
  // Forza (peso max in una serie)
  BadgeDef(
    'w50',
    Icons.fitness_center_rounded,
    BadgeMetric.weight,
    50,
    Color(0xff58a6ff),
  ),
  BadgeDef(
    'w100',
    Icons.fitness_center_rounded,
    BadgeMetric.weight,
    100,
    Color(0xfff43f5e),
  ),
  // Varietà
  BadgeDef(
    'v5',
    Icons.grid_view_rounded,
    BadgeMetric.variety,
    5,
    Color(0xff4cd964),
  ),
  BadgeDef(
    'v15',
    Icons.grid_view_rounded,
    BadgeMetric.variety,
    15,
    Color(0xff38bdf8),
  ),
  BadgeDef(
    'v30',
    Icons.grid_view_rounded,
    BadgeMetric.variety,
    30,
    Color(0xfff59e0b),
  ),
];
