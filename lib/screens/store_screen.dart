import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/theme_provider.dart';
import '../state/locale_provider.dart';
import '../services/feedback_service.dart';
import '../services/app_icon_service.dart';
import '../services/monetization_service.dart';
import '../services/analytics_service.dart';
import '../theme/app_theme.dart';
import '../widgets/emblem.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  // Temi considerati "leggendari" (gli altri premium sono palette Neon).
  static const _legendaryIds = {
    'spartacus', 'kratos', 'ulisse', 'zeus', 'cyberpunk',
    'valkyrie', 'ronin', 'anubis', 'achille', 'leonida', 'poseidon',
    'ercole', 'odino', 'ra', 'ade',
    'cavaliere', 'cerberus', 'igris', 'sukuna', 'toji',
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final c = theme.colors;
    final t = context.watch<LocaleProvider>().t;

    final premium = themeList.where((s) => s.premium).toList();
    final legendary = premium.where((s) => _legendaryIds.contains(s.id)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final neon = premium.where((s) => !_legendaryIds.contains(s.id)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final locked = premium.where((s) => !theme.isUnlocked(s.id)).toList();

    return Scaffold(
      appBar: AppBar(title: Text(t('neon_store'))),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          _banner(context, c, t.call, locked),
          if (legendary.isNotEmpty) ...[
            _sectionHeader(c, t('theme_tab_legendary'), legendary.length),
            ...legendary.map((s) => _tile(context, theme, c, t.call, s)),
          ],
          if (neon.isNotEmpty) ...[
            const SizedBox(height: Spacing.sm),
            _sectionHeader(c, t('theme_tab_neon'), neon.length),
            ...neon.map((s) => _tile(context, theme, c, t.call, s)),
          ],
          const SizedBox(height: Spacing.md),
          Text(t('demo_purchases'),
              style: TextStyle(color: c.textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _banner(BuildContext context, AppColors c, String Function(String) t,
      List<AppSkin> locked) {
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.md),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t('store_banner'),
              style: TextStyle(color: c.text, fontWeight: FontWeight.w600)),
          if (locked.isNotEmpty) ...[
            const SizedBox(height: Spacing.sm),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: c.primary),
                onPressed: () async {
                  final themeProvider = context.read<ThemeProvider>();
                  FeedbackService.onUnlock();
                  // Se RevenueCat è configurato (API key presente) avvia un
                  // acquisto reale; altrimenti mantiene lo sblocco locale (demo).
                  if (MonetizationService.isAvailable) {
                    final ok = await MonetizationService.buyPremium();
                    if (!ok) return; // acquisto annullato o fallito
                    AnalyticsService.storeUnlock('all', paid: true, price: 9.99);
                  } else {
                    AnalyticsService.storeUnlock('all', paid: false);
                  }
                  themeProvider.unlockMany(locked.map((s) => s.id));
                },
                icon: const Icon(Icons.lock_open_rounded, size: 18),
                label: Text('${t('store_unlock_all')}  ·  9,99 €'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionHeader(AppColors c, String label, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.sm, bottom: Spacing.sm),
      child: Row(
        children: [
          Text(label.toUpperCase(),
              style: TextStyle(
                  color: c.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2)),
          const SizedBox(width: 6),
          Text('$count',
              style: TextStyle(color: c.textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, ThemeProvider theme, AppColors c,
      String Function(String) t, AppSkin skin) {
    final owned = theme.isUnlocked(skin.id);
    final active = theme.themeId == skin.id;
    final glow = skin.glow ?? skin.colors.primary;
    final subject = emblemForTheme(skin.id);
    final hasIcon = AppIconService.styles
        .any((ic) => ic.premium && ic.themeId == skin.id);

    void buy() {
      FeedbackService.onUnlock();
      theme.unlock(skin.id);
      theme.changeTheme(skin.id);
    }

    void apply() {
      FeedbackService.onTap();
      theme.changeTheme(skin.id);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: skin.colors.card,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(
            color: active ? glow : glow.withValues(alpha: 0.35),
            width: active ? 2 : 1),
      ),
      child: Row(
        children: [
          // Anteprima
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [skin.colors.cardAlt, skin.colors.bg],
              ),
              borderRadius: BorderRadius.circular(Radii.sm),
              border: Border.all(color: glow.withValues(alpha: 0.5)),
            ),
            clipBehavior: Clip.antiAlias,
            child: subject != null
                ? Center(
                    child: EmblemView(
                        subject: subject, size: 30, color: glow))
                : Center(
                    child: Icon(Icons.palette_rounded,
                        color: glow, size: 22)),
          ),
          const SizedBox(width: Spacing.sm),
          // Testo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(skin.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: skin.colors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
                Text(
                  hasIcon
                      ? '${skin.description} · ${t('store_icon_included')}'
                      : skin.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: skin.colors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          // Azione
          _actionButton(t, glow, owned, active, buy, apply),
        ],
      ),
    );
  }

  Widget _actionButton(String Function(String) t, Color glow, bool owned,
      bool active, VoidCallback buy, VoidCallback apply) {
    if (active) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.check_circle_rounded, size: 16, color: glow),
          const SizedBox(width: 4),
          Text(t('active'),
              style: TextStyle(color: glow, fontWeight: FontWeight.w700)),
        ]),
      );
    }
    if (owned) {
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
            foregroundColor: glow,
            side: BorderSide(color: glow),
            visualDensity: VisualDensity.compact),
        onPressed: apply,
        child: Text(t('apply')),
      );
    }
    return FilledButton(
      style: FilledButton.styleFrom(
          backgroundColor: glow,
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 14)),
      onPressed: buy,
      child: const Text('2,99 €'),
    );
  }
}
