import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Grafico a linea semplice con linea di riferimento opzionale (record).
class SimpleLineChart extends StatelessWidget {
  final List<double> values;
  final Color color;
  final double? refLine;
  final double height;

  const SimpleLineChart({
    super.key,
    required this.values,
    required this.color,
    this.refLine,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('Dati insufficienti')),
      );
    }
    final spots = <FlSpot>[
      for (int i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i])
    ];
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final minY = values.reduce((a, b) => a < b ? a : b);
    final pad = (maxY - minY).abs() * 0.15 + 1;

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
          extraLinesData: refLine != null
              ? ExtraLinesData(horizontalLines: [
                  HorizontalLine(
                    y: refLine!,
                    color: color.withValues(alpha: 0.4),
                    dashArray: [6, 4],
                    strokeWidth: 1,
                  )
                ])
              : const ExtraLinesData(),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                  radius: 3,
                  color: color,
                  strokeWidth: 0,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0.25),
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

/// Grafico a barre semplice con etichette.
class SimpleBarChart extends StatelessWidget {
  final List<String> labels;
  final List<double> values;
  final Color color;
  final double height;

  const SimpleBarChart({
    super.key,
    required this.labels,
    required this.values,
    required this.color,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    final maxY = (values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b));
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: (maxY == 0 ? 1 : maxY) * 1.2,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= labels.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(labels[i],
                        style: TextStyle(fontSize: 10, color: muted)),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (int i = 0; i < values.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: values[i],
                  color: color,
                  width: 14,
                  borderRadius: BorderRadius.circular(4),
                )
              ]),
          ],
        ),
      ),
    );
  }
}
