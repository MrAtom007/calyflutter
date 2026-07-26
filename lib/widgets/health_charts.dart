import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Onda ECG/sinusoide animata che scorre orizzontalmente.
/// Il [bpm] modula la velocità e la frequenza dei picchi.
class HeartWave extends StatefulWidget {
  final Color color;
  final double bpm;
  final double height;
  final bool ecg;
  const HeartWave({
    super.key,
    required this.color,
    this.bpm = 70,
    this.height = 90,
    this.ecg = true,
  });

  @override
  State<HeartWave> createState() => _HeartWaveState();
}

class _HeartWaveState extends State<HeartWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _WavePainter(
            phase: _c.value,
            color: widget.color,
            bpm: widget.bpm,
            ecg: widget.ecg,
          ),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double phase;
  final Color color;
  final double bpm;
  final bool ecg;
  _WavePainter({
    required this.phase,
    required this.color,
    required this.bpm,
    required this.ecg,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.height / 2;
    final path = Path();
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [color.withValues(alpha: 0.15), color, color],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Numero di battiti visibili proporzionale al bpm.
    final beats = (bpm / 22).clamp(2.0, 6.0);
    final cycle = size.width / beats;
    final shift = phase * cycle;

    for (double x = 0; x <= size.width; x += 1.5) {
      final local = ((x + shift) % cycle) / cycle; // 0..1 dentro un battito
      double y;
      if (ecg) {
        y = mid - _ecg(local) * (size.height * 0.4);
      } else {
        y = mid - sin(local * 2 * pi) * (size.height * 0.32);
      }
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, linePaint);

    // Punto luminoso in testa all'onda.
    final headX = size.width - 2;
    final headLocal = ((headX + shift) % cycle) / cycle;
    final headY = ecg
        ? mid - _ecg(headLocal) * (size.height * 0.4)
        : mid - sin(headLocal * 2 * pi) * (size.height * 0.32);
    canvas.drawCircle(
      Offset(headX, headY),
      3.2,
      Paint()..color = color,
    );
    canvas.drawCircle(
      Offset(headX, headY),
      7,
      Paint()
        ..color = color.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
  }

  /// Forma d'onda tipo ECG (P-QRS-T) normalizzata su -1..1.5.
  double _ecg(double t) {
    double y = 0;
    y += 0.12 * exp(-pow((t - 0.20) / 0.03, 2).toDouble()); // P
    y -= 0.18 * exp(-pow((t - 0.34) / 0.015, 2).toDouble()); // Q
    y += 1.0 * exp(-pow((t - 0.38) / 0.012, 2).toDouble()); // R
    y -= 0.30 * exp(-pow((t - 0.42) / 0.015, 2).toDouble()); // S
    y += 0.22 * exp(-pow((t - 0.62) / 0.04, 2).toDouble()); // T
    return y;
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) =>
      old.phase != phase || old.color != color || old.bpm != bpm;
}

/// Anello di progresso in stile "activity ring".
class RingGauge extends StatelessWidget {
  final double progress; // 0..1
  final Color color;
  final Color trackColor;
  final double size;
  final double stroke;
  final Widget? center;
  const RingGauge({
    super.key,
    required this.progress,
    required this.color,
    required this.trackColor,
    this.size = 84,
    this.stroke = 9,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress.clamp(0, 1)),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => CustomPaint(
          painter: _RingPainter(v, color, trackColor, stroke),
          child: Center(child: center),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color track;
  final double stroke;
  _RingPainter(this.progress, this.color, this.track, this.stroke);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.width - stroke) / 2;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );
    final sweep = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: -pi / 2,
          endAngle: 3 * pi / 2,
          colors: [color.withValues(alpha: 0.5), color],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    if (progress > 0.02) {
      final ang = -pi / 2 + sweep;
      final dot = Offset(
        center.dx + radius * cos(ang),
        center.dy + radius * sin(ang),
      );
      canvas.drawCircle(dot, stroke * 0.55, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}

/// Mini grafico a linea curva riempita (sparkline).
class Sparkline extends StatelessWidget {
  final List<double> values;
  final Color color;
  final double height;
  final bool showDots;
  const Sparkline({
    super.key,
    required this.values,
    required this.color,
    this.height = 54,
    this.showDots = false,
  });

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) {
      return SizedBox(height: height);
    }
    final maxY = values.reduce(max);
    final minY = values.reduce(min);
    final pad = (maxY - minY).abs() * 0.2 + 0.5;
    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: minY - pad,
          maxY: maxY + pad,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (int i = 0; i < values.length; i++)
                  FlSpot(i.toDouble(), values[i])
              ],
              isCurved: true,
              curveSmoothness: 0.35,
              color: color,
              barWidth: 2.6,
              dotData: FlDotData(show: showDots),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0.3),
                    color.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grafico a doppia linea (es. pressione sistolica/diastolica).
class DualLineChart extends StatelessWidget {
  final List<double> primary;
  final List<double> secondary;
  final Color colorPrimary;
  final Color colorSecondary;
  final double height;
  const DualLineChart({
    super.key,
    required this.primary,
    required this.secondary,
    required this.colorPrimary,
    required this.colorSecondary,
    this.height = 150,
  });

  @override
  Widget build(BuildContext context) {
    final all = [...primary, ...secondary];
    if (all.length < 2) return SizedBox(height: height);
    final maxY = all.reduce(max);
    final minY = all.reduce(min);
    final pad = (maxY - minY).abs() * 0.15 + 2;
    LineChartBarData bar(List<double> v, Color c) => LineChartBarData(
          spots: [for (int i = 0; i < v.length; i++) FlSpot(i.toDouble(), v[i])],
          isCurved: true,
          color: c,
          barWidth: 2.8,
          dotData: FlDotData(
            show: true,
            getDotPainter: (s, p, b, i) =>
                FlDotCirclePainter(radius: 2.6, color: c, strokeWidth: 0),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [c.withValues(alpha: 0.18), c.withValues(alpha: 0.0)],
            ),
          ),
        );
    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: minY - pad,
          maxY: maxY + pad,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => FlLine(
              color: Colors.white.withValues(alpha: 0.05),
              strokeWidth: 1,
            ),
          ),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Colors.black.withValues(alpha: 0.8),
              getTooltipItems: (spots) => spots
                  .map((s) => LineTooltipItem(
                        s.y.round().toString(),
                        TextStyle(
                            color: s.bar.color ?? Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12),
                      ))
                  .toList(),
            ),
          ),
          lineBarsData: [bar(primary, colorPrimary), bar(secondary, colorSecondary)],
        ),
      ),
    );
  }
}
