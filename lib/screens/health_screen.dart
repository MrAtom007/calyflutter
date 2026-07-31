import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/theme_provider.dart';
import '../state/locale_provider.dart';
import '../state/health_provider.dart';
import '../state/health_layout_provider.dart';
import '../models/health_data.dart';
import '../services/feedback_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_kit.dart';
import '../widgets/design_system.dart';
import '../widgets/health_charts.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  int _range = 7; // giorni mostrati nei grafici trend

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleProvider>().t;
    final health = context.watch<HealthProvider>();
    final scale = context.watch<ThemeProvider>().densityScale;
    final gap = Spacing.md * scale;

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(t('nav_health')),
          actions: [
            if (health.hasData)
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                tooltip: t('customize_widgets'),
                onPressed: () {
                  FeedbackService.onTap();
                  _openLayoutSheet(context);
                },
              ),
            if (health.hasData)
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: t('health_sync'),
                onPressed: () {
                  FeedbackService.onTap();
                  health.sync();
                },
              ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(gap, gap, gap, gap * 4),
            children: [
              _ConnectCard(health: health),
              SizedBox(height: gap),
              const _GoalsCard(),
              SizedBox(height: gap),
              if (health.status == HealthStatus.loading && !health.hasData)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (health.hasData) ...[
                _rangeSelector(context),
                SizedBox(height: gap),
                ..._metrics(context, health, gap),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _rangeSelector(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    Widget seg(int days, String label) {
      final active = _range == days;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _range = days),
          child: Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: active ? c.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            child: Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: active
                        ? (c.bg.computeLuminance() > 0.5 ? Colors.white : Colors.black)
                        : c.textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.border),
      ),
      child: Row(children: [
        seg(7, '7 ${t('day_short')}'),
        seg(30, '30 ${t('day_short')}'),
      ]),
    );
  }

  List<HealthSample> _sliced(List<HealthSample> src) =>
      src.length > _range ? src.sublist(src.length - _range) : src;

  List<Widget> _metrics(BuildContext context, HealthProvider health, double gap) {
    final layout = context.watch<HealthLayoutProvider>();
    final widgets = <Widget>[];
    final pendingSmall = <Widget>[];

    // Svuota le metriche "piccole" accumulate in una griglia a 2 colonne.
    void flushSmall() {
      if (pendingSmall.isEmpty) return;
      final tiles = List<Widget>.of(pendingSmall);
      pendingSmall.clear();
      widgets.add(LayoutBuilder(builder: (context, cns) {
        final w = (cns.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [for (final tile in tiles) SizedBox(width: w, child: tile)],
        );
      }));
      widgets.add(SizedBox(height: gap));
    }

    for (final m in layout.enabled) {
      final s = health.series(m);
      if (s == null) continue;
      switch (m) {
        case HealthMetric.heartRate:
          flushSmall();
          final bpm = s.latest ?? s.avg ?? 70;
          widgets.add(_expandable(
              context, m, health, _HeroHeart(series: s, bpm: bpm)));
          widgets.add(SizedBox(height: gap));
          break;
        case HealthMetric.bloodPressure:
          final bp = MetricSeries(
              metric: s.metric, today: s.today, daily: _sliced(s.daily));
          if (bp.daily.length > 1) {
            flushSmall();
            widgets.add(_expandable(
                context, m, health, _bloodPressureCard(context, bp)));
            widgets.add(SizedBox(height: gap));
          }
          break;
        case HealthMetric.sleep:
          // Il sonno ha SEMPRE i consigli affiancati.
          flushSmall();
          final sleep = MetricSeries(
              metric: s.metric, today: s.today, daily: _sliced(s.daily));
          widgets.add(_expandable(context, m, health,
              _SleepCard(series: sleep, goalHours: health.goalSleep)));
          widgets.add(SizedBox(height: gap));
          break;
        default:
          final sliced = MetricSeries(
              metric: s.metric, today: s.today, daily: _sliced(s.daily));
          pendingSmall.add(
              _expandable(context, m, health, _MetricCard(series: sliced)));
      }
    }
    flushSmall();
    return widgets;
  }

  /// Rende una card cliccabile: al tap apre il dettaglio espanso della metrica.
  Widget _expandable(BuildContext context, HealthMetric m,
      HealthProvider health, Widget child) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FeedbackService.onTap();
        final full = health.series(m);
        if (full == null) return;
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) =>
              _MetricDetailSheet(series: full, goalSleep: health.goalSleep),
        );
      },
      child: child,
    );
  }

  Widget _bloodPressureCard(BuildContext context, MetricSeries bp) {
    final t = context.watch<LocaleProvider>().t;
    return SurfaceCard(
      accent: HealthMetric.bloodPressure.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
              title: t('hm_blood_pressure').toUpperCase(),
              icon: Icons.bloodtype_rounded),
          Row(children: [
            Text(
              '${bp.daily.last.value.round()}/${bp.daily.last.value2?.round() ?? '--'}',
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: HealthMetric.bloodPressure.accent),
            ),
            const SizedBox(width: 6),
            Text('mmHg',
                style: TextStyle(
                    color: context.watch<ThemeProvider>().colors.textMuted)),
          ]),
          const SizedBox(height: 8),
          DualLineChart(
            primary: bp.daily.map((e) => e.value).toList(),
            secondary: bp.daily.map((e) => e.value2 ?? 0).toList(),
            colorPrimary: HealthMetric.bloodPressure.accent,
            colorSecondary: HealthMetric.spo2.accent,
          ),
        ],
      ),
    );
  }

  void _openLayoutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LayoutSheet(),
    );
  }
}

// ---------------------------------------------------------------------------
class _GoalsCard extends StatelessWidget {
  const _GoalsCard();

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleProvider>().t;
    final health = context.watch<HealthProvider>();
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: t('goals').toUpperCase(), icon: Icons.flag_rounded),
          _row(context, HealthMetric.steps.icon, t('hm_steps'),
              health.goalSteps.round().toString(), HealthMetric.steps.accent,
              () => _edit(context, health, 'steps', health.goalSteps)),
          _row(context, HealthMetric.calories.icon, t('hm_calories'),
              '${health.goalCalories.round()} kcal', HealthMetric.calories.accent,
              () => _edit(context, health, 'calories', health.goalCalories)),
          _row(context, HealthMetric.sleep.icon, t('hm_sleep'),
              '${health.goalSleep.toStringAsFixed(1)} h', HealthMetric.sleep.accent,
              () => _edit(context, health, 'sleep', health.goalSleep)),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String label, String value,
      Color color, VoidCallback onTap) {
    final c = context.watch<ThemeProvider>().colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Expanded(child: Text(label)),
            Text(value,
                style: TextStyle(fontWeight: FontWeight.w800, color: c.text)),
            const SizedBox(width: 6),
            Icon(Icons.edit_rounded, size: 15, color: c.textMuted),
          ],
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context, HealthProvider health, String key,
      double current) async {
    final t = context.read<LocaleProvider>().t;
    final ctrl = TextEditingController(
        text: key == 'sleep' ? current.toStringAsFixed(1) : current.round().toString());
    final res = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('goals')),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: t('goals')),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          TextButton(
            onPressed: () {
              final v = double.tryParse(ctrl.text.replaceAll(',', '.'));
              Navigator.pop(ctx, v);
            },
            child: Text(t('save')),
          ),
        ],
      ),
    );
    if (res != null && res > 0) {
      switch (key) {
        case 'steps':
          await health.setGoals(steps: res);
          break;
        case 'calories':
          await health.setGoals(calories: res);
          break;
        case 'sleep':
          await health.setGoals(sleep: res);
          break;
      }
    }
  }
}

// ---------------------------------------------------------------------------
class _ConnectCard extends StatelessWidget {
  final HealthProvider health;
  const _ConnectCard({required this.health});

  /// Formatta l'ora dell'ultimo backup in modo compatto (gg/mm HH:mm).
  static String _formatBackup(DateTime? dt, String never) {
    if (dt == null) return never;
    final l = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(l.day)}/${two(l.month)} ${two(l.hour)}:${two(l.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    final sourceLabel = switch (health.source) {
      HealthSource.healthConnect => 'Health Connect',
      HealthSource.appleHealth => 'Apple Health',
      HealthSource.demo => t('health_demo'),
      HealthSource.none => t('health_not_connected'),
    };

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [c.primary, c.primaryDark]),
                  borderRadius: BorderRadius.circular(Radii.md),
                ),
                child: const Icon(Icons.monitor_heart_rounded,
                    color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t('health_title'),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                    Text(sourceLabel,
                        style: TextStyle(color: c.textMuted, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          // Google
          if (health.googleSignedIn)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: c.cardAlt,
                      backgroundImage: health.googlePhoto != null
                          ? NetworkImage(health.googlePhoto!)
                          : null,
                      child: health.googlePhoto == null
                          ? Icon(Icons.person, size: 16, color: c.textMuted)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(health.googleName ?? health.googleEmail ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    TextButton(
                        onPressed: () => health.signOutGoogle(),
                        child: Text(t('sign_out'))),
                  ],
                ),
                if (health.cloudSignedIn) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.cloud_done_rounded,
                          size: 15, color: c.textMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${t('last_backup')}: '
                          '${_formatBackup(health.lastCloudBackup, t('backup_never'))}',
                          style: TextStyle(fontSize: 12, color: c.textMuted),
                        ),
                      ),
                      if (health.cloudBusy)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        TextButton.icon(
                          onPressed: () async {
                            FeedbackService.onTap();
                            final messenger = ScaffoldMessenger.of(context);
                            final ok = await health.backupToCloud();
                            messenger.showSnackBar(SnackBar(
                                content: Text(ok
                                    ? t('backup_saved')
                                    : t('backup_failed'))));
                          },
                          icon: const Icon(Icons.backup_rounded, size: 16),
                          label: Text(t('backup_now')),
                        ),
                    ],
                  ),
                ],
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  FeedbackService.onTap();
                  final messenger = ScaffoldMessenger.of(context);
                  final ok = await health.signInGoogle();
                  if (!ok) {
                    messenger.showSnackBar(SnackBar(
                        content: Text(t('sign_in_failed'))));
                  }
                },
                icon: const Icon(Icons.account_circle_rounded),
                label: Text(t('sign_in_google')),
              ),
            ),
          const SizedBox(height: Spacing.sm),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: c.primary),
              onPressed: () async {
                FeedbackService.onTap();
                final ok = await health.connectHealthPlatform();
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(t('health_connect_failed'))));
                }
              },
              icon: const Icon(Icons.link_rounded),
              label: Text(t('health_connect')),
            ),
          ),
          // Selettore sorgente dispositivo/app (es. orologio Xiaomi).
          if (health.connected && health.availableSources.isNotEmpty) ...[
            const SizedBox(height: Spacing.sm),
            DropdownButtonFormField<String?>(
              initialValue: health.selectedSource,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: t('health_source'),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(t('all_sources')),
                ),
                for (final s in health.availableSources)
                  DropdownMenuItem<String?>(value: s, child: Text(s)),
              ],
              onChanged: (v) {
                FeedbackService.onTap();
                health.setSource(v);
              },
            ),
            const SizedBox(height: 4),
            Text(t('health_source_hint'),
                style: TextStyle(color: c.textMuted, fontSize: 11)),
          ],
          const SizedBox(height: 6),
          Text(t('health_hint'),
              style: TextStyle(color: c.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _HeroHeart extends StatelessWidget {
  final MetricSeries series;
  final double bpm;
  const _HeroHeart({required this.series, required this.bpm});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    final accent = HealthMetric.heartRate.accent;
    return SurfaceCard(
      accent: accent,
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(Icons.favorite_rounded, color: accent),
              const SizedBox(width: 8),
              Text(t('hm_heart_rate'),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(bpm.round().toString(),
                  style: TextStyle(
                      fontSize: 40,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      color: accent)),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('bpm', style: TextStyle(color: c.textMuted)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          HeartWave(color: accent, bpm: bpm, height: 110),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _mini(context, t('min'), series.min?.round().toString() ?? '--'),
              _mini(context, t('avg'), series.avg?.round().toString() ?? '--'),
              _mini(context, t('max'), series.max?.round().toString() ?? '--'),
            ],
          ),
          if (series.today.length > 3) ...[
            const SizedBox(height: 12),
            _HrZones(samples: series.today),
          ],
        ],
      ),
    );
  }

  Widget _mini(BuildContext context, String k, String v) {
    final c = context.watch<ThemeProvider>().colors;
    return Column(
      children: [
        Text(v,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        Text(k, style: TextStyle(fontSize: 11, color: c.textMuted)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
class _HrZones extends StatelessWidget {
  final List samples; // List<HealthSample>
  const _HrZones({required this.samples});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    // Soglie bpm: riposo <60, leggero 60-100, cardio 100-140, picco >140.
    final zones = [
      (t('hz_rest'), const Color(0xff38bdf8), 0),
      (t('hz_light'), const Color(0xff4cd964), 0),
      (t('hz_cardio'), const Color(0xffff9f1c), 0),
      (t('hz_peak'), const Color(0xffff2e63), 0),
    ];
    final counts = [0, 0, 0, 0];
    for (final s in samples) {
      final v = (s.value as num).toDouble();
      if (v < 60) {
        counts[0]++;
      } else if (v < 100) {
        counts[1]++;
      } else if (v < 140) {
        counts[2]++;
      } else {
        counts[3]++;
      }
    }
    final total = counts.fold<int>(0, (a, b) => a + b).clamp(1, 1 << 30);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Row(
            children: [
              for (int i = 0; i < 4; i++)
                if (counts[i] > 0)
                  Expanded(
                    flex: counts[i],
                    child: Container(height: 10, color: zones[i].$2),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            for (int i = 0; i < 4; i++)
              Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                        color: zones[i].$2, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text(
                    '${zones[i].$1} ${(counts[i] / total * 100).round()}%',
                    style: TextStyle(fontSize: 10.5, color: c.textMuted)),
              ]),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
class _MetricCard extends StatelessWidget {
  final MetricSeries series;
  const _MetricCard({required this.series});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    final m = series.metric;
    final accent = m.accent;
    final val = series.latest ?? series.daily.lastOrNull?.value;
    final display = val != null
        ? (m == HealthMetric.sleep
            ? '${val.floor()}h${((val % 1) * 60).round()}m'
            : (m == HealthMetric.steps
                ? val.round().toString()
                : val.round().toString()))
        : '--';
    final data = series.daily.map((e) => e.value).toList();
    return SurfaceCard(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(m.icon, size: 16, color: accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(t(m.titleKey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: c.textMuted)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(display,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: accent)),
              if (m.unit.isNotEmpty && m != HealthMetric.sleep) ...[
                const SizedBox(width: 3),
                Text(m.unit,
                    style: TextStyle(fontSize: 11, color: c.textMuted)),
              ],
            ],
          ),
          const SizedBox(height: 4),
          if (data.length > 1)
            Sparkline(values: data, color: accent, height: 40),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card Sonno: grafico + consigli SEMPRE affiancati per migliorare il riposo.
class _SleepCard extends StatelessWidget {
  final MetricSeries series;
  final double goalHours;
  const _SleepCard({required this.series, required this.goalHours});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    final accent = HealthMetric.sleep.accent;
    final last =
        series.daily.isNotEmpty ? series.daily.last.value : (series.avg ?? 0);
    final h = last.floor();
    final min = ((last % 1) * 60).round();
    final data = series.daily.map((e) => e.value).toList();
    final below = last < goalHours - 0.5;
    final tips = <String>[
      t('sleep_tip_schedule'),
      t('sleep_tip_screens'),
      t('sleep_tip_caffeine'),
      t('sleep_tip_dark'),
      t('sleep_tip_temp'),
    ];
    return SurfaceCard(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
              title: t('hm_sleep').toUpperCase(),
              icon: Icons.bedtime_rounded),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${h}h${min.toString().padLeft(2, '0')}m',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: accent)),
              const SizedBox(width: 8),
              Text('/ ${goalHours.toStringAsFixed(1)}h',
                  style: TextStyle(color: c.textMuted)),
            ],
          ),
          if (data.length > 1) ...[
            const SizedBox(height: 8),
            Sparkline(values: data, color: accent, height: 46),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.tips_and_updates_rounded, size: 16, color: accent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(t('sleep_tips_title'),
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ]),
                const SizedBox(height: 6),
                Text(below ? t('sleep_status_low') : t('sleep_status_good'),
                    style: TextStyle(fontSize: 12.5, color: c.text)),
                const SizedBox(height: 8),
                for (final tip in tips)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_outline_rounded,
                            size: 15, color: accent),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(tip,
                              style: TextStyle(
                                  fontSize: 12.5, color: c.textMuted)),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 2),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: accent,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    onPressed: () {
                      FeedbackService.onTap();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const _SleepGuideSheet(),
                      );
                    },
                    icon: const Icon(Icons.menu_book_rounded, size: 16),
                    label: Text(t('sleep_guide_open')),
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
// Guida estesa al sonno: aperta dai consigli della card Sonno.
class _SleepGuideSheet extends StatelessWidget {
  const _SleepGuideSheet();

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    final accent = HealthMetric.sleep.accent;
    final sections = <(IconData, String, String)>[
      (Icons.schedule_rounded, t('sg_routine_t'), t('sg_routine_b')),
      (Icons.nightlight_round, t('sg_env_t'), t('sg_env_b')),
      (Icons.restaurant_rounded, t('sg_food_t'), t('sg_food_b')),
      (Icons.directions_run_rounded, t('sg_move_t'), t('sg_move_b')),
      (Icons.self_improvement_rounded, t('sg_relax_t'), t('sg_relax_b')),
    ];
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      builder: (context, scroll) => Container(
        decoration: BoxDecoration(
          color: c.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: ListView(
          controller: scroll,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: c.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Icon(Icons.bedtime_rounded, color: accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(t('sleep_guide_title'),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800)),
              ),
            ]),
            const SizedBox(height: 6),
            Text(t('sleep_guide_intro'),
                style: TextStyle(fontSize: 13, color: c.textMuted)),
            const SizedBox(height: 16),
            for (final s in sections)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(s.$1, size: 18, color: accent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(s.$2,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    Text(s.$3,
                        style: TextStyle(
                            fontSize: 13, height: 1.4, color: c.text)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom sheet per aggiungere/rimuovere/riordinare i widget della schermata.
class _LayoutSheet extends StatelessWidget {
  const _LayoutSheet();

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    final layout = context.watch<HealthLayoutProvider>();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      builder: (context, scroll) => Container(
        decoration: BoxDecoration(
          color: c.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: c.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(t('customize_widgets'),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                ),
                TextButton.icon(
                  onPressed: () {
                    FeedbackService.onTap();
                    layout.reset();
                  },
                  icon: const Icon(Icons.restore_rounded, size: 18),
                  label: Text(t('reset_layout')),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(t('reorder_hint'),
                style: TextStyle(fontSize: 12, color: c.textMuted)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                controller: scroll,
                children: [
                  ReorderableListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    onReorder: layout.reorder,
                    children: [
                      for (final m in layout.enabled)
                        Card(
                          key: ValueKey(m),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(m.icon, color: m.accent),
                            title: Text(t(m.titleKey)),
                            trailing: IconButton(
                              icon: Icon(Icons.remove_circle_outline_rounded,
                                  color: c.textMuted),
                              tooltip: t('remove_widget'),
                              onPressed: () {
                                FeedbackService.onTap();
                                layout.remove(m);
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (layout.available.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(t('add_widget').toUpperCase(),
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: c.textMuted)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final m in layout.available)
                          ActionChip(
                            avatar: Icon(m.icon, size: 18, color: m.accent),
                            label: Text(t(m.titleKey)),
                            onPressed: () {
                              FeedbackService.onTap();
                              layout.add(m);
                            },
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dettaglio espanso di una metrica (aperto al tap su una card).
class _MetricDetailSheet extends StatelessWidget {
  final MetricSeries series;
  final double goalSleep;
  const _MetricDetailSheet({required this.series, required this.goalSleep});

  String _fmt(double? v) {
    if (v == null) return '--';
    if (series.metric == HealthMetric.sleep) {
      final min = ((v % 1) * 60).round().toString().padLeft(2, '0');
      return '${v.floor()}h${min}m';
    }
    return v.round().toString();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    final m = series.metric;
    final accent = m.accent;
    final daily = series.daily.map((e) => e.value).toList();
    final isBp = m == HealthMetric.bloodPressure;

    final headline = isBp
        ? '${_fmt(series.latest)}/${series.latest2?.round() ?? '--'}'
        : _fmt(series.latest ?? series.avg);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      maxChildSize: 0.96,
      builder: (context, scroll) => Container(
        decoration: BoxDecoration(
          color: c.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: ListView(
          controller: scroll,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: c.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(Radii.md)),
                child: Icon(m.icon, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(t(m.titleKey),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              Text(headline,
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: accent)),
              if (m.unit.isNotEmpty && m != HealthMetric.sleep) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(m.unit,
                      style: TextStyle(color: c.textMuted, fontSize: 12)),
                ),
              ],
            ]),
            const SizedBox(height: 18),
            // Grafico grande.
            if (isBp && series.daily.length > 1)
              DualLineChart(
                primary: series.daily.map((e) => e.value).toList(),
                secondary: series.daily.map((e) => e.value2 ?? 0).toList(),
                colorPrimary: accent,
                colorSecondary: HealthMetric.spo2.accent,
              )
            else if (m == HealthMetric.heartRate && series.today.length > 1)
              HeartWave(
                  color: accent,
                  bpm: series.latest ?? series.avg ?? 70,
                  height: 130)
            else if (daily.length > 1)
              Sparkline(values: daily, color: accent, height: 120),
            const SizedBox(height: 18),
            // Statistiche.
            Row(
              children: [
                _stat(context, t('stat_latest'), _fmt(series.latest), accent),
                _stat(context, t('avg'), _fmt(series.avg), accent),
                _stat(context, t('min'), _fmt(series.min), accent),
                _stat(context, t('stat_max'), _fmt(series.max), accent),
              ],
            ),
            if (m == HealthMetric.heartRate && series.today.isNotEmpty) ...[
              const SizedBox(height: 20),
              SectionHeader(
                  title: t('hr_zones').toUpperCase(),
                  icon: Icons.stacked_line_chart_rounded),
              _HrZones(samples: series.today),
            ],
            if (m == HealthMetric.sleep) ...[
              const SizedBox(height: 20),
              SectionHeader(
                  title: t('sleep_tips_title').toUpperCase(),
                  icon: Icons.tips_and_updates_rounded),
              for (final tip in [
                t('sleep_tip_schedule'),
                t('sleep_tip_screens'),
                t('sleep_tip_caffeine'),
                t('sleep_tip_dark'),
                t('sleep_tip_temp'),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline_rounded,
                          size: 15, color: accent),
                      const SizedBox(width: 6),
                      Expanded(
                          child: Text(tip,
                              style: TextStyle(
                                  fontSize: 12.5, color: c.textMuted))),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: accent),
                onPressed: () {
                  FeedbackService.onTap();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const _SleepGuideSheet(),
                  );
                },
                icon: const Icon(Icons.menu_book_rounded, size: 18),
                label: Text(t('sleep_guide_open')),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stat(
      BuildContext context, String label, String value, Color accent) {
    final c = context.watch<ThemeProvider>().colors;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: c.border),
        ),
        child: Column(
          children: [
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800, color: accent)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(fontSize: 10.5, color: c.textMuted)),
          ],
        ),
      ),
    );
  }
}
