import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/discipline_provider.dart';
import '../state/theme_provider.dart';
import '../state/locale_provider.dart';
import '../services/feedback_service.dart';
import '../theme/app_theme.dart';

/// Segmented control per scegliere la disciplina attiva.
class DisciplineSwitch extends StatelessWidget {
  const DisciplineSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final c = theme.colors;
    final t = context.watch<LocaleProvider>().t;
    final dp = context.watch<DisciplineProvider>();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: Spacing.sm),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.cardAlt,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: disciplines.entries.map((e) {
          final selected = dp.discipline == e.key;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                FeedbackService.selection();
                context.read<DisciplineProvider>().setDiscipline(e.key);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? c.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(Radii.md),
                  boxShadow: selected && theme.glowActive
                      ? glowShadow(c.primary, blur: 10)
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(e.value.icon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      t(e.key),
                      style: TextStyle(
                        color: selected
                            ? (theme.skin.isDark ? Colors.black : Colors.white)
                            : c.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
