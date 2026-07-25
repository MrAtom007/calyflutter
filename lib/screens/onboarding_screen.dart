import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../state/theme_provider.dart';
import '../state/onboarding_provider.dart';
import '../state/locale_provider.dart';
import '../services/feedback_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_kit.dart';

class _Slide {
  final String emoji;
  final String titleKey;
  final String textKey;
  const _Slide(this.emoji, this.titleKey, this.textKey);
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = [
    _Slide('💪', 'ob1_t', 'ob1_s'),
    _Slide('🤸🏋️', 'ob2_t', 'ob2_s'),
    _Slide('➕', 'ob3_t', 'ob3_s'),
    _Slide('📋', 'ob4_t', 'ob4_s'),
    _Slide('📈', 'ob5_t', 'ob5_s'),
    _Slide('🏅', 'ob6_t', 'ob6_s'),
    _Slide('🎨', 'ob7_t', 'ob7_s'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final t = context.watch<LocaleProvider>().t;
    final isLast = _page == _slides.length - 1;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  FeedbackService.onTap();
                  context.read<OnboardingProvider>().finish();
                },
                child: Text(t('skip')),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) {
                  FeedbackService.selection();
                  setState(() => _page = i);
                },
                itemBuilder: (_, i) {
                  final s = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.all(Spacing.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(s.emoji, style: const TextStyle(fontSize: 80))
                            .animate(key: ValueKey(i))
                            .scale(
                                duration: 450.ms,
                                curve: Curves.easeOutBack,
                                begin: const Offset(0.5, 0.5))
                            .then()
                            .shimmer(duration: 1200.ms),
                        const SizedBox(height: Spacing.xl),
                        Text(t(s.titleKey),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: c.text,
                                fontSize: 26,
                                fontWeight: FontWeight.w900))
                            .animate(key: ValueKey('t$i'))
                            .fadeIn(delay: 150.ms)
                            .slideY(begin: 0.2),
                        const SizedBox(height: Spacing.md),
                        Text(t(s.textKey),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: c.textMuted, fontSize: 16))
                            .animate(key: ValueKey('s$i'))
                            .fadeIn(delay: 300.ms),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? c.primary : c.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: c.primary),
                  onPressed: () {
                    FeedbackService.onTap();
                    if (isLast) {
                      context.read<OnboardingProvider>().finish();
                    } else {
                      _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(isLast ? t('begin') : t('next')),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
