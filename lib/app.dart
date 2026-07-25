import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state/theme_provider.dart';
import 'state/onboarding_provider.dart';
import 'state/security_provider.dart';
import 'state/levelup_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/lock_screen.dart';
import 'screens/root_nav.dart';
import 'widgets/level_up_overlay.dart';

/// Decide cosa mostrare: caricamento, lock, onboarding o app.
class AppGate extends StatelessWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final onboarding = context.watch<OnboardingProvider>();
    final security = context.watch<SecurityProvider>();
    final c = theme.colors;

    if (!theme.ready || !security.ready || onboarding.onboarded == null) {
      return Scaffold(backgroundColor: c.bg, body: const SizedBox());
    }

    // Il blocco ha priorità assoluta.
    if (security.locked) {
      return const LockScreen();
    }

    if (onboarding.onboarded == false) {
      return const OnboardingScreen();
    }

    return Stack(
      children: [
        const RootNav(),
        // Overlay level up
        Consumer<LevelUpProvider>(
          builder: (context, lu, _) {
            if (lu.rank == null) return const SizedBox.shrink();
            return LevelUpOverlay(
              rank: lu.rank!,
              level: lu.level ?? 1,
              onDismiss: () => context.read<LevelUpProvider>().dismiss(),
            );
          },
        ),
      ],
    );
  }
}
