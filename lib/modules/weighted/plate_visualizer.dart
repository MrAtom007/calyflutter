import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'plate_math.dart';

/// Rendering vettoriale dei dischi caricati su bilanciere o cintura.
class PlateVisualizer extends StatelessWidget {
  final PlateResult result;
  final AppColors colors;

  /// Se true usa colori standard da gara, altrimenti tinte coordinate col tema.
  final bool standardColors;

  /// Unità di misura ('kg' o 'lb') per colori ed etichette.
  final String unit;

  const PlateVisualizer({
    super.key,
    required this.result,
    required this.colors,
    this.standardColors = true,
    this.unit = 'kg',
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('${result.mode}-${result.plates.join(',')}'),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        return SizedBox(
          height: 150,
          width: double.infinity,
          child: CustomPaint(
            painter: _PlatePainter(
              result: result,
              colors: colors,
              standardColors: standardColors,
              unit: unit,
              progress: v,
            ),
          ),
        );
      },
    );
  }
}

class _PlatePainter extends CustomPainter {
  final PlateResult result;
  final AppColors colors;
  final bool standardColors;
  final String unit;
  final double progress;

  _PlatePainter({
    required this.result,
    required this.colors,
    required this.standardColors,
    required this.unit,
    required this.progress,
  });

  Color _plateColor(double kg, int index) {
    if (standardColors) return PlateMath.colorFor(kg, unit);
    // Tinte coordinate col tema: alterna primary/primaryDark con opacità.
    final base = index.isEven ? colors.primary : colors.primaryDark;
    return base;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (result.mode == LoadMode.barbell) {
      _paintBarbell(canvas, size);
    } else {
      _paintBelt(canvas, size);
    }
  }

  void _paintBarbell(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final plates = result.plates; // per lato
    if (plates.isEmpty) {
      _paintEmpty(canvas, size);
      return;
    }
    final maxKg = plates.first;
    const plateW = 15.0;
    const gap = 3.0;
    // Barra centrale
    final barPaint = Paint()..color = colors.textMuted.withValues(alpha: 0.6);
    const centerSleeveW = 26.0;
    // Disegna la barra come linea orizzontale
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, cy),
          width: size.width * 0.9,
          height: 8,
        ),
        const Radius.circular(4),
      ),
      barPaint,
    );
    // Sleeve centrale (manicotto)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, cy),
          width: centerSleeveW,
          height: 16,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = colors.textMuted.withValues(alpha: 0.8),
    );

    // Numero massimo di dischi visibili per lato senza uscire dallo schermo.
    final half = (size.width / 2) - centerSleeveW / 2 - 8;
    final maxCount = (half / (plateW + gap)).floor().clamp(1, plates.length);
    final shown = plates.take(maxCount).toList();

    double xL = size.width / 2 - centerSleeveW / 2;
    double xR = size.width / 2 + centerSleeveW / 2;
    for (var i = 0; i < shown.length; i++) {
      final kg = shown[i];
      final h = _plateHeight(kg, maxKg);
      final animH = h * progress;
      final color = _plateColor(kg, i);
      // Lato destro
      _drawPlate(
        canvas,
        Rect.fromLTWH(xR, cy - animH / 2, plateW, animH),
        color,
        kg,
        i == 0,
      );
      // Lato sinistro (specchiato)
      _drawPlate(
        canvas,
        Rect.fromLTWH(xL - plateW, cy - animH / 2, plateW, animH),
        color,
        kg,
        i == 0,
      );
      xR += plateW + gap;
      xL -= plateW + gap;
    }

    if (shown.length < plates.length) {
      _drawMoreBadge(canvas, size, plates.length - shown.length);
    }
  }

  void _paintBelt(Canvas canvas, Size size) {
    final plates = result.plates;
    if (plates.isEmpty) {
      _paintEmpty(canvas, size);
      return;
    }
    final cx = size.width / 2;
    // Moschettone/gancio in alto
    final hookPaint = Paint()
      ..color = colors.textMuted
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, 22), radius: 12),
      3.6,
      4.4,
      false,
      hookPaint,
    );
    canvas.drawLine(Offset(cx, 28), Offset(cx, 44), hookPaint);

    final maxKg = plates.reduce((a, b) => a > b ? a : b);
    const plateH = 16.0;
    const gap = 4.0;
    final maxKgWidth = size.width * 0.5;

    double y = 46;
    final maxCount = ((size.height - y - 6) / (plateH + gap)).floor().clamp(
      1,
      plates.length,
    );
    final shown = plates.take(maxCount).toList();
    for (var i = 0; i < shown.length; i++) {
      final kg = shown[i];
      final w = (0.4 + 0.6 * (kg / maxKg)) * maxKgWidth;
      final animW = w * progress;
      final color = _plateColor(kg, i);
      _drawPlate(
        canvas,
        Rect.fromCenter(
          center: Offset(cx, y + plateH / 2),
          width: animW,
          height: plateH,
        ),
        color,
        kg,
        false,
        horizontal: true,
      );
      y += plateH + gap;
    }
    if (shown.length < plates.length) {
      _drawMoreBadge(canvas, size, plates.length - shown.length);
    }
  }

  double _plateHeight(double kg, double maxKg) {
    final ratio = maxKg <= 0 ? 1.0 : kg / maxKg;
    return 40 + 80 * ratio; // 40..120 px
  }

  void _drawPlate(
    Canvas canvas,
    Rect rect,
    Color color,
    double kg,
    bool label, {
    bool horizontal = false,
  }) {
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
    canvas.drawRRect(rrect, Paint()..color = color);
    // Sfumatura per dare volume al disco.
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = LinearGradient(
          begin: horizontal ? Alignment.topCenter : Alignment.centerLeft,
          end: horizontal ? Alignment.bottomCenter : Alignment.centerRight,
          colors: [
            Colors.white.withValues(alpha: 0.22),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.28),
          ],
          stops: const [0, 0.5, 1],
        ).createShader(rect),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    // Foro centrale (visibile nei dischi mostrati di faccia, cintura).
    if (horizontal && rect.width > 26) {
      canvas.drawCircle(
        rect.center,
        4,
        Paint()..color = colors.bg.withValues(alpha: 0.9),
      );
      canvas.drawCircle(
        rect.center,
        4,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
    // Etichetta peso (solo se lo spazio è sufficiente).
    final show = horizontal ? rect.width > 34 : rect.height > 46;
    if (show) {
      final tp = TextPainter(
        text: TextSpan(
          text: _fmt(kg),
          style: TextStyle(
            color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.save();
      if (!horizontal) {
        canvas.translate(rect.center.dx, rect.center.dy);
        canvas.rotate(-1.5708); // -90°
        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      } else {
        tp.paint(
          canvas,
          Offset(rect.center.dx - tp.width / 2, rect.center.dy - tp.height / 2),
        );
      }
      canvas.restore();
    }
  }

  void _drawMoreBadge(Canvas canvas, Size size, int extra) {
    final tp = TextPainter(
      text: TextSpan(
        text: '+$extra',
        style: TextStyle(
          color: colors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(size.width - tp.width - 4, size.height - tp.height - 2),
    );
  }

  void _paintEmpty(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: TextSpan(
        text: '—',
        style: TextStyle(color: colors.textMuted, fontSize: 20),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(size.width / 2 - tp.width / 2, size.height / 2 - tp.height / 2),
    );
  }

  String _fmt(double kg) =>
      kg == kg.roundToDouble() ? kg.toInt().toString() : kg.toString();

  @override
  bool shouldRepaint(_PlatePainter old) =>
      old.progress != progress ||
      old.result.plates.join(',') != result.plates.join(',') ||
      old.result.mode != result.mode ||
      old.standardColors != standardColors;
}
