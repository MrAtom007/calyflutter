import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/ranks.dart';
import '../state/locale_provider.dart';
import '../services/feedback_service.dart';
import 'medal.dart';

/// Overlay a schermo intero con coriandoli mostrato al level up.
class LevelUpOverlay extends StatefulWidget {
  final Rank rank;
  final int level;
  final VoidCallback onDismiss;
  const LevelUpOverlay({
    super.key,
    required this.rank,
    required this.level,
    required this.onDismiss,
  });

  @override
  State<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<LevelUpOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();
  late final ConfettiController _confetti =
      ConfettiController(duration: const Duration(seconds: 3));

  @override
  void initState() {
    super.initState();
    _confetti.play();
    FeedbackService.onLevelUp();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleProvider>().t;
    final scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(color: Colors.black.withValues(alpha: 0.92)),
          // Coriandoli dal centro-alto
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirection: pi / 2,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 24,
              maxBlastForce: 28,
              minBlastForce: 10,
              gravity: 0.25,
              colors: [
                widget.rank.color,
                widget.rank.glow,
                widget.rank.color2,
                Colors.white,
              ],
            ),
          ),
          ScaleTransition(
            scale: scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('✨', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                ShaderMask(
                  shaderCallback: (r) => LinearGradient(
                    colors: [widget.rank.glow, widget.rank.color],
                  ).createShader(r),
                  child: Text(
                    t('level_up'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Medal(rank: widget.rank, size: 170, level: widget.level),
                const SizedBox(height: 20),
                Text(
                  widget.rank.name,
                  style: TextStyle(
                    color: widget.rank.color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${t('level')} ${widget.level}',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 28),
                OutlinedButton(
                  onPressed: widget.onDismiss,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: widget.rank.color),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: Text(t('continue_')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
