import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/theme_provider.dart';
import '../state/locale_provider.dart';
import '../state/health_provider.dart';
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
    final t = context.watch<LocaleProvider>().t;
    final widgets = <Widget>[];

    // Heart rate hero con sinusoide grande.
    final hr = health.series(HealthMetric.heartRate);
    if (hr != null) {
      final bpm = hr.latest ?? hr.avg ?? 70;
      widgets.add(_HeroHeart(series: hr, bpm: bpm));
      widgets.add(SizedBox(height: gap));
    }

    // Pressione (doppia linea).
    final bp0 = health.series(HealthMetric.bloodPressure);
    final bp = bp0 == null
        ? null
        : MetricSeries(
            metric: bp0.metric, today: bp0.today, daily: _sliced(bp0.daily));
    if (bp != null && bp.daily.length > 1) {
      widgets.add(SurfaceCard(
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
      ));
      widgets.add(SizedBox(height: gap));
    }

    // Griglia metriche restanti.
    final grid = <HealthMetric>[
      HealthMetric.restingHeartRate,
      HealthMetric.hrv,
      HealthMetric.spo2,
      HealthMetric.steps,
      HealthMetric.calories,
      HealthMetric.sleep,
    ];
    final tiles = <Widget>[];
    for (final m in grid) {
      final s = health.series(m);
      if (s == null) continue;
      final sliced = MetricSeries(
          metric: s.metric, today: s.today, daily: _sliced(s.daily));
      tiles.add(_MetricCard(series: sliced));
    }
    if (tiles.isNotEmpty) {
      widgets.add(SectionHeader(
          title: t('health_metrics').toUpperCase(),
          icon: Icons.dashboard_rounded));
      widgets.add(LayoutBuilder(builder: (context, cns) {
        final w = (cns.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [for (final tile in tiles) SizedBox(width: w, child: tile)],
        );
      }));
    }
    return widgets;
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
              if (health.demoMode)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: c.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(Radii.sm),
                  ),
                  child: Text('DEMO',
                      style: TextStyle(
                          color: c.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800)),
                ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          // Google
          if (health.googleSignedIn)
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
          Row(
            children: [
              Expanded(
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
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    FeedbackService.onTap();
                    health.enableDemo();
                  },
                  icon: const Icon(Icons.play_circle_outline_rounded),
                  label: Text(t('health_try_demo')),
                ),
              ),
            ],
          ),
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
