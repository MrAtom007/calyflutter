import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/theme_provider.dart';
import '../state/workout_provider.dart';
import '../state/locale_provider.dart';
import '../data/achievements.dart';
import '../theme/app_theme.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    final all = context.watch<WorkoutProvider>().all;
    final stats = computeBadgeStats(all);
    final unlocked = badgeDefs.where((b) => b.unlocked(stats)).length;

    return Scaffold(
      appBar: AppBar(title: Text(t('achievements'))),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          // Riepilogo
          Container(
            padding: const EdgeInsets.all(Spacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.alphaBlend(c.primary.withValues(alpha: 0.22), c.card),
                  Color.alphaBlend(
                    c.primary.withValues(alpha: 0.05),
                    c.cardAlt,
                  ),
                ],
              ),
              borderRadius: BorderRadius.circular(Radii.lg),
              border: Border.all(color: c.primary.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_events_rounded, size: 40, color: c.primary),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$unlocked / ${badgeDefs.length}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        t('achievements_unlocked'),
                        style: TextStyle(color: c.textMuted, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: badgeDefs.isEmpty
                              ? 0
                              : unlocked / badgeDefs.length,
                          minHeight: 8,
                          backgroundColor: c.border,
                          valueColor: AlwaysStoppedAnimation(c.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),
          ...badgeDefs.map((b) => _badgeTile(context, c, t, b, stats)),
          const SizedBox(height: Spacing.xl),
        ],
      ),
    );
  }

  Widget _badgeTile(
    BuildContext context,
    AppColors c,
    dynamic t,
    BadgeDef b,
    BadgeStats stats,
  ) {
    final done = b.unlocked(stats);
    final cur = b.current(stats);
    final prog = b.progress(stats);
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(
          color: done ? b.color.withValues(alpha: 0.7) : c.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: (done ? b.color : c.textMuted).withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              done ? b.icon : Icons.lock_rounded,
              color: done ? b.color : c.textMuted,
              size: 24,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.p(b.descKey, {'n': '${b.threshold}'}),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: done ? c.text : c.text.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: prog,
                    minHeight: 6,
                    backgroundColor: c.cardAlt,
                    valueColor: AlwaysStoppedAnimation(
                      done ? b.color : c.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$cur / ${b.threshold}',
                  style: TextStyle(color: c.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          if (done) ...[
            const SizedBox(width: Spacing.sm),
            Icon(Icons.check_circle_rounded, color: b.color, size: 22),
          ],
        ],
      ),
    );
  }
}
