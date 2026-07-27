import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/theme_provider.dart';
import '../../state/locale_provider.dart';
import '../../state/workout_provider.dart';
import '../../services/feedback_service.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import '../../screens/timer_screen.dart';
import 'skill_data.dart';

enum SkillStatus { locked, inProgress, unlocked }

/// Schermata "Albero delle Skill" del calisthenics.
class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  static const _key = '@calistrack/skillProgress';
  Map<String, double> _progress = {};
  // Migliori risultati registrati per esercizio (dalla cronologia).
  Map<String, double> _maxSec = {};
  Map<String, double> _maxReps = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = await StorageService.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      try {
        final m = Map<String, dynamic>.from(jsonDecode(raw));
        _progress = m.map((k, v) => MapEntry(k, (v as num).toDouble()));
      } catch (_) {}
    }
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _persist() async {
    await StorageService.setString(_key, jsonEncode(_progress));
  }

  /// Progresso automatico derivato dalla cronologia (0..100).
  double _autoPct(SkillNode n) {
    if (!n.hasAutoTarget) return 0;
    if (n.targetSec != null) {
      final best = _maxSec[n.exerciseId] ?? 0;
      return (best / n.targetSec! * 100).clamp(0, 100);
    }
    final best = _maxReps[n.exerciseId] ?? 0;
    return (best / n.targetReps! * 100).clamp(0, 100);
  }

  /// Progresso effettivo: massimo tra manuale e automatico.
  double _pct(String id) {
    final node = skillById[id];
    final manual = _progress[id] ?? 0;
    final auto = node == null ? 0.0 : _autoPct(node);
    return manual > auto ? manual : auto;
  }

  SkillStatus _status(SkillNode n) {
    final prereqsDone = n.prereqs.every((p) => _pct(p) >= 100);
    if (!prereqsDone) return SkillStatus.locked;
    if (_pct(n.id) >= 100) return SkillStatus.unlocked;
    return SkillStatus.inProgress;
  }

  /// Ricalcola i migliori risultati per esercizio dalla cronologia.
  void _computeBest(WorkoutProvider workouts) {
    final sec = <String, double>{};
    final reps = <String, double>{};
    for (final w in workouts.all) {
      if (w.discipline != 'calisthenics') continue;
      for (final s in w.sets) {
        if (s.sec != null) {
          sec[s.exerciseId] =
              (sec[s.exerciseId] ?? 0) < s.sec! ? s.sec!.toDouble() : sec[s.exerciseId]!;
        }
        if (s.reps != null) {
          reps[s.exerciseId] = (reps[s.exerciseId] ?? 0) < s.reps!
              ? s.reps!.toDouble()
              : reps[s.exerciseId]!;
        }
      }
    }
    _maxSec = sec;
    _maxReps = reps;
  }

  void _setProgress(String id, double pct) {
    setState(() => _progress[id] = pct.clamp(0, 100));
    _persist();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    _computeBest(context.watch<WorkoutProvider>());
    final unlockedCount =
        skillNodes.where((n) => _pct(n.id) >= 100).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('skills_title')),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: Spacing.md),
              child: Text('$unlockedCount/${skillNodes.length}',
                  style: TextStyle(
                      color: c.textMuted, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                const height = 620.0;
                return SingleChildScrollView(
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: Stack(
                      children: [
                        // Archi tra i nodi.
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _EdgePainter(
                              canvas: Size(width, height),
                              statusOf: (id) => _status(skillById[id]!),
                              primary: c.primary,
                              muted: c.border,
                            ),
                          ),
                        ),
                        // Nodi.
                        for (final n in skillNodes)
                          _positionedNode(n, width, height, c),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _positionedNode(
      SkillNode n, double width, double height, AppColors c) {
    const size = 62.0;
    final cx = n.x * width;
    final cy = n.y * height;
    final status = _status(n);
    return Positioned(
      left: cx - size / 2,
      top: cy - size / 2,
      width: size,
      height: size + 26, // spazio per l'etichetta
      child: _SkillNodeWidget(
        node: n,
        status: status,
        progress: _pct(n.id),
        colors: c,
        onTap: () => _openNode(n, status),
      ),
    );
  }

  void _openNode(SkillNode n, SkillStatus status) {
    if (status == SkillStatus.unlocked) {
      FeedbackService.medium();
    } else {
      FeedbackService.light();
    }
    final c = context.read<ThemeProvider>().colors;
    final t = context.read<LocaleProvider>().t;
    showModalBottomSheet(
      context: context,
      backgroundColor: c.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.lg))),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheet) {
          final pct = _pct(n.id);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(n.icon, color: c.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(n.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800)),
                      ),
                      _statusBadge(status, c, t),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(n.criteria,
                      style: TextStyle(color: c.textMuted, fontSize: 13)),
                  const SizedBox(height: Spacing.md),
                  if (status == SkillStatus.locked)
                    Text(t('skills_locked_hint'),
                        style: TextStyle(color: c.danger, fontSize: 12))
                  else ...[
                    Row(
                      children: [
                        Text('${pct.round()}%',
                            style: TextStyle(
                                color: c.primary,
                                fontWeight: FontWeight.w800)),
                        Expanded(
                          child: Slider(
                            value: pct,
                            max: 100,
                            divisions: 20,
                            activeColor: c.primary,
                            onChanged: (v) {
                              setSheet(() {});
                              _setProgress(n.id, v);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              FeedbackService.onTap();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => TimerScreen(
                                          exerciseName: n.name)));
                            },
                            icon: const Icon(Icons.timer_outlined),
                            label: Text(t('skills_start_set')),
                          ),
                        ),
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                                backgroundColor: c.primary),
                            onPressed: () {
                              FeedbackService.medium();
                              _setProgress(n.id, 100);
                              setSheet(() {});
                            },
                            icon: const Icon(Icons.check_rounded),
                            label: Text(t('skills_complete')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _statusBadge(SkillStatus s, AppColors c, dynamic t) {
    final (label, color) = switch (s) {
      SkillStatus.locked => (t('skills_state_locked'), c.textMuted),
      SkillStatus.inProgress => (t('skills_state_progress'), c.primary),
      SkillStatus.unlocked => (t('skills_state_done'), c.primary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w800)),
    );
  }
}

// ---------------------------------------------------------------------------
// Nodo
// ---------------------------------------------------------------------------
class _SkillNodeWidget extends StatelessWidget {
  final SkillNode node;
  final SkillStatus status;
  final double progress;
  final AppColors colors;
  final VoidCallback onTap;

  const _SkillNodeWidget({
    required this.node,
    required this.status,
    required this.progress,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final locked = status == SkillStatus.locked;
    final unlocked = status == SkillStatus.unlocked;
    final ring = unlocked ? 1.0 : progress / 100;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          SizedBox(
            width: 62,
            height: 62,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Anello di progresso animato.
                if (!locked)
                  SizedBox(
                    width: 62,
                    height: 62,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: ring),
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, _) => CircularProgressIndicator(
                        value: unlocked ? null : v,
                        strokeWidth: 3.5,
                        backgroundColor: c.cardAlt,
                        valueColor: AlwaysStoppedAnimation(
                            unlocked ? c.primary : c.primary),
                      ),
                    ),
                  ),
                // Corpo del nodo.
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: locked
                        ? c.cardAlt
                        : Color.alphaBlend(
                            c.primary.withValues(alpha: 0.18), c.card),
                    border: Border.all(
                      color: locked ? c.border : c.primary,
                      width: unlocked ? 2 : 1.4,
                    ),
                  ),
                  child: Icon(
                    locked ? Icons.lock_rounded : node.icon,
                    size: 20,
                    color: locked
                        ? c.textMuted
                        : (unlocked ? c.primary : c.text),
                  ),
                ),
                if (unlocked)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          color: c.primary, shape: BoxShape.circle),
                      child: Icon(Icons.check_rounded,
                          size: 12,
                          color: c.bg.computeLuminance() > 0.5
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            node.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: locked ? c.textMuted : c.text),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Archi
// ---------------------------------------------------------------------------
class _EdgePainter extends CustomPainter {
  final Size canvas;
  final SkillStatus Function(String id) statusOf;
  final Color primary;
  final Color muted;

  _EdgePainter({
    required this.canvas,
    required this.statusOf,
    required this.primary,
    required this.muted,
  });

  @override
  void paint(Canvas c, Size size) {
    for (final (from, to) in skillEdges) {
      final a = skillById[from]!;
      final b = skillById[to]!;
      final p1 = Offset(a.x * size.width, a.y * size.height);
      final p2 = Offset(b.x * size.width, b.y * size.height);
      final active = statusOf(to) != SkillStatus.locked;
      final paint = Paint()
        ..color = active ? primary.withValues(alpha: 0.7) : muted
        ..strokeWidth = active ? 2.5 : 1.4
        ..style = PaintingStyle.stroke;
      // Curva morbida verticale.
      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..cubicTo(p1.dx, (p1.dy + p2.dy) / 2, p2.dx,
            (p1.dy + p2.dy) / 2, p2.dx, p2.dy);
      c.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_EdgePainter old) => true;
}
