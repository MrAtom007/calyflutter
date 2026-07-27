import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/theme_provider.dart';
import '../../state/locale_provider.dart';
import '../../services/feedback_service.dart';
import '../../theme/app_theme.dart';
import 'weighted_settings.dart';

/// Configurazione dei dischi disponibili, barra e peso corporeo.
class WeightedSettingsScreen extends StatefulWidget {
  const WeightedSettingsScreen({super.key});

  @override
  State<WeightedSettingsScreen> createState() => _WeightedSettingsScreenState();
}

class _WeightedSettingsScreenState extends State<WeightedSettingsScreen> {
  WeightedSettings? _s;

  /// Tagli standard selezionabili per unità.
  static const _standardKg = [25.0, 20.0, 15.0, 10.0, 5.0, 2.5, 1.25, 0.5];
  static const _standardLb = [45.0, 35.0, 25.0, 10.0, 5.0, 2.5];

  List<double> get _standardPlates =>
      _s?.unit == 'lb' ? _standardLb : _standardKg;

  @override
  void initState() {
    super.initState();
    WeightedSettings.load().then((s) {
      if (mounted) setState(() => _s = s);
    });
  }

  void _save() => _s?.save();

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    final s = _s;

    return Scaffold(
      appBar: AppBar(title: Text(t('weighted_settings'))),
      body: s == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(Spacing.md),
              children: [
                _section(c, t('unit_measure')),
                Row(
                  children: [
                    for (final u in const ['kg', 'lb'])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(u.toUpperCase()),
                          selected: s.unit == u,
                          selectedColor: c.primary,
                          onSelected: (_) {
                            FeedbackService.selection();
                            setState(() {
                              s.applyUnitDefaults(u);
                              _save();
                            });
                          },
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: Spacing.lg),
                _section(c, t('plates_available')),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final p in _standardPlates)
                      _plateChip(c, p, s.hasPlate(p)),
                  ],
                ),
                const SizedBox(height: Spacing.lg),
                _section(c, t('bar_weight')),
                _numberRow(
                  c,
                  value: s.barWeight,
                  unit: s.unit,
                  steps: const [1.25, 2.5, 5],
                  onChanged: (v) => setState(() {
                    s.barWeight = v.clamp(0, 100);
                    _save();
                  }),
                ),
                const SizedBox(height: Spacing.lg),
                _section(c, t('body_weight')),
                _numberRow(
                  c,
                  value: s.bodyWeight,
                  unit: s.unit,
                  steps: const [0.5, 1, 5],
                  onChanged: (v) => setState(() {
                    s.bodyWeight = v.clamp(20, 300);
                    _save();
                  }),
                ),
              ],
            ),
    );
  }

  Widget _plateChip(AppColors c, double kg, bool active) {
    return GestureDetector(
      onTap: () {
        FeedbackService.light();
        setState(() {
          _s!.togglePlate(kg);
          _save();
        });
      },
      child: Container(
        constraints: const BoxConstraints(minWidth: 56, minHeight: 48),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? c.primary : c.cardAlt,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: active ? c.primary : c.border),
        ),
        child: Text(
          _fmt(kg),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: active
                ? (c.bg.computeLuminance() > 0.5 ? Colors.white : Colors.black)
                : c.text,
          ),
        ),
      ),
    );
  }

  Widget _numberRow(
    AppColors c, {
    required double value,
    required String unit,
    required List<double> steps,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: c.cardAlt,
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(color: c.border),
          ),
          child: Text('${_fmt(value)} $unit',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: c.primary)),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final st in steps) ...[
                _stepBtn(c, '-${_fmt(st)}', () => onChanged(value - st)),
                _stepBtn(c, '+${_fmt(st)}', () => onChanged(value + st),
                    filled: true),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepBtn(AppColors c, String label, VoidCallback onTap,
      {bool filled = false}) {
    return Material(
      color: filled ? c.primary : c.cardAlt,
      borderRadius: BorderRadius.circular(Radii.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.sm),
        onTap: () {
          FeedbackService.light();
          onTap();
        },
        child: Container(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 44),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Radii.sm),
            border: filled ? null : Border.all(color: c.border),
          ),
          child: Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: filled
                      ? (c.bg.computeLuminance() > 0.5
                          ? Colors.white
                          : Colors.black)
                      : c.text)),
        ),
      ),
    );
  }

  Widget _section(AppColors c, String label) => Padding(
        padding: const EdgeInsets.only(bottom: Spacing.sm),
        child: Text(label,
            style: TextStyle(
                color: c.primary,
                fontSize: 15,
                fontWeight: FontWeight.w800)),
      );

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
}
