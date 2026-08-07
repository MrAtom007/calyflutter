import 'package:flutter/material.dart';

/// Metriche di salute supportate dalla sezione Salute.
enum HealthMetric {
  heartRate,
  restingHeartRate,
  hrv,
  bloodPressure,
  spo2,
  steps,
  calories,
  sleep,
}

extension HealthMetricInfo on HealthMetric {
  String get key => name;

  /// Chiave di localizzazione del titolo.
  String get titleKey => switch (this) {
    HealthMetric.heartRate => 'hm_heart_rate',
    HealthMetric.restingHeartRate => 'hm_resting_hr',
    HealthMetric.hrv => 'hm_hrv',
    HealthMetric.bloodPressure => 'hm_blood_pressure',
    HealthMetric.spo2 => 'hm_spo2',
    HealthMetric.steps => 'hm_steps',
    HealthMetric.calories => 'hm_calories',
    HealthMetric.sleep => 'hm_sleep',
  };

  String get unit => switch (this) {
    HealthMetric.heartRate => 'bpm',
    HealthMetric.restingHeartRate => 'bpm',
    HealthMetric.hrv => 'ms',
    HealthMetric.bloodPressure => 'mmHg',
    HealthMetric.spo2 => '%',
    HealthMetric.steps => '',
    HealthMetric.calories => 'kcal',
    HealthMetric.sleep => 'h',
  };

  IconData get icon => switch (this) {
    HealthMetric.heartRate => Icons.favorite_rounded,
    HealthMetric.restingHeartRate => Icons.spa_rounded,
    HealthMetric.hrv => Icons.graphic_eq_rounded,
    HealthMetric.bloodPressure => Icons.bloodtype_rounded,
    HealthMetric.spo2 => Icons.air_rounded,
    HealthMetric.steps => Icons.directions_walk_rounded,
    HealthMetric.calories => Icons.local_fire_department_rounded,
    HealthMetric.sleep => Icons.bedtime_rounded,
  };

  /// Colore di accento coerente per ogni metrica.
  Color get accent => switch (this) {
    HealthMetric.heartRate => const Color(0xffff2e63),
    HealthMetric.restingHeartRate => const Color(0xffff6b9d),
    HealthMetric.hrv => const Color(0xff7c5cff),
    HealthMetric.bloodPressure => const Color(0xffff5252),
    HealthMetric.spo2 => const Color(0xff2ee6d6),
    HealthMetric.steps => const Color(0xff38bdf8),
    HealthMetric.calories => const Color(0xffff9f1c),
    HealthMetric.sleep => const Color(0xff9d4bff),
  };
}

/// Un singolo campione temporale (istantaneo o giornaliero).
class HealthSample {
  final DateTime time;
  final double value;

  /// Valore secondario (es. diastolica per la pressione).
  final double? value2;

  const HealthSample(this.time, this.value, {this.value2});

  Map<String, dynamic> toJson() => {
    't': time.toIso8601String(),
    'v': value,
    if (value2 != null) 'v2': value2,
  };

  factory HealthSample.fromJson(Map<String, dynamic> j) => HealthSample(
    DateTime.parse(j['t'] as String),
    (j['v'] as num).toDouble(),
    value2: (j['v2'] as num?)?.toDouble(),
  );
}

/// Serie completa di una metrica: campioni intraday + storico giornaliero.
class MetricSeries {
  final HealthMetric metric;

  /// Campioni ad alta frequenza della giornata odierna (per le sinusoidi).
  final List<HealthSample> today;

  /// Aggregati/rappresentativi degli ultimi giorni (per i grafici trend).
  final List<HealthSample> daily;

  const MetricSeries({
    required this.metric,
    required this.today,
    required this.daily,
  });

  /// Ultimo valore noto della metrica.
  double? get latest => today.isNotEmpty
      ? today.last.value
      : (daily.isNotEmpty ? daily.last.value : null);

  double? get latest2 => today.isNotEmpty
      ? today.last.value2
      : (daily.isNotEmpty ? daily.last.value2 : null);

  double? get avg {
    final src = today.isNotEmpty ? today : daily;
    if (src.isEmpty) return null;
    return src.map((e) => e.value).reduce((a, b) => a + b) / src.length;
  }

  double? get min {
    final src = today.isNotEmpty ? today : daily;
    if (src.isEmpty) return null;
    return src.map((e) => e.value).reduce((a, b) => a < b ? a : b);
  }

  double? get max {
    final src = today.isNotEmpty ? today : daily;
    if (src.isEmpty) return null;
    return src.map((e) => e.value).reduce((a, b) => a > b ? a : b);
  }

  Map<String, dynamic> toJson() => {
    'm': metric.name,
    'today': today.map((e) => e.toJson()).toList(),
    'daily': daily.map((e) => e.toJson()).toList(),
  };

  factory MetricSeries.fromJson(Map<String, dynamic> j) => MetricSeries(
    metric: HealthMetric.values.firstWhere((e) => e.name == j['m']),
    today: (j['today'] as List)
        .map((e) => HealthSample.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    daily: (j['daily'] as List)
        .map((e) => HealthSample.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
}

/// Fonte dei dati di salute mostrati.
enum HealthSource { none, healthConnect, appleHealth, demo }

/// Snapshot completo dei dati di salute.
class HealthSnapshot {
  final Map<HealthMetric, MetricSeries> series;
  final HealthSource source;
  final DateTime updatedAt;

  /// Dispositivi/app rilevati come sorgente dei dati (es. "Mi Fitness",
  /// "Samsung Health", "Zepp Life"). Utile per farne scegliere/filtrare uno.
  final List<String> sources;

  /// Sorgente attualmente selezionata (nome dispositivo/app) oppure null =
  /// "tutte le sorgenti".
  final String? selectedSource;

  const HealthSnapshot({
    required this.series,
    required this.source,
    required this.updatedAt,
    this.sources = const [],
    this.selectedSource,
  });

  MetricSeries? of(HealthMetric m) => series[m];

  Map<String, dynamic> toJson() => {
    'source': source.name,
    'updatedAt': updatedAt.toIso8601String(),
    'series': series.values.map((e) => e.toJson()).toList(),
    'sources': sources,
    if (selectedSource != null) 'selectedSource': selectedSource,
  };

  factory HealthSnapshot.fromJson(Map<String, dynamic> j) {
    final list = (j['series'] as List)
        .map((e) => MetricSeries.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return HealthSnapshot(
      source: HealthSource.values.firstWhere(
        (e) => e.name == j['source'],
        orElse: () => HealthSource.demo,
      ),
      updatedAt:
          DateTime.tryParse(j['updatedAt'] as String? ?? '') ?? DateTime.now(),
      series: {for (final s in list) s.metric: s},
      sources:
          (j['sources'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      selectedSource: j['selectedSource'] as String?,
    );
  }
}
