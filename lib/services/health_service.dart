import 'dart:io' show Platform;
import 'dart:math';

import 'package:health/health.dart';

import '../models/health_data.dart';

/// Servizio che collega la sezione Salute a Health Connect (Android) /
/// Apple HealthKit (iOS) tramite il pacchetto `health`, con fallback su un
/// motore demo che genera dati realistici e spettacolari.
class HealthService {
  static final Health _health = Health();
  static bool _configured = false;

  /// Tipi letti dal sistema salute.
  static const List<HealthDataType> _types = [
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.SLEEP_ASLEEP,
  ];

  static Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  /// Vero se sul dispositivo esiste una piattaforma salute disponibile.
  static Future<bool> isAvailable() async {
    try {
      await _ensureConfigured();
      if (Platform.isAndroid) {
        final status = await _health.getHealthConnectSdkStatus();
        return status == HealthConnectSdkStatus.sdkAvailable;
      }
      return Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  /// Prova ad aprire l'installazione di Health Connect (solo Android).
  static Future<void> installHealthConnect() async {
    try {
      await _ensureConfigured();
      if (Platform.isAndroid) await _health.installHealthConnect();
    } catch (_) {}
  }

  /// Richiede i permessi di lettura all'utente.
  static Future<bool> requestPermissions() async {
    try {
      await _ensureConfigured();
      final granted = await _health.requestAuthorization(_types);
      return granted;
    } catch (_) {
      return false;
    }
  }

  static HealthSource get _platformSource =>
      Platform.isIOS ? HealthSource.appleHealth : HealthSource.healthConnect;

  /// Legge i dati reali dal sistema salute. Ritorna `null` se non ci sono
  /// dati sufficienti (in tal caso il chiamante userà i dati demo).
  static Future<HealthSnapshot?> fetchReal() async {
    try {
      await _ensureConfigured();
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final todayStart = DateTime(now.year, now.month, now.day);

      final points = await _health.getHealthDataFromTypes(
        types: _types,
        startTime: weekAgo,
        endTime: now,
      );
      if (points.isEmpty) return null;

      double? num(HealthDataPoint p) =>
          p.value is NumericHealthValue
              ? (p.value as NumericHealthValue).numericValue.toDouble()
              : null;

      List<HealthDataPoint> byType(HealthDataType t) =>
          points.where((p) => p.type == t).toList()
            ..sort((a, b) => a.dateFrom.compareTo(b.dateFrom));

      final series = <HealthMetric, MetricSeries>{};

      // Heart rate intraday + daily avg.
      final hr = byType(HealthDataType.HEART_RATE);
      if (hr.isNotEmpty) {
        final today = <HealthSample>[];
        for (final p in hr) {
          final v = num(p);
          if (v != null && p.dateFrom.isAfter(todayStart)) {
            today.add(HealthSample(p.dateFrom, v));
          }
        }
        series[HealthMetric.heartRate] = MetricSeries(
          metric: HealthMetric.heartRate,
          today: today,
          daily: _dailyAvg(hr, num),
        );
      }

      // Metriche giornaliere semplici.
      void simpleDaily(HealthMetric m, HealthDataType t) {
        final pts = byType(t);
        if (pts.isEmpty) return;
        final today = [
          for (final p in pts)
            if (num(p) != null && p.dateFrom.isAfter(todayStart))
              HealthSample(p.dateFrom, num(p)!)
        ];
        series[m] = MetricSeries(metric: m, today: today, daily: _dailyAvg(pts, num));
      }

      simpleDaily(HealthMetric.restingHeartRate, HealthDataType.RESTING_HEART_RATE);
      simpleDaily(HealthMetric.hrv, HealthDataType.HEART_RATE_VARIABILITY_RMSSD);
      simpleDaily(HealthMetric.spo2, HealthDataType.BLOOD_OXYGEN);

      // Passi e calorie: somma giornaliera.
      void dailySum(HealthMetric m, HealthDataType t) {
        final pts = byType(t);
        if (pts.isEmpty) return;
        series[m] = MetricSeries(metric: m, today: const [], daily: _dailySum(pts, num));
      }

      dailySum(HealthMetric.steps, HealthDataType.STEPS);
      dailySum(HealthMetric.calories, HealthDataType.ACTIVE_ENERGY_BURNED);

      // Pressione: accoppia sistolica/diastolica per giorno.
      final sys = byType(HealthDataType.BLOOD_PRESSURE_SYSTOLIC);
      final dia = byType(HealthDataType.BLOOD_PRESSURE_DIASTOLIC);
      if (sys.isNotEmpty) {
        final daily = <HealthSample>[];
        for (final s in sys) {
          final sv = num(s);
          if (sv == null) continue;
          HealthDataPoint? match;
          for (final d in dia) {
            if (d.dateFrom.difference(s.dateFrom).abs() <
                const Duration(minutes: 5)) {
              match = d;
              break;
            }
          }
          daily.add(HealthSample(s.dateFrom, sv, value2: match != null ? num(match) : null));
        }
        series[HealthMetric.bloodPressure] = MetricSeries(
          metric: HealthMetric.bloodPressure,
          today: const [],
          daily: daily,
        );
      }

      // Sonno: durata per notte in ore.
      final sleep = byType(HealthDataType.SLEEP_ASLEEP);
      if (sleep.isNotEmpty) {
        final byDay = <String, double>{};
        for (final p in sleep) {
          final mins = p.dateTo.difference(p.dateFrom).inMinutes.toDouble();
          final k = '${p.dateFrom.year}-${p.dateFrom.month}-${p.dateFrom.day}';
          byDay[k] = (byDay[k] ?? 0) + mins;
        }
        final daily = [
          for (final e in byDay.entries)
            HealthSample(DateTime.parse(e.key.replaceAllMapped(
                RegExp(r'(\d+)-(\d+)-(\d+)'),
                (m) => '${m[1]}-${m[2]!.padLeft(2, '0')}-${m[3]!.padLeft(2, '0')}')),
                e.value / 60.0)
        ]..sort((a, b) => a.time.compareTo(b.time));
        series[HealthMetric.sleep] =
            MetricSeries(metric: HealthMetric.sleep, today: const [], daily: daily);
      }

      if (series.isEmpty) return null;
      return HealthSnapshot(
        series: series,
        source: _platformSource,
        updatedAt: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  static List<HealthSample> _dailyAvg(
      List<HealthDataPoint> pts, double? Function(HealthDataPoint) num) {
    final byDay = <String, List<double>>{};
    for (final p in pts) {
      final v = num(p);
      if (v == null) continue;
      final k = '${p.dateFrom.year}-${p.dateFrom.month}-${p.dateFrom.day}';
      (byDay[k] ??= []).add(v);
    }
    final out = <HealthSample>[];
    byDay.forEach((k, vals) {
      final parts = k.split('-').map(int.parse).toList();
      out.add(HealthSample(DateTime(parts[0], parts[1], parts[2]),
          vals.reduce((a, b) => a + b) / vals.length));
    });
    out.sort((a, b) => a.time.compareTo(b.time));
    return out;
  }

  static List<HealthSample> _dailySum(
      List<HealthDataPoint> pts, double? Function(HealthDataPoint) num) {
    final byDay = <String, double>{};
    for (final p in pts) {
      final v = num(p);
      if (v == null) continue;
      final k = '${p.dateFrom.year}-${p.dateFrom.month}-${p.dateFrom.day}';
      byDay[k] = (byDay[k] ?? 0) + v;
    }
    final out = <HealthSample>[];
    byDay.forEach((k, sum) {
      final parts = k.split('-').map(int.parse).toList();
      out.add(HealthSample(DateTime(parts[0], parts[1], parts[2]), sum));
    });
    out.sort((a, b) => a.time.compareTo(b.time));
    return out;
  }

  // ---------------------------------------------------------------------------
  // Motore DEMO: genera dati realistici così la UI è sempre spettacolare.
  // ---------------------------------------------------------------------------
  static HealthSnapshot demoSnapshot({int? seed}) {
    final rnd = Random(seed ?? DateTime.now().day);
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final series = <HealthMetric, MetricSeries>{};

    // Heart rate intraday: 120 campioni (ogni ~12 min) con oscillazione.
    final hrToday = <HealthSample>[];
    for (int i = 0; i < 120; i++) {
      final t = todayStart.add(Duration(minutes: i * 12));
      if (t.isAfter(now)) break;
      final base = 62 +
          14 * sin(i / 10) +
          8 * sin(i / 3.3) +
          (rnd.nextDouble() - 0.5) * 6;
      hrToday.add(HealthSample(t, base.clamp(48, 165).toDouble()));
    }
    series[HealthMetric.heartRate] = MetricSeries(
      metric: HealthMetric.heartRate,
      today: hrToday,
      daily: _demoDaily(7, () => 66 + rnd.nextInt(10).toDouble()),
    );

    series[HealthMetric.restingHeartRate] = MetricSeries(
      metric: HealthMetric.restingHeartRate,
      today: const [],
      daily: _demoDaily(7, () => 54 + rnd.nextInt(8).toDouble()),
    );

    series[HealthMetric.hrv] = MetricSeries(
      metric: HealthMetric.hrv,
      today: const [],
      daily: _demoDaily(7, () => 45 + rnd.nextInt(40).toDouble()),
    );

    series[HealthMetric.spo2] = MetricSeries(
      metric: HealthMetric.spo2,
      today: const [],
      daily: _demoDaily(7, () => 96 + rnd.nextInt(4).toDouble()),
    );

    series[HealthMetric.steps] = MetricSeries(
      metric: HealthMetric.steps,
      today: const [],
      daily: _demoDaily(7, () => 4200 + rnd.nextInt(9000).toDouble()),
    );

    series[HealthMetric.calories] = MetricSeries(
      metric: HealthMetric.calories,
      today: const [],
      daily: _demoDaily(7, () => 320 + rnd.nextInt(680).toDouble()),
    );

    series[HealthMetric.sleep] = MetricSeries(
      metric: HealthMetric.sleep,
      today: const [],
      daily: _demoDaily(7, () => 5.5 + rnd.nextDouble() * 3),
    );

    // Pressione: sistolica/diastolica correlate.
    final bp = <HealthSample>[];
    for (int i = 6; i >= 0; i--) {
      final day = todayStart.subtract(Duration(days: i));
      final s = 115 + rnd.nextInt(18).toDouble();
      final d = 72 + rnd.nextInt(12).toDouble();
      bp.add(HealthSample(day, s, value2: d));
    }
    series[HealthMetric.bloodPressure] = MetricSeries(
      metric: HealthMetric.bloodPressure,
      today: const [],
      daily: bp,
    );

    return HealthSnapshot(
      series: series,
      source: HealthSource.demo,
      updatedAt: DateTime.now(),
    );
  }

  static List<HealthSample> _demoDaily(int days, double Function() gen) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return [
      for (int i = days - 1; i >= 0; i--)
        HealthSample(start.subtract(Duration(days: i)), gen())
    ];
  }
}
