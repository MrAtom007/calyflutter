import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/ranks.dart';

/// Medaglia con anello di progresso, disco a gradiente e icona del rango.
class Medal extends StatelessWidget {
  final Rank rank;
  final double size;
  final double progress; // 0..1
  final bool locked;
  final int? level;

  const Medal({
    super.key,
    required this.rank,
    this.size = 64,
    this.progress = 1,
    this.locked = false,
    this.level,
  });

  @override
  Widget build(BuildContext context) {
    final lvl = level ?? levelOf(rank.id);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MedalPainter(
          rank: rank,
          progress: progress.clamp(0, 1),
          locked: locked,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                locked ? Icons.lock : rank.mci,
                size: size * 0.32,
                color: locked ? Colors.white54 : Colors.white,
              ),
              if (!locked)
                Text(
                  'LV $lvl',
                  style: TextStyle(
                    fontSize: size * 0.12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedalPainter extends CustomPainter {
  final Rank rank;
  final double progress;
  final bool locked;

  _MedalPainter({
    required this.rank,
    required this.progress,
    required this.locked,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final ringWidth = size.width * 0.08;
    final discRadius = radius - ringWidth * 1.6;

    final c1 = locked ? const Color(0xFF444444) : rank.color;
    final c2 = locked ? const Color(0xFF2a2a2a) : rank.color2;

    // disco con gradiente radiale
    final discPaint = Paint()
      ..shader = RadialGradient(
        colors: [c1, c2],
      ).createShader(Rect.fromCircle(center: center, radius: discRadius));
    canvas.drawCircle(center, discRadius, discPaint);

    // anello di sfondo
    final bgRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth
      ..color = Colors.white.withValues(alpha: 0.12);
    canvas.drawCircle(center, radius - ringWidth / 2, bgRing);

    // anello di progresso
    if (!locked) {
      final progPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = ringWidth
        ..color = rank.glow;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - ringWidth / 2),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MedalPainter old) =>
      old.progress != progress || old.locked != locked || old.rank != rank;
}
