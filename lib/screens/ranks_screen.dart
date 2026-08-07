import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../state/theme_provider.dart';
import '../state/discipline_provider.dart';
import '../state/workout_provider.dart';
import '../state/locale_provider.dart';
import '../services/feedback_service.dart';
import '../data/ranks.dart';
import '../theme/app_theme.dart';
import '../widgets/discipline_switch.dart';
import '../widgets/medal.dart';

class RanksScreen extends StatelessWidget {
  const RanksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    final discipline = context.watch<DisciplineProvider>().discipline;
    final workouts = context.watch<WorkoutProvider>().forDiscipline(discipline);
    final pts = totalPoints(workouts);
    final info = rankFor(pts);
    final level = levelOf(info.current.id);

    return Scaffold(
      appBar: AppBar(title: Text(t('nav_medals'))),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          const DisciplineSwitch(),
          const SizedBox(height: Spacing.sm),
          // Hero card
          Container(
            padding: const EdgeInsets.all(Spacing.lg),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(Radii.lg),
              border: Border.all(
                color: info.current.color.withValues(alpha: 0.6),
              ),
            ),
            child: Column(
              children: [
                Medal(
                  rank: info.current,
                  size: 140,
                  progress: info.progress,
                  level: level,
                ),
                const SizedBox(height: Spacing.md),
                Text(
                  info.current.name,
                  style: TextStyle(
                    color: info.current.color,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${t('level')} $level/$maxLevel',
                  style: TextStyle(color: c.textMuted),
                ),
                const SizedBox(height: 6),
                Text(
                  '$pts pt • ${workouts.length} ${t('workouts').toLowerCase()}',
                  style: TextStyle(color: c.text),
                ),
                const SizedBox(height: 6),
                Text(
                  info.next != null
                      ? t.p('points_for_next', {
                          'n': '${info.next!.min - pts}',
                          'name': info.next!.name,
                        })
                      : t('max_rank'),
                  style: TextStyle(color: c.textMuted, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Spacing.md),
                OutlinedButton.icon(
                  icon: const Icon(Icons.share),
                  label: Text(t('share_progress')),
                  onPressed: () {
                    FeedbackService.onTap();
                    Share.share(
                      'Sono ${info.current.name} (Lv $level) su CaliStrack con $pts punti! 💪',
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Text(
            t('ranks_scale'),
            style: TextStyle(color: c.textMuted, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: Spacing.sm),
          ...ranks.reversed.map((r) {
            final unlocked = pts >= r.min;
            final isCurrent = r.id == info.current.id;
            return Opacity(
              opacity: unlocked ? 1 : 0.55,
              child: Container(
                margin: const EdgeInsets.only(bottom: Spacing.sm),
                padding: const EdgeInsets.all(Spacing.sm),
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(Radii.md),
                  border: Border.all(
                    color: isCurrent ? r.color : c.border,
                    width: isCurrent ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Medal(
                      rank: r,
                      size: 54,
                      progress: unlocked ? 1 : 0,
                      locked: !unlocked,
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lv ${levelOf(r.id)} · ${r.name}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${r.min} ${t('points')}',
                            style: TextStyle(color: c.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: r.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(Radii.sm),
                        ),
                        child: Text(
                          t('current'),
                          style: TextStyle(
                            color: r.color,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: Spacing.lg),
          Text(
            t('points_explanation'),
            style: TextStyle(color: c.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
