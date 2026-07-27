import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/theme_provider.dart';
import '../../state/locale_provider.dart';
import '../../services/feedback_service.dart';
import '../../theme/app_theme.dart';
import 'plate_math.dart';
import 'plate_visualizer.dart';
import 'weighted_settings.dart';

/// Pulsante tattile grande (min 48x48dp) con feedback aptico leggero.
class BigTapButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;
  final bool filled;

  const BigTapButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.color,
    this.textColor,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final bg = filled ? (color ?? c.primary) : c.cardAlt;
    final fg = textColor ?? (filled ? _onColor(context, bg) : c.text);
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(Radii.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.md),
        onTap: () {
          FeedbackService.light();
          onTap();
        },
        child: Container(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Radii.md),
            border: filled ? null : Border.all(color: c.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 6),
              ],
              Text(label,
                  style: TextStyle(
                      color: fg, fontWeight: FontWeight.w800, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  static Color _onColor(BuildContext context, Color bg) =>
      bg.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}

/// Numpad rapido: mostra il valore corrente e bottoni di incremento tattili,
/// evitando l'apertura della tastiera di sistema.
class QuickStepper extends StatefulWidget {
  final TextEditingController controller;
  final List<double> steps; // incrementi rapidi (es. [1, 2.5, 5])
  final bool decimal;
  final String unit;
  final ValueChanged<double>? onChanged;

  const QuickStepper({
    super.key,
    required this.controller,
    required this.steps,
    required this.unit,
    this.decimal = false,
    this.onChanged,
  });

  @override
  State<QuickStepper> createState() => _QuickStepperState();
}

class _QuickStepperState extends State<QuickStepper> {
  double get _value =>
      double.tryParse(widget.controller.text.replaceAll(',', '.')) ?? 0;

  void _apply(double delta) {
    final next = (_value + delta).clamp(0, 100000).toDouble();
    setState(() {
      widget.controller.text = _fmt(next);
    });
    FeedbackService.light();
    widget.onChanged?.call(next);
  }

  String _fmt(double v) {
    if (widget.decimal) {
      return v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
    }
    return v.round().toString();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Valore corrente in evidenza.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: c.cardAlt,
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(color: c.border),
          ),
          child: Row(
            children: [
              Text(
                widget.controller.text.isEmpty ? '0' : widget.controller.text,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: c.primary),
              ),
              const SizedBox(width: 6),
              Text(widget.unit,
                  style: TextStyle(color: c.textMuted, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: Spacing.sm),
        // Bottoni incremento/decremento.
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in widget.steps)
              BigTapButton(label: '-${_fmt(s)}', onTap: () => _apply(-s)),
            for (final s in widget.steps)
              BigTapButton(
                  label: '+${_fmt(s)}', filled: true, onTap: () => _apply(s)),
          ],
        ),
      ],
    );
  }
}

/// Mostra il bottom sheet con il visualizzatore dischi per un peso target.
Future<void> showPlateSheet(
  BuildContext context, {
  required double addedWeight,
}) async {
  final settings = await WeightedSettings.load();
  if (!context.mounted) return;
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PlateSheet(settings: settings, addedWeight: addedWeight),
  );
}

class _PlateSheet extends StatefulWidget {
  final WeightedSettings settings;
  final double addedWeight;
  const _PlateSheet({required this.settings, required this.addedWeight});

  @override
  State<_PlateSheet> createState() => _PlateSheetState();
}

class _PlateSheetState extends State<_PlateSheet> {
  late LoadMode _mode = LoadMode.belt;
  late final TextEditingController _weight =
      TextEditingController(text: _fmtInput(widget.addedWeight));

  String _fmtInput(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  double get _target =>
      double.tryParse(_weight.text.replaceAll(',', '.')) ?? 0;

  @override
  void dispose() {
    _weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    final s = widget.settings;

    final result = PlateMath.compute(
      target: _target,
      available: s.availablePlates,
      mode: _mode,
      barWeight: s.barWeight,
    );
    final effective = PlateMath.effectiveLoad(
        bodyWeight: s.bodyWeight, addedWeight: _target);
    final u = s.unit;
    final steps = u == 'lb'
        ? const <double>[2.5, 5, 10, 25]
        : const <double>[1.25, 2.5, 5, 10];

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(Radii.lg)),
        border: Border.all(color: c.border),
      ),
      padding: EdgeInsets.only(
        left: Spacing.md,
        right: Spacing.md,
        top: Spacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + Spacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: Spacing.md),
          Text(t('plate_title'),
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: Spacing.sm),
          // Toggle modalità cintura / bilanciere.
          Row(
            children: [
              Expanded(
                child: _modeChip(c, t('plate_belt'), Icons.link_rounded,
                    LoadMode.belt),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _modeChip(c, t('plate_barbell'),
                    Icons.fitness_center_rounded, LoadMode.barbell),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          PlateVisualizer(result: result, colors: c, unit: u),
          const SizedBox(height: Spacing.sm),
          // Riepilogo pesi.
          _summaryRow(c, t('plate_added'), '${_fmtInput(_target)} $u'),
          if (_mode == LoadMode.barbell)
            _summaryRow(c, t('plate_total_bar'),
                '${_fmtInput(result.totalSystemWeight)} $u'),
          _summaryRow(c, t('plate_effective'),
              '${_fmtInput(effective)} $u (BW+${_fmtInput(_target)})'),
          if (!result.isExact && !result.isEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: c.danger.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(Radii.sm),
                border: Border.all(color: c.danger.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 16, color: c.danger),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${t('plate_not_exact')} ${_fmtInput(result.achieved + (_mode == LoadMode.barbell ? result.barWeight : 0))} $u',
                      style: TextStyle(color: c.danger, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: Spacing.md),
          QuickStepper(
            controller: _weight,
            steps: steps,
            unit: u,
            decimal: true,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _modeChip(AppColors c, String label, IconData icon, LoadMode mode) {
    final active = _mode == mode;
    return GestureDetector(
      onTap: () {
        FeedbackService.selection();
        setState(() => _mode = mode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? c.primary : c.cardAlt,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: active ? c.primary : c.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: active
                    ? (c.bg.computeLuminance() > 0.5
                        ? Colors.white
                        : Colors.black)
                    : c.textMuted),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: active
                        ? (c.bg.computeLuminance() > 0.5
                            ? Colors.white
                            : Colors.black)
                        : c.text)),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(AppColors c, String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: TextStyle(color: c.textMuted, fontSize: 13)),
          Text(v,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        ],
      ),
    );
  }
}
