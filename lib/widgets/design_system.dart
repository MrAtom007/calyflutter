import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/theme_provider.dart';
import '../theme/app_theme.dart';
import 'ui_kit.dart';

/// Spaziatura effettiva scalata sulla densità scelta dall'utente.
double sp(BuildContext context, double base) =>
    base * context.watch<ThemeProvider>().densityScale;

/// true solo su piattaforme mobile (Android/iOS). Su desktop (Linux/Windows/
/// macOS) e Web è false: usato per nascondere feature mobile-only come il
/// login Google / salvataggio cloud, non supportati su desktop.
bool get isMobilePlatform =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

/// Dispone [children] in colonne responsive: 1 colonna su schermi stretti
/// (telefono), più colonne su schermi larghi (desktop/PC). Ogni figlio riceve
/// la stessa larghezza. Utile per liste omogenee di card.
class ResponsiveWrap extends StatelessWidget {
  const ResponsiveWrap({
    super.key,
    required this.children,
    this.minTileWidth = 260,
    this.maxColumns = 3,
    this.spacing = Spacing.sm,
    this.runSpacing = Spacing.sm,
  });

  final List<Widget> children;
  final double minTileWidth;
  final int maxColumns;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, cns) {
        final cols = (cns.maxWidth / minTileWidth).floor().clamp(1, maxColumns);
        if (cols <= 1) {
          // Mobile: colonna singola con spaziatura verticale.
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(height: runSpacing),
                children[i],
              ],
            ],
          );
        }
        final w = (cns.maxWidth - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: [for (final ch in children) SizedBox(width: w, child: ch)],
        );
      },
    );
  }
}

/// Intestazione di sezione uniforme (icona + titolo + azione opzionale).
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm, top: Spacing.xs),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: c.primary),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: c.textMuted,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            PressableScale(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: c.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Card che rispetta lo stile scelto (solid / glass / outline).
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? accent;
  final bool glow;
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.accent,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final c = theme.colors;
    final style = theme.cardStyle;
    final pad = padding ?? EdgeInsets.all(Spacing.md * theme.densityScale);
    final accentColor = accent ?? c.primary;

    BoxDecoration deco;
    switch (style) {
      case CardStyle.glass:
        deco = BoxDecoration(
          color: Color.alphaBlend(c.card.withValues(alpha: 0.6), c.bg),
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(color: c.text.withValues(alpha: 0.06)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              c.text.withValues(alpha: 0.05),
              accentColor.withValues(alpha: 0.04),
            ],
          ),
        );
        break;
      case CardStyle.outline:
        deco = BoxDecoration(
          color: c.bg,
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.35),
            width: 1.4,
          ),
        );
        break;
      case CardStyle.solid:
        deco = BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              c.card,
              Color.alphaBlend(accentColor.withValues(alpha: 0.04), c.cardAlt),
            ],
          ),
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(color: c.border),
          boxShadow: glow && theme.glowActive
              ? glowShadow(accentColor, blur: 16)
              : [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: theme.skin.isDark ? 0.32 : 0.06,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        );
        break;
    }

    final content = Container(padding: pad, decoration: deco, child: child);
    if (onTap == null) return content;
    return PressableScale(onTap: onTap, child: content);
  }
}

/// Piccola tile numerica (etichetta + valore + unità).
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final IconData? icon;
  final Color? color;
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final col = color ?? c.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: col),
          const SizedBox(height: 6),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: c.text,
              ),
            ),
            if (unit != null) ...[
              const SizedBox(width: 3),
              Text(
                unit!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: c.textMuted,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: c.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
