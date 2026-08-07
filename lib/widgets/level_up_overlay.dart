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
  late final ConfettiController _confetti = ConfettiController(
    duration: const Duration(seconds: 2),
  );

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
    final accent = rank.glow;
    final scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    final fade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0, 0.4, curve: Curves.easeOut),
    );

    // Material (transparency) + DefaultTextStyle: garantisce font corretto
    // dell'app e nessuna sottolineatura di debug (l'overlay sta fuori da Scaffold).
    return Material(
      type: MaterialType.transparency,
      child: DefaultTextStyle(
        style: const TextStyle(
          fontFamily: 'Inter',
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
        child: GestureDetector(
          onTap: widget.onDismiss,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            alignment: Alignment.center,
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.black.withValues(alpha: 0.6)),
              ),
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
              FadeTransition(
                opacity: fade,
                child: ScaleTransition(
                  scale: scale,
                  child: _card(context, t, rank, accent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(BuildContext context, dynamic t, Rank rank, Color accent) {
    final onAccent = accent.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF16161E).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: accent.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Text(
                    t('rank_unlocked'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Badge con backlight radiale + glow.
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          rank.color.withValues(alpha: 0.35),
                          rank.color2.withValues(alpha: 0.10),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Medal(rank: rank, size: 118, level: widget.level),
                  ),
                  const SizedBox(height: 20),
                  // Titolo
                  Text(
                    '${rank.name} • ${t('level')} ${widget.level}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Sottotitolo
                  Text(
                    t('level_up_sub'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white60,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Pulsante Continua
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: onAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        FeedbackService.onTap();
                        widget.onDismiss();
                      },
                      child: Text(
                        t('continue_'),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          decoration: TextDecoration.none,
                        ),
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
    return Path()..addOval(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2,
      ),
    );
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
