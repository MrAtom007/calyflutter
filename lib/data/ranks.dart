import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/workout.dart';

Color _hex(String h) {
  h = h.replaceAll('#', '');
  if (h.length == 6) h = 'FF$h';
  return Color(int.parse(h, radix: 16));
}

/// Un rango della scala di gamification.
class Rank {
  final String id;
  final String name;
  final String icon; // emoji
  final IconData mci;
  final Color color;
  final Color color2; // secondo stop gradiente
  final Color glow;
  final int min; // punti soglia

  const Rank({
    required this.id,
    required this.name,
    required this.icon,
    required this.mci,
    required this.color,
    required this.color2,
    required this.glow,
    required this.min,
  });
}

final List<Rank> ranks = [
  Rank(
    id: 'wood',
    name: 'Legno',
    icon: '🪵',
    mci: Icons.park,
    color: _hex('#9c6b3f'),
    color2: _hex('#6d4a2b'),
    glow: _hex('#c98a52'),
    min: 0,
  ),
  Rank(
    id: 'stone',
    name: 'Pietra',
    icon: '🪨',
    mci: Icons.terrain,
    color: _hex('#9aa0a6'),
    color2: _hex('#6b7075'),
    glow: _hex('#b8bec4'),
    min: 300,
  ),
  Rank(
    id: 'bronze',
    name: 'Bronzo',
    icon: '🥉',
    mci: Icons.military_tech_outlined,
    color: _hex('#cd7f32'),
    color2: _hex('#8a5320'),
    glow: _hex('#e6a15a'),
    min: 900,
  ),
  Rank(
    id: 'iron',
    name: 'Ferro',
    icon: '⚙️',
    mci: Icons.settings,
    color: _hex('#c2c8cf'),
    color2: _hex('#7d858e'),
    glow: _hex('#dfe4e9'),
    min: 2000,
  ),
  Rank(
    id: 'silver',
    name: 'Argento',
    icon: '🥈',
    mci: Icons.military_tech,
    color: _hex('#d8d8d8'),
    color2: _hex('#9a9a9a'),
    glow: _hex('#ffffff'),
    min: 4000,
  ),
  Rank(
    id: 'gold',
    name: 'Oro',
    icon: '🥇',
    mci: Icons.emoji_events,
    color: _hex('#ffd700'),
    color2: _hex('#c79a00'),
    glow: _hex('#fff2a8'),
    min: 7500,
  ),
  Rank(
    id: 'platinum',
    name: 'Platino',
    icon: '💠',
    mci: Icons.shield,
    color: _hex('#e9edf0'),
    color2: _hex('#a9b4bd'),
    glow: _hex('#ffffff'),
    min: 13000,
  ),
  Rank(
    id: 'diamond',
    name: 'Diamante',
    icon: '💎',
    mci: Icons.diamond,
    color: _hex('#7fe3f2'),
    color2: _hex('#2aa7c4'),
    glow: _hex('#c8f6ff'),
    min: 22000,
  ),
  Rank(
    id: 'painite',
    name: 'Painite',
    icon: '🟥',
    mci: Icons.hexagon,
    color: _hex('#d24437'),
    color2: _hex('#7c1f18'),
    glow: _hex('#ff7a6b'),
    min: 38000,
  ),
  Rank(
    id: 'antimatter',
    name: 'Antimateria',
    icon: '⚛️',
    mci: Icons.blur_on,
    color: _hex('#c77bff'),
    color2: _hex('#6d28d9'),
    glow: _hex('#e9b6ff'),
    min: 60000,
  ),
];

final int maxLevel = ranks.length;

/// Livello 1..N in base all'id del rango.
int levelOf(String rankId) => ranks.indexWhere((r) => r.id == rankId) + 1;

/// Punteggio di un allenamento.
double workoutPoints(Workout w) {
  double pts = 0;
  for (final s in w.sets) {
    if (w.discipline == 'gym') {
      pts += ((s.weight ?? 0) * (s.reps ?? 0)) / 10;
    } else {
      pts += (s.reps ?? 0) * 1 + (s.sec ?? 0) * 0.5;
    }
  }
  return pts;
}

int totalPoints(List<Workout> workouts) =>
    workouts.fold<double>(0, (acc, w) => acc + workoutPoints(w)).round();

/// Rango attuale + prossimo + progresso (0..1).
class RankInfo {
  final Rank current;
  final Rank? next;
  final double progress;
  const RankInfo(this.current, this.next, this.progress);
}

RankInfo rankFor(int points) {
  Rank current = ranks[0];
  Rank? next;
  for (int i = 0; i < ranks.length; i++) {
    if (points >= ranks[i].min) {
      current = ranks[i];
      next = i + 1 < ranks.length ? ranks[i + 1] : null;
    }
  }
  final progress = next != null
      ? math.min(1.0, (points - current.min) / (next.min - current.min))
      : 1.0;
  return RankInfo(current, next, progress);
}
