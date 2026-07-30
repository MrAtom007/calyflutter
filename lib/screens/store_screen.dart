import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/theme_provider.dart';
import '../state/locale_provider.dart';
import '../services/feedback_service.dart';
import '../services/app_icon_service.dart';
import '../theme/app_theme.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final c = theme.colors;
    final t = context.watch<LocaleProvider>().t;
    final premium = themeList.where((s) => s.premium).toList();

    return Scaffold(
      appBar: AppBar(title: Text(t('neon_store'))),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(Radii.lg),
              border: Border.all(color: c.border),
            ),
            child: Text(
              t('store_banner'),
              style: TextStyle(color: c.text, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: Spacing.md),
          ...premium.map((skin) {
            final owned = theme.isUnlocked(skin.id);
            final active = theme.themeId == skin.id;
            final glow = skin.glow ?? c.primary;
            return Container(
              margin: const EdgeInsets.only(bottom: Spacing.md),
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                color: skin.colors.bg,
                borderRadius: BorderRadius.circular(Radii.lg),
                border: Border.all(color: glow.withValues(alpha: 0.7)),
                boxShadow: glowShadow(glow, blur: 14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _swatch(skin.colors.bg),
                      _swatch(skin.colors.card),
                      _swatch(skin.colors.primary),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(skin.name,
                      style: TextStyle(
                          color: glow,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  Text(skin.description,
                      style: TextStyle(color: skin.colors.textMuted)),
                  if (AppIconService.styles
                      .any((ic) => ic.premium && ic.themeId == skin.id))
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(Icons.apps_rounded, size: 14, color: glow),
                          const SizedBox(width: 4),
                          Text(t('store_icon_included'),
                              style: TextStyle(
                                  color: glow,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  const SizedBox(height: Spacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: owned
                        ? (active
                            ? FilledButton(
                                onPressed: null,
                                child: Text(t('active')))
                            : FilledButton(
                                style: FilledButton.styleFrom(
                                    backgroundColor: glow),
                                onPressed: () {
                                  FeedbackService.onTap();
                                  theme.changeTheme(skin.id);
                                },
                                child: Text(t('apply'))))
                        : FilledButton(
                            style: FilledButton.styleFrom(
                                backgroundColor: glow),
                            onPressed: () async {
                              FeedbackService.onUnlock();
                              await theme.unlock(skin.id);
                              await theme.changeTheme(skin.id);
                            },
                            child: const Text('2,99 €'),
                          ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: Spacing.md),
          Text(
            t('demo_purchases'),
            style: TextStyle(color: c.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _swatch(Color color) => Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white24),
        ),
      );
}
