import 'dart:convert';
import '../../services/storage_service.dart';
import 'plate_math.dart';

/// Impostazioni persistenti del calcolatore zavorre/piastre.
///
/// Non è un provider: viene caricato/salvato on-demand tramite [StorageService],
/// per restare completamente autonomo dall'albero dei provider dell'app.
class WeightedSettings {
  /// Tagli di dischi disponibili in palestra (kg), dal più pesante al leggero.
  List<double> availablePlates;

  /// Peso della barra usata in modalità bilanciere (kg).
  double barWeight;

  /// Peso corporeo dell'utente per il calcolo del carico efficace (kg).
  double bodyWeight;

  /// Unità di misura: 'kg' o 'lb'.
  String unit;

  WeightedSettings({
    required this.availablePlates,
    required this.barWeight,
    required this.bodyWeight,
    this.unit = 'kg',
  });

  String get unitLabel => unit;

  static const _key = '@calistrack/weightedSettings';

  factory WeightedSettings.defaults() => WeightedSettings(
        availablePlates: List.of(PlateMath.defaultPlatesKg),
        barWeight: PlateMath.olympicBarKg,
        bodyWeight: 75,
        unit: 'kg',
      );

  /// Applica i valori standard (barra e dischi) per l'unità indicata.
  void applyUnitDefaults(String u) {
    unit = u;
    if (u == 'lb') {
      availablePlates = List.of(PlateMath.defaultPlatesLb);
      barWeight = PlateMath.olympicBarLb;
      bodyWeight = 165;
    } else {
      availablePlates = List.of(PlateMath.defaultPlatesKg);
      barWeight = PlateMath.olympicBarKg;
      bodyWeight = 75;
    }
  }

  Map<String, dynamic> toJson() => {
        'plates': availablePlates,
        'bar': barWeight,
        'body': bodyWeight,
        'unit': unit,
      };

  factory WeightedSettings.fromJson(Map<String, dynamic> j) => WeightedSettings(
        availablePlates: ((j['plates'] as List?) ?? PlateMath.defaultPlatesKg)
            .map((e) => (e as num).toDouble())
            .toList()
          ..sort((a, b) => b.compareTo(a)),
        barWeight: (j['bar'] as num?)?.toDouble() ?? PlateMath.olympicBarKg,
        bodyWeight: (j['body'] as num?)?.toDouble() ?? 75,
        unit: (j['unit'] as String?) ?? 'kg',
      );

  static Future<WeightedSettings> load() async {
    final raw = await StorageService.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      try {
        return WeightedSettings.fromJson(
            Map<String, dynamic>.from(jsonDecode(raw)));
      } catch (_) {}
    }
    return WeightedSettings.defaults();
  }

  Future<void> save() async {
    await StorageService.setString(_key, jsonEncode(toJson()));
  }

  /// Attiva/disattiva un taglio di disco nella lista disponibile.
  void togglePlate(double kg) {
    if (availablePlates.any((p) => (p - kg).abs() < 0.001)) {
      availablePlates.removeWhere((p) => (p - kg).abs() < 0.001);
    } else {
      availablePlates.add(kg);
    }
    availablePlates.sort((a, b) => b.compareTo(a));
  }

  bool hasPlate(double kg) =>
      availablePlates.any((p) => (p - kg).abs() < 0.001);
}
