import 'dart:math';
import 'dart:ui';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/ranks.dart';
import '../state/locale_provider.dart';
import '../services/feedback_service.dart';
import 'medal.dart';

final _rnd = Random();

/// Overlay a schermo intero, premium/dark, mostrato al level up.
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
    duration: const Duration(milliseconds: 900),
  )..forward();
  late final ConfettiController _confetti =
      ConfettiController(duration: const Duration(seconds: 2));

  @override
  void initState() {
    super.initState();
    _confetti.play();
    // Suono + haptic ritmico sincronizzati con l'esplosione.
    FeedbackService.onLevelUp();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _confetti.dispose();
    super.dispose();
  }

  static const _confettiColors = [
    Colors.amber,
    Colors.orangeAccent,
    Colors.white,
    Colors.yellow,
    Colors.cyanAccent,
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleProvider>().t;
    final rank = widget.rank;
    final scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    final fade = CurvedAnimation(
        parent: _ctrl, curve: const Interval(0, 0.4, curve: Curves.easeOut));

    return GestureDetector(
      onTap: widget.onDismiss,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Sfondo scuro + sfocatura.
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withValues(alpha: 0.6)),
          ),
          // Esplosione radiale di coriandoli dal centro.
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.04,
              numberOfParticles: 30,
              maxBlastForce: 40,
              minBlastForce: 12,
              gravity: 0.32,
              particleDrag: 0.05,
              minimumSize: const Size(8, 8),
              maximumSize: const Size(16, 16),
              createParticlePath: _starOrCircle,
              colors: [..._confettiColors, rank.color, rank.glow],
            ),
          ),
          // Card centrale glassmorphic.
          FadeTransition(
            opacity: fade,
            child: ScaleTransition(
              scale: scale,
              child: _card(context, t, rank),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, dynamic t, Rank rank) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                    color: const Color(0xFFFFD37A).withValues(alpha: 0.55),
                    width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: rank.glow.withValues(alpha: 0.35),
                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Label superiore.
                  Text(
                    t('rank_unlocked'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFFFD37A),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Badge con glow radiale dietro.
                  SizedBox(
                    width: 190,
                    height: 190,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                rank.glow.withValues(alpha: 0.55),
                                rank.color.withValues(alpha: 0.15),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                        Medal(rank: rank, size: 150, level: widget.level),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  // Titolo: nome rango + livello.
                  Text(
                    '${rank.name} · ${t('level')} ${widget.level}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                      shadows: [
                        Shadow(color: rank.glow.withValues(alpha: 0.6), blurRadius: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t('level_up_sub'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 26),
                  // Pulsante primario "Continua".
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: rank.color,
                        foregroundColor:
                            rank.color.computeLuminance() > 0.5
                                ? Colors.black
                                : Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        FeedbackService.onTap();
                        widget.onDismiss();
                      },
                      child: Text(
                        t('continue_'),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Path casuale (stella o cerchio) per le particelle, così niente rettangoli.
Path _starOrCircle(Size size) {
  if (_rnd.nextBool()) {
    return Path()
      ..addOval(Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.width / 2));
  }
  return _starPath(size);
}

Path _starPath(Size size) {
  const points = 5;
  final path = Path();
  final cx = size.width / 2;
  final cy = size.height / 2;
  final outer = size.width / 2;
  final inner = outer * 0.45;
  final step = pi / points;
  var angle = -pi / 2;
  path.moveTo(cx + outer * cos(angle), cy + outer * sin(angle));
  for (var i = 0; i < points; i++) {
    angle += step;
    path.lineTo(cx + inner * cos(angle), cy + inner * sin(angle));
    angle += step;
    path.lineTo(cx + outer * cos(angle), cy + outer * sin(angle));
  }
  path.close();
  return path;
}
