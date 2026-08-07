import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/theme_provider.dart';
import '../theme/app_theme.dart';
import '../services/feedback_service.dart';

/// Sfondo con un leggero gradiente radiale basato sul colore primario.
class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final c = theme.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.6, -0.9),
          radius: 1.4,
          colors: [
            Color.alphaBlend(c.primary.withValues(alpha: 0.12), c.bg),
            c.bg,
          ],
        ),
      ),
      child: child,
    );
  }
}

/// Card con bordo, glow opzionale e animazione di pressione.
class GlowCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final bool glow;
  final VoidCallback? onTap;
  final double radius;

  const GlowCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Spacing.md),
    this.borderColor,
    this.glow = false,
    this.onTap,
    this.radius = Radii.lg,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final c = theme.colors;
    final border = borderColor ?? c.border;
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            c.card,
            Color.alphaBlend(c.primary.withValues(alpha: 0.03), c.cardAlt),
          ],
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border),
        boxShadow: glow && theme.glowActive
            ? glowShadow(c.primary, blur: 16)
            : [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: theme.skin.isDark ? 0.35 : 0.06,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: child,
    );
    if (onTap == null) return content;
    return PressableScale(onTap: onTap, child: content);
  }
}

/// Wrapper che scala il figlio quando premuto (con feedback tattile/sonoro).
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool feedback;
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.96,
    this.feedback = true,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap == null
          ? null
          : () {
              if (widget.feedback) FeedbackService.onTap();
              widget.onTap!();
            },
      child: AnimatedScale(
        scale: _down ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
