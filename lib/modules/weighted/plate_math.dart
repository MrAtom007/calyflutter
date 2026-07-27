import 'dart:ui' show Color;

/// Modalità di caricamento dei dischi.
enum LoadMode {
  /// Zavorra su cintura/dip belt: i dischi si impilano tutti sullo stesso lato.
  belt,

  /// Bilanciere: i dischi si distribuiscono in modo simmetrico sui due lati.
  barbell,
}

/// Esito del calcolo dischi per un peso target.
class PlateResult {
  /// Peso aggiuntivo richiesto (zavorra o carico sul bilanciere, barra esclusa).
  final double target;

  /// Peso aggiuntivo effettivamente ottenibile con i dischi disponibili.
  final double achieved;

  /// Dischi da montare. In modalità [LoadMode.barbell] è la lista **per lato**,
  /// in modalità [LoadMode.belt] è lo stack completo. Ordinati dal più pesante.
  final List<double> plates;

  /// Modalità usata per il calcolo.
  final LoadMode mode;

  /// Peso della barra (solo per [LoadMode.barbell]).
  final double barWeight;

  const PlateResult({
    required this.target,
    required this.achieved,
    required this.plates,
    required this.mode,
    this.barWeight = 0,
  });

  /// Differenza tra target e ottenuto (>= 0). Se > 0 il peso esatto non è
  /// raggiungibile con i dischi disponibili.
  double get leftover => (target - achieved).clamp(0, double.infinity);

  /// True se il peso richiesto è stato raggiunto esattamente.
  bool get isExact => leftover < 0.001;

  /// True se non è stato possibile montare alcun disco.
  bool get isEmpty => plates.isEmpty;

  /// Peso totale sul sistema, barra inclusa (utile per il bilanciere).
  double get totalSystemWeight =>
      mode == LoadMode.barbell ? barWeight + achieved : achieved;
}

/// Calcolatore di dischi con decomposizione greedy sui tagli disponibili.
class PlateMath {
  /// Tagli disponibili di default (kg), dal più pesante al più leggero.
  static const List<double> defaultPlatesKg = [
    25, 20, 15, 10, 5, 2.5, 1.25,
  ];

  /// Tagli disponibili di default (lb).
  static const List<double> defaultPlatesLb = [
    45, 35, 25, 10, 5, 2.5,
  ];

  /// Peso barra olimpica standard.
  static const double olympicBarKg = 20;
  static const double olympicBarLb = 45;

  /// Tolleranza per i confronti in virgola mobile.
  static const double _eps = 1e-6;

  /// Calcola i dischi necessari per ottenere [target] kg di peso aggiuntivo.
  ///
  /// - [available]: tagli disponibili (verranno ordinati decrescenti).
  /// - [mode]: cintura (stack unico) o bilanciere (simmetrico sui due lati).
  /// - [barWeight]: peso della barra, sottratto dal target in modalità bilanciere.
  static PlateResult compute({
    required double target,
    required List<double> available,
    LoadMode mode = LoadMode.belt,
    double barWeight = 0,
  }) {
    final sorted = [...available.where((p) => p > _eps)]
      ..sort((a, b) => b.compareTo(a));

    if (mode == LoadMode.belt) {
      final plates = _greedy(target, sorted);
      final achieved = plates.fold<double>(0, (s, p) => s + p);
      return PlateResult(
        target: target,
        achieved: achieved,
        plates: plates,
        mode: mode,
      );
    }

    // Bilanciere: distribuisci il carico (target - barra) sui due lati.
    final loadable = target - barWeight;
    if (loadable <= _eps) {
      return PlateResult(
        target: target,
        achieved: 0,
        plates: const [],
        mode: mode,
        barWeight: barWeight,
      );
    }
    final perSideTarget = loadable / 2;
    final perSide = _greedy(perSideTarget, sorted);
    final perSideWeight = perSide.fold<double>(0, (s, p) => s + p);
    return PlateResult(
      target: target,
      achieved: perSideWeight * 2,
      plates: perSide,
      mode: mode,
      barWeight: barWeight,
    );
  }

  /// Decomposizione greedy: monta i dischi più pesanti finché rientrano.
  static List<double> _greedy(double amount, List<double> sortedDesc) {
    final out = <double>[];
    var remaining = amount;
    for (final p in sortedDesc) {
      while (remaining >= p - _eps) {
        out.add(p);
        remaining -= p;
      }
    }
    return out;
  }

  /// Carico totale relativo: peso corporeo + zavorra.
  static double effectiveLoad({
    required double bodyWeight,
    required double addedWeight,
  }) =>
      bodyWeight + addedWeight;

  /// Percentuale di zavorra rispetto al peso corporeo (es. +50% BW).
  static double addedPercentOfBody({
    required double bodyWeight,
    required double addedWeight,
  }) =>
      bodyWeight <= _eps ? 0 : (addedWeight / bodyWeight) * 100;

  /// Colore convenzionale per un disco, in base all'unità.
  static Color colorFor(double v, String unit) =>
      unit == 'lb' ? colorForLb(v) : colorForKg(v);

  /// Colori standard (stile calibrati lb) per i dischi in libbre.
  static Color colorForLb(double lb) {
    if ((lb - 45).abs() < 0.01) return const Color(0xFF1E88E5); // blu
    if ((lb - 35).abs() < 0.01) return const Color(0xFFFDD835); // giallo
    if ((lb - 25).abs() < 0.01) return const Color(0xFF43A047); // verde
    if ((lb - 10).abs() < 0.01) return const Color(0xFFECEFF1); // bianco
    if ((lb - 5).abs() < 0.01) return const Color(0xFF546E7A);
    if ((lb - 2.5).abs() < 0.01) return const Color(0xFF90A4AE);
    return const Color(0xFF78909C);
  }

  /// Colore convenzionale (stile IPF) per un disco di un dato peso in kg.
  static Color colorForKg(double kg) {
    if ((kg - 25).abs() < 0.01) return const Color(0xFFE53935); // rosso
    if ((kg - 20).abs() < 0.01) return const Color(0xFF1E88E5); // blu
    if ((kg - 15).abs() < 0.01) return const Color(0xFFFDD835); // giallo
    if ((kg - 10).abs() < 0.01) return const Color(0xFF43A047); // verde
    if ((kg - 5).abs() < 0.01) return const Color(0xFFECEFF1); // bianco
    if ((kg - 2.5).abs() < 0.01) return const Color(0xFF546E7A); // grigio scuro
    if ((kg - 1.25).abs() < 0.01) return const Color(0xFF90A4AE); // argento
    if ((kg - 0.5).abs() < 0.01) return const Color(0xFFB0BEC5);
    return const Color(0xFF78909C);
  }

  /// Raggruppa una lista di dischi in coppie (peso, quantità) preservando
  /// l'ordine decrescente.
  static List<({double weight, int count})> group(List<double> plates) {
    final out = <({double weight, int count})>[];
    for (final p in plates) {
      if (out.isNotEmpty && (out.last.weight - p).abs() < _eps) {
        final last = out.removeLast();
        out.add((weight: last.weight, count: last.count + 1));
      } else {
        out.add((weight: p, count: 1));
      }
    }
    return out;
  }
}
