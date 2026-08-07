import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../state/theme_provider.dart';
import '../state/discipline_provider.dart';
import '../state/workout_provider.dart';
import '../state/levelup_provider.dart';
import '../state/locale_provider.dart';
import '../services/storage_service.dart';
import '../services/feedback_service.dart';
import '../data/ranks.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/discipline_switch.dart';
import '../widgets/medal.dart';
import '../widgets/animated_number.dart';
import '../widgets/ui_kit.dart';
import '../widgets/design_system.dart';
import 'new_workout_screen.dart';
import 'workout_detail_screen.dart';
import 'timer_screen.dart';
import 'store_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkLevelUp());
  }

  Future<void> _checkLevelUp() async {
    if (!mounted) return;
    final dp = context.read<DisciplineProvider>();
    final wp = context.read<WorkoutProvider>();
    final pts = totalPoints(wp.forDiscipline(dp.discipline));
    final lvl = levelOf(rankFor(pts).current.id);
    final last = await StorageService.getLastLevel(dp.discipline);
    if (last != null && lvl > last && mounted) {
      context.read<LevelUpProvider>().celebrate(ranks[lvl - 1], lvl);
    }
    if (last == null || lvl != last) {
      await StorageService.setLastLevel(dp.discipline, lvl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final c = theme.colors;
    final t = context.watch<LocaleProvider>().t;
    final dp = context.watch<DisciplineProvider>();
    final wp = context.watch<WorkoutProvider>();
    final workouts = wp.forDiscipline(dp.discipline);
    final pts = totalPoints(workouts);
    final info = rankFor(pts);
    final totalSets = workouts.fold<int>(0, (a, w) => a + w.sets.length);

    return Scaffold(
      body: GradientBackground(
        child: _body(
          context,
          theme,
          c,
          t,
          dp,
          wp,
          workouts,
          pts,
          info,
          totalSets,
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    ThemeProvider theme,
    AppColors c,
    dynamic t,
    DisciplineProvider dp,
    WorkoutProvider wp,
    List workouts,
    int pts,
    RankInfo info,
    int totalSets,
  ) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: ShaderMask(
          shaderCallback: (r) =>
              LinearGradient(colors: [c.primary, c.text]).createShader(r),
          child: const Text(
            'CaliStrack',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) {
              FeedbackService.selection();
              if (v == 'store') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StoreScreen()),
                );
              } else if (v == 'timer') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TimerScreen()),
                );
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'store', child: Text(t('neon_store'))),
              PopupMenuItem(value: 'timer', child: Text(t('timer'))),
            ],
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton.extended(
            backgroundColor: c.primary,
            foregroundColor: theme.skin.isDark ? Colors.black : Colors.white,
            onPressed: () {
              FeedbackService.onTap();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NewWorkoutScreen()),
              );
            },
            icon: const Icon(Icons.add, size: 26),
            label: Text(
              t('new_workout'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ).animate().scale(
            duration: 400.ms,
            curve: Curves.easeOutBack,
            begin: const Offset(0.6, 0.6),
          ),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          const DisciplineSwitch(),
          const SizedBox(height: Spacing.sm),
          _RankCard(info: info, points: pts)
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, curve: Curves.easeOut),
          const SizedBox(height: Spacing.md),
          Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      label: t('workouts'),
                      animatedValue: workouts.length,
                      icon: Icons.event_available,
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: _StatBox(
                      label: t('total_sets'),
                      animatedValue: totalSets,
                      icon: Icons.repeat,
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: PressableScale(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TimerScreen()),
                      ),
                      child: _StatBox(
                        label: t('timer'),
                        icon: Icons.timer_outlined,
                      ),
                    ),
                  ),
                ],
              )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideY(begin: 0.1),
          const SizedBox(height: Spacing.md),
          if (workouts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.fitness_center, size: 56, color: c.textMuted)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scaleXY(
                        end: 1.1,
                        duration: 1200.ms,
                        curve: Curves.easeInOut,
                      ),
                  const SizedBox(height: Spacing.md),
                  Text(
                    t('no_workouts'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: c.textMuted),
                  ),
                ],
              ),
            )
          else
            ResponsiveWrap(
              minTileWidth: 340,
              maxColumns: 2,
              children: workouts.asMap().entries.map((entry) {
                final i = entry.key;
                final w = entry.value;
                return GlowCard(
                      padding: EdgeInsets.zero,
                      radius: Radii.md,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkoutDetailScreen(id: w.id),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.md,
                          vertical: 4,
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: c.primary.withValues(alpha: 0.15),
                            child: Icon(
                              dp.discipline == 'gym'
                                  ? Icons.fitness_center
                                  : Icons.sports_gymnastics,
                              color: c.primary,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            formatDate(w.date),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            workoutSummary(w),
                            style: TextStyle(color: c.textMuted),
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: c.textMuted,
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: (60 * i).ms, duration: 350.ms)
                    .slideX(begin: 0.08, curve: Curves.easeOut);
              }).toList(),
            ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}

class _RankCard extends StatelessWidget {
  final RankInfo info;
  final int points;
  const _RankCard({required this.info, required this.points});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final c = theme.colors;
    final t = context.watch<LocaleProvider>().t;
    final diff = info.next != null ? info.next!.min - points : 0;
    return GlowCard(
      glow: true,
      borderColor: info.current.color.withValues(alpha: 0.6),
      child: Row(
        children: [
          Hero(
            tag: 'rank-medal',
            child: Medal(rank: info.current, size: 68, progress: info.progress),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${t('level')} ${levelOf(info.current.id)}/$maxLevel',
                  style: TextStyle(color: c.textMuted, fontSize: 12),
                ),
                Text(
                  info.current.name,
                  style: TextStyle(
                    color: info.current.color,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Row(
                  children: [
                    AnimatedNumber(
                      value: points,
                      style: TextStyle(
                        color: c.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      format: (v) => '${fmtCompact(v.round())} pt',
                    ),
                    Flexible(
                      child: Text(
                        info.next != null
                            ? ' • ${fmtCompact(diff)} ${t.p('to_next', {'name': info.next!.name})}'
                            : ' • ${t('max')}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: c.textMuted, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: info.progress),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, _) => LinearProgressIndicator(
                      value: v,
                      minHeight: 6,
                      backgroundColor: c.cardAlt,
                      valueColor: AlwaysStoppedAnimation(info.current.color),
                    ),
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

class _StatBox extends StatelessWidget {
  final String label;
  final int? animatedValue;
  final IconData? icon;
  const _StatBox({required this.label, this.animatedValue, this.icon});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Spacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.cardAlt, c.card],
        ),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          if (animatedValue != null)
            AnimatedNumber(
              value: animatedValue!,
              style: TextStyle(
                color: c.primary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            )
          else if (icon != null)
            Icon(icon, color: c.primary, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: c.textMuted, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
